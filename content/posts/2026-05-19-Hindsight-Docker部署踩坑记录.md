---
title: 'Hindsight Docker部署踩坑记录'
date: 2026-05-19T00:00:00+08:00
tags: ['AI', 'Docker', '技术思考', 'Hindsight', '部署']
categories: ['技术思考']
---

# Hindsight Docker 部署踩坑记录

> 部署环境：Ubuntu 22.04.5 / 4 vCPU i3-N305 / 7.8G RAM / Docker v29.4.3
> 部署日期：2026-05-18
> 最后更新：2026-05-19

## 一、初始部署

按照教程用标准参数启动容器：
- LLM: DeepSeek API (deepseek-v4-flash)
- Embeddings: 智谱 embedding-3 (openai provider)
- Reranker: 默认 local (没改)

结果：**容器反复崩溃重启**

## 二、第一个坑 — HuggingFace 网络不通

**现象**：日志报 `RuntimeError: Cannot send a request, as the client has been closed.`，容器启动后 300 秒超时退出。

**原因**：默认的 local reranker 需要从 HuggingFace 下载 `cross-encoder/ms-marco-MiniLM-L-6-v2` 模型，国内访问不了 HuggingFace。

**解决**：加环境变量 `HF_ENDPOINT=https://hf-mirror.com`，走国内镜像。

## 三、第二个坑 — PostgreSQL 数据目录损坏

**现象**：每次重启都报 `WARNING: pg0 data directory exists but no PG_VERSION found`。

**原因**：容器被 kill 时数据库没正常关闭，数据目录残留了损坏的数据，下次启动检测到不一致就从头来。

**解决**：清理数据目录 `rm -rf ~/.hindsight-docker/data/*`，从头初始化。

## 四、第三个坑 — CrossEncoder 初始化卡死（最耗时）

**现象**：加了 HF 镜像后，日志显示模型权重加载到 100% 就停了，之后再无新日志，300 秒超时后容器被杀。

**排查过程**：
1. 进入容器手动测试 `CrossEncoder('cross-encoder/ms-marco-MiniLM-L-6-v2')` → 120 秒超时无响应
2. 测试 PyTorch 基础运算 → 正常
3. 测试 `AutoTokenizer.from_pretrained(...)` → 被 kill (exit 137)
4. 检查内存 → 7.8GB 只用了 600MB，不是 OOM
5. 检查 CPU → 持续 100%

**结论**：`transformers 5.8.1 + sentence_transformers 5.5.0 + PyTorch 2.12.0 CPU` 这套组合在 i3-N305 这颗低端 CPU 上，CrossEncoder 初始化时可能在做某种 CPU 优化编译（torch.compile 或 ONNX 优化），这个操作在缺少 AVX 指令集的 CPU 上极慢，实际上就是死循环。

**解决**：放弃本地 Reranker，改用外部 rerank API。查阅 Hindsight 源码发现支持 siliconflow provider：

```bash
HINDSIGHT_API_RERANKER_PROVIDER=siliconflow
HINDSIGHT_API_RERANKER_SILICONFLOW_MODEL=BAAI/bge-reranker-v2-m3
HINDSIGHT_API_RERANKER_SILICONFLOW_BASE_URL=https://api.siliconflow.cn/v1/
HINDSIGHT_API_RERANKER_SILICONFLOW_API_KEY=sk-xxx
```

## 五、第四个坑 — Embedding 维度超限

**现象**：跳过本地 Reranker 后，终于看到新的错误：

```
RuntimeError: Embedding dimension 2048 on memory_units exceeds pgvector HNSW index limit of 2000
```

**原因**：智谱 embedding-3 模型输出 2048 维，而 Hindsight 内置的 pgvector 的 HNSW 索引最高只支持 2000 维。

**为什么之前没发现**：因为之前每次都在 Reranker 阶段就卡死了，根本走不到 Embedding 初始化数据库这一步。所以前三个坑掩盖了第四个坑。

**最终解决**：换成 SiliconFlow 的 BAAI/bge-m3 模型，原生 1024 维，无需降维，完美在 pgvector 限制内：

```bash
HINDSIGHT_API_EMBEDDINGS_PROVIDER=openai
HINDSIGHT_API_EMBEDDINGS_OPENAI_MODEL=BAAI/bge-m3
HINDSIGHT_API_EMBEDDINGS_OPENAI_BASE_URL=https://api.siliconflow.cn/v1/
HINDSIGHT_API_EMBEDDINGS_OPENAI_API_KEY=sk-xxx
```

