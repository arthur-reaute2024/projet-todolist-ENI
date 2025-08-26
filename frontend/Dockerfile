# Build
FROM node:16 AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build --prod

# App
FROM nginx:alpine
LABEL org.opencontainers.image.source="https://github.com/arthur-reaute2024/projet-todolist-ENI"

COPY --from=build /app/dist/frontend /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
