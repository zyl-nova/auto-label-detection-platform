# 自动标注及目标检测软件开发

本项目包含 Vue 前端和 Spring Boot 后端，用于文件管理、标注任务、样本中心、模型中心、训练任务和目标检测工作区。

## 目录结构

- `junrui/dltools`: 前端项目
- `Java_proj/idtserver/mrserver`: 后端 Maven 多模块项目
- `Java_proj/postgres.sql`: 主业务库表结构和初始化数据
- `Java_proj/AIDetection.sql`: 目标检测演示任务相关表

## 本地环境

- Node.js
- JDK 8
- Maven
- PostgreSQL

## 数据库初始化

后端默认连接：

- host: `localhost`
- port: `5432`
- database: `postgres`
- username: `postgres`

先在 PostgreSQL 中执行：

```sql
-- 使用 IDEA Database、pgAdmin 或 psql 执行
Java_proj/postgres.sql
```

如需目标检测演示表，再执行：

```sql
Java_proj/AIDetection.sql
```

## 环境变量

后端配置支持以下环境变量：

```bash
DB_URL=jdbc:postgresql://localhost:5432/postgres
DB_USERNAME=postgres
DB_PASSWORD=你的数据库密码
JWT_SECRET=你的JWT密钥
NACOS_SERVER_ADDR=localhost:8848
```

Nacos 已默认关闭，普通本地开发不需要启动 Nacos。

## 启动后端

在 IDEA 中打开：

```text
Java_proj/idtserver/mrserver
```

至少启动：

- `ai/src/main/java/com/idtserver/mrserver/AIApplication.java`

如果使用完整登录和网关流程，再启动：

- `auth/src/main/java/com/idtserver/mrserver/AuthApplication.java`
- `user/src/main/java/com/idtserver/mrserver/UserApplication.java`
- `gateway/src/main/java/com/idtserver/mrserver/GatewayApplication.java`

端口：

- Auth: `81`
- User: `82`
- AI: `83`
- Gateway: `80`

## 启动前端

```bash
cd junrui/dltools
npm install
npm run dev
```

开发阶段，前端已将 `/api/AIModuleServer` 直接代理到 `http://localhost:83`，方便调试文件管理和 AI 模块接口。

## Git 协作建议

不要提交：

- `node_modules`
- Maven `target`
- 本地上传文件
- `.env`
- 日志文件

这些内容已经在根目录 `.gitignore` 中忽略。