> 注：中间曾尝试用 litellm-sdk provider + output_dimensions=1024 降维方案，最终因换成 bge-m3 而不再需要。

## 六、网络隔离 — 端口绑定虚拟 IP

为配合 EasyTier 组网的 Hermes Agent 共享记忆方案，将容器端口从监听所有网卡改为仅监听 EasyTier 虚拟 IP，确保物理局域网和公网无法访问：

```bash
# 之前（不安全）
-p 8888:8888 -p 9999:9999

# 之后（仅 VPN 内可达）
-p 10.126.126.1:8888:8888 -p 10.126.126.1:9999:9999
```

**效果**：
- `10.126.126.1:8888`（虚拟 IP）→ HTTP 200 ✅
- `192.168.31.76:8888`（物理 IP）→ 连接拒绝 ✅ 已隔离

无需开启 UFW 防火墙，端口绑定本身已实现网络隔离。

## 七、最终成功的启动命令

```bash
docker run -d --name hindsight --restart unless-stopped \
  -p 10.126.126.1:8888:8888 \
  -p 10.126.126.1:9999:9999 \
  -e HINDSIGHT_API_LLM_PROVIDER=openai \
  -e HINDSIGHT_API_LLM_API_KEY=sk-xxx \
  -e HINDSIGHT_API_LLM_BASE_URL=https://api.deepseek.com/v1 \
  -e HINDSIGHT_API_LLM_MODEL=deepseek-v4-flash \
  -e HINDSIGHT_API_EMBEDDINGS_PROVIDER=openai \
  -e HINDSIGHT_API_EMBEDDINGS_OPENAI_API_KEY=sk-xxx \
  -e HINDSIGHT_API_EMBEDDINGS_OPENAI_MODEL=BAAI/bge-m3 \
  -e HINDSIGHT_API_EMBEDDINGS_OPENAI_BASE_URL=https://api.siliconflow.cn/v1/ \
  -e HINDSIGHT_API_RERANKER_PROVIDER=siliconflow \
  -e HINDSIGHT_API_RERANKER_SILICONFLOW_MODEL=BAAI/bge-reranker-v2-m3 \
  -e HINDSIGHT_API_RERANKER_SILICONFLOW_BASE_URL=https://api.siliconflow.cn/v1/ \
  -e HINDSIGHT_API_RERANKER_SILICONFLOW_API_KEY=sk-xxx \
  -e HF_ENDPOINT=https://hf-mirror.com \
  -e HINDSIGHT_API_STARTUP_WAIT_SECONDS=600 \
  -v ~/.hindsight-docker/data:/home/hindsight/.pg0 \
  ghcr.io/vectorize-io/hindsight:latest
```

## 八、其他设备 Hermes Agent 接入

其他设备只需编辑 `~/.hermes/.env`，添加：

```bash
HINDSIGHT_MODE=local
HINDSIGHT_API_URL=http://10.126.126.1:8888
```

如需所有设备**共享记忆**（互相同步），再加一行：

```bash
HINDSIGHT_USER_ID=shared-agent
```

然后重启 Hermes（CLI 退出重进，Gateway 发 `/restart`）。

## 总结

| 坑 | 根因 | 解决方案 |
|---|---|---|
| HuggingFace 不通 | 国内网络 | HF_ENDPOINT=hf-mirror.com |
| 数据目录损坏 | 非正常关闭 | 清空 data 目录重来 |
| CrossEncoder 卡死 | transformers 5.x 在低端 CPU 上优化编译极慢 | 改用 SiliconFlow 远程 Reranker |
| Embedding 2048 维超限 | pgvector HNSW 上限 2000 | 换用 bge-m3（原生 1024 维） |
| 端口暴露风险 | 默认监听 0.0.0.0 | 绑定 EasyTier 虚拟 IP |

四个坑是串行的，每个解决后才能暴露下一个。本地 Reranker 卡死这个问题是最隐蔽的，因为它不是报错而是无响应，而且把后面所有错误都挡住了。

最终方案三件套全部使用外部 API：LLM（DeepSeek）、Embeddings（SiliconFlow bge-m3）、Reranker（SiliconFlow bge-reranker-v2-m3），本地零模型加载，启动快、内存省（约 400MB）。
