---
title: '基于 EasyTier 组网的 Hermes Agent + Hindsight 共享记忆架构方案'
date: 2026-05-14T14:45:00+08:00
tags: ['Hermes', 'EasyTier', 'Hindsight', '多智能体', '组网']
categories: ['技术思考']
---


## 1. 背景与目标
- **场景**：一台固定公网 IP 的 Ubuntu 服务器、办公室电脑、家中 NAS（24×7在线）和台式机，均运行 Ubuntu。
- **需求**：让各设备上的 [Hermes Agent](https://github.com/NousResearch/hermes-agent) 通过 [EasyTier](https://github.com/EasyTier/EasyTier) 组网共享记忆，减少维护。
- **选型结论**：记忆后端采用 **Hindsight**（`local_external` 模式），其部署极简、Hermes 原生支持本地部署选项，无需外部云服务。

## 2. 架构总览
```
┌───────────────────────────────────────────────────────────┐
│        EasyTier 虚拟局域网 (10.126.126.0/24)               │
│                                                           │
│  ┌───────────────┐     ┌───────────────┐                  │
│  │ 公网服务器      │     │ NAS (24×7)    │                  │
│  │ 10.126.126.1  │     │ 10.126.126.10 │                  │
│  │ (EasyTier中枢) │     │ ★ Hindsight   │                  │
│  │ Hermes Agent  │     │ Docker :8888  │                  │
│  └───────────────┘     └───────┬───────┘                  │
│        │                       │                           │
│  ┌─────┴─────┐                 │                           │
│  │ 办公室电脑  │◄────────────────┘                           │
│  │ DHCP获取IP │                                           │
│  │ Hermes     │                                           │
│  └───────────┘                                           │
│        │                                                  │
│  ┌─────┴─────┐                                           │
│  │ 家里台式机  │                                           │
│  │ DHCP获取IP │                                           │
│  │ Hermes     │                                           │
│  └───────────┘                                           │
└───────────────────────────────────────────────────────────┘
```
- Hindsight 仅部署在 NAS，通过虚拟 IP `10.126.126.10:8888` 统一对外。
- 所有 Agent 通过网络连接同一记忆后端，`user_id` 统一为 `shared-agent` 实现记忆共享。

## 3. EasyTier 组网（关键步骤）
### 3.1 节点角色与 IP
| 节点 | 角色 | 虚拟 IP | 模式 |
|------|------|---------|------|
| 公网服务器 | 私有共享节点 | 10.126.126.1（固定） | 安全模式 |
| NAS | 普通节点 | 10.126.126.10（固定） | 安全模式 |
| 办公室电脑 | 普通节点 | DHCP | 安全模式 |
| 家里台式机 | 普通节点 | DHCP | 安全模式 |

### 3.2 一键部署命令
**公网服务器**（需先获取 [EasyTier](https://github.com/EasyTier/EasyTier/releases)）：
```bash
sudo ./easytier-cli service install \
  --ipv4 10.126.126.1 \
  --network-name "agent-net" \
  --network-secret "your-secret" \
  --secure-mode \
  --local-private-key "your-base64-key" \
  -l tcp://0.0.0.0:11010 -l udp://0.0.0.0:11010 \
  -e tcp://<公网IP>:11010
sudo ./easytier-cli service start
```

**NAS（固定 IP）**：
```bash
sudo ./easytier-cli service install \
  --ipv4 10.126.126.10 \
  --network-name "agent-net" \
  --network-secret "your-secret" \
  --secure-mode \
  -p tcp://<公网IP>:11010
sudo ./easytier-cli service start
```

**动态 IP 设备**（办公室/台式机）：
```bash
sudo ./easytier-cli service install -d \
  --network-name "agent-net" --network-secret "your-secret" \
  --secure-mode -p tcp://<公网IP>:11010
sudo ./easytier-cli service start
```

**验证**：`ping 10.126.126.10` 须通。

## 4. Hindsight 记忆层部署（含双重安全加固）
### 4.1 Docker 容器启动（在 NAS 执行）
```bash
docker run -d \
  --name hindsight \
  --restart unless-stopped \
  -p 10.126.126.10:8888:8888 \
  -p 10.126.126.10:9999:9999 \
  -e HINDSIGHT_API_LLM_PROVIDER=openai \
  -e HINDSIGHT_API_LLM_API_KEY=你的密钥 \
  -e HINDSIGHT_API_LLM_BASE_URL=https://api.deepseek.com \
  -e HINDSIGHT_API_LLM_MODEL=deepseek-chat \
  -v $HOME/.hindsight-docker:/home/hindsight/.pg0 \
  ghcr.io/vectorize-io/hindsight:latest
```
> 关键：`-p 10.126.126.10:8888:8888` 强制 Docker 仅监听虚拟网卡 IP，不暴露于物理局域网或公网。

### 4.2 UFW 防火墙（双重保险）
```bash
sudo ufw allow from 10.126.126.0/24 to any port 8888,9999
sudo ufw deny 8888
sudo ufw deny 9999
sudo ufw enable
```
**验证锁定**：`netstat -tunlp | grep 8888` 应显示 `10.126.126.10:8888` 而非 `0.0.0.0:8888`。

### 4.3 健康检查
在任意 EasyTier 节点：
```bash
curl http://10.126.126.10:8888/health
```
应返回成功。

## 5. Hermes Agent 记忆共享配置
所有需要 Agent 的设备执行：
```bash
hermes memory setup
# 选择 Hindsight -> Docker (local_external) -> http://10.126.126.10:8888
```
**统一 user_id**（全部 Agent 必须一致）：
```bash
echo 'HINDSIGHT_USER_ID=shared-agent' >> ~/.hermes/.env
```

## 6. 部署与验证清单
1. 所有设备安装 EasyTier，按角色启动服务，确认组网互通。
2. NAS 上启动 Hindsight 容器（IP 绑定 + UFW），验证监听地址和健康检查。
3. 每台 Agent 设备配置 Hermes 记忆指向 `http://10.126.126.10:8888`，并统一 `user_id`。
4. 功能测试：在一台设备上告知偏好（如“我喜欢拿铁”），另一台设备新建会话询问，应能正确回忆。

## 7. 运维建议
- **容器保活**：`--restart unless-stopped` 确保自动重启。
- **数据备份**：定期打包 `$HOME/.hindsight-docker`。
- **EasyTier 监控**：`easytier-cli peer` 检查节点在线状态。
- **磁盘空间**：NAS 预留足够空间（镜像 ~6.2 GB，数据初期较小）。

## 8. 方案优势
- **极简部署**：EasyTier 一键服务化，Hindsight 一条 `docker run`。
- **绝对安全**：端口绑定 + UFW 双重隔离，记忆数据不暴露于任何外部网络。
- **零成本自托管**：全部开源，无需云服务订阅。
- **低维护**：24×7 NAS 保证服务长时在线，容器自动恢复，组网自动重连。
- **即时共享**：跨设备 Agent 记忆无缝同步，真正实现协同智能体群体记忆。