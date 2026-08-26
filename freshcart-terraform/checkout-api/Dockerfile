# ---------- Build Stage ----------
FROM node:22-alpine AS builder

WORKDIR /app

# Copy dependency files first for better caching
COPY package*.json ./

RUN npm ci

# Copy source
COPY . .

RUN npm run build


# ---------- Runtime Stage ----------
FROM node:22-alpine

WORKDIR /app

ENV NODE_ENV=production

# Update npm to latest patched version
RUN npm install -g npm@latest

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy package files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev

# Copy compiled application
COPY --from=builder /app/dist ./dist

USER appuser

EXPOSE 3000

CMD ["node", "dist/index.js"]
