FROM node:22-alpine AS base
WORKDIR /usr/src/app
ENV NODE_ENV=production

FROM base AS deps
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev || npm install --omit=dev

FROM base AS runtime
RUN apk add --no-cache curl && addgroup -S app && adduser -S app -G app
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY src ./src
COPY package.json ./
USER app
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -fsS http://localhost:3000/healthz || exit 1
CMD ["node", "src/server.js"]
