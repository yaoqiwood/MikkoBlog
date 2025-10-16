# 构建阶段
FROM node:18-alpine AS build-stage

WORKDIR /app

# 复制package文件
COPY package*.json ./

# 清理npm缓存并安装依赖
RUN npm cache clean --force && npm install

# 复制源代码
COPY . .

# 设置构建参数
ARG VITE_API_BASE_URL=https://mikkocat.top
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL

# 构建应用
RUN npm run build

# 生产阶段
FROM nginx:alpine AS production-stage

# 复制构建结果到nginx
COPY --from=build-stage /app/dist /usr/share/nginx/html

# 复制nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
