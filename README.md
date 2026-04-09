# 🔐 Linux 系统配置自动备份工具

![Bash](https://img.shields.io/badge/Bash-4.4+-green)
![Linux](https://img.shields.io/badge/Linux-CentOS/Ubuntu-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

> 一个用于自动备份 Linux 系统关键配置目录的 Bash 脚本。支持多目录备份、时间戳归档、自动清理旧备份、详细日志记录。

## 🎯 功能亮点

- ✅ 自动备份常见服务配置：Nginx、Apache、MySQL、SSH
- ✅ 生成带时间戳的 `tar.gz` 压缩包
- ✅ 支持自定义备份目标目录
- ✅ 支持详细输出模式（`-v`）
- ✅ 完整的日志记录（`/var/log/backup_config.log`）
- ✅ 自动清理 7 天前的旧备份
- ✅ 错误处理与命令依赖检查
- ✅ 帮助信息（`-h`）

## 🧰 适用场景

- 运维人员定期备份服务器配置
- 配合 crontab 实现每日自动备份
- 系统迁移前的配置快照

## 🚀 快速开始

### 前置条件

- Linux 操作系统（CentOS / Ubuntu / Debian）
- 已安装 `tar`、`find`（通常系统自带）
- 以 root 或具有读取配置文件权限的用户运行

### 下载与使用

```bash
git clone https://github.com/你的用户名/linux-config-backup-tool.git
cd linux-config-backup-tool
chmod +x backup_config.sh

# 备份到默认目录 /backup/configs
sudo ./backup_config.sh

# 备份到自定义目录
sudo ./backup_config.sh /mnt/my_backup

# 详细模式（同时输出到终端）
sudo ./backup_config.sh -v

# 查看帮助
./backup_config.sh -h









# 🚀 FullStack Web App with Docker Compose

![Docker](https://img.shields.io/badge/Docker-20.10-blue)
![Node.js](https://img.shields.io/badge/Node.js-14-green)
![MySQL](https://img.shields.io/badge/MySQL-5.7-orange)
![Nginx](https://img.shields.io/badge/Nginx-1.20-brightgreen)

> 一个基于 Docker Compose 的全栈应用示例，包含：
> - 前端：Nginx 托管静态页面
> - 后端：Node.js + MySQL 连接池
> - 数据库：MySQL 5.7，支持 UTF8MB4

## 🧰 技术栈

| 组件         | 技术                         |
|--------------|------------------------------|
| 前端         | HTML5 + JavaScript + Nginx   |
| 后端         | Node.js + MySQL2             |
| 数据库       | MySQL 5.7                    |
| 容器化       | Docker + Docker Compose      |
| 网络         | 自定义桥接网络               |

## 🧱 架构图
[用户] → [Nginx:80] → [Node.js:3000] → [MySQL:3306]


## 🚀 快速开始

### 前置条件
- Docker (>=20.10)
- Docker Compose (>=2.0)

### 启动项目

```bash
git clone https://github.com/你的用户名/fullstack-web-app-docker-compose.git
cd fullstack-web-app-docker-compose
docker-compose up -d

🔐 环境变量
复制 .env.example 为 .env 并修改（可选，已有默认值）：

bash
cp .env.example .env


变量名	               说明	                          默认值
DB_PASSWORD	         数据库用户密码	                apppass
MYSQL_ROOT_PASSWORD	  MySQL root 密码	               rootpass
✨ 项目亮点
✅ 完整的三层架构（前端 / 后端 / 数据库）

✅ 使用 Docker Compose 一键部署

✅ 支持数据库字符集 UTF8MB4（兼容 emoji）

✅ 前后端分离，Nginx 反向代理

✅ 生产级 Node.js 数据库连接池

✅ 清晰的目录结构与工程化配置

📌 待优化项
















