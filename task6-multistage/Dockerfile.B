# STAGE 1: Builder
FROM node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# STAGE 2: Runtime
FROM node:20-alpine
WORKDIR /app
# We only copy the final compiled code and modules from the builder
COPY --from=builder /app . 
EXPOSE 3000
CMD ["node", "app.js"]