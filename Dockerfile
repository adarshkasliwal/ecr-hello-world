# ---- Build Stage ----
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency manifests first (layer-cache optimization)
COPY package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev

# Copy application source
COPY app.js ./

# ---- Production Stage ----
FROM node:20-alpine AS production

# Non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only what we need from builder
COPY --from=builder /app /app

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1

CMD ["node", "app.js"]
