# hardened.Dockerfile
# ==========================================
# STAGE 1: Builder
# ==========================================
FROM node:20-alpine AS builder
WORKDIR /build
COPY package*.json ./
# Only install production dependencies
RUN npm ci --only=production
COPY . .

# ==========================================
# STAGE 2: Secure Production Runtime
# ==========================================
FROM node:20-alpine
LABEL maintainer="SRE Security Team"

# 1. Install curl for the native health check
RUN apk add --no-cache curl

# 2. Set strict environment defaults (NO SECRETS HERE)
ENV NODE_ENV=production
WORKDIR /app

# 3. Copy ONLY compiled/production files from the builder
COPY --from=builder /build ./

# 4. Enforce Principle of Least Privilege
# Change ownership to the non-root 'node' user built into the Alpine image
RUN chown -R node:node /app
USER node

# 5. Native Layer 7 Health Check
HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD curl -f http://127.0.0.1:8080/health || exit 1

EXPOSE 8080
CMD ["node", "server.js"]