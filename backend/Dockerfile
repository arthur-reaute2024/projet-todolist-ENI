# Build
FROM node:18 AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# App
FROM node:18
LABEL org.opencontainers.image.source="https://github.com/arthur-reaute2024/projet-todolist-ENI"
WORKDIR /app

COPY --from=build /app .

EXPOSE ${PORT:-3000}
CMD ["node", "src/server.js"]
