# ========= 阶段1：构建 =========
FROM node:20-alpine AS builder

WORKDIR /app

# 使用国内镜像加速（可选但强烈建议）
RUN npm config set registry https://registry.npmmirror.com

# 直接用 npm 全局安装 pnpm（最稳，最快）
RUN npm install -g pnpm

# 复制依赖文件先缓存
COPY package.json pnpm-lock.yaml ./

# 安装依赖
RUN pnpm install --frozen-lockfile

# 复制源码并构建
COPY . .
RUN pnpm run build

# ========= 阶段2：运行时 =========
FROM nginx:alpine

# 复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 解决 Vue Router history 模式 404 问题
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]