FROM node:18-slim AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y python3 make g++ && rm -rf /var/lib/apt/lists/*


COPY package*.json ./
RUN npm ci

COPY . .

FROM node:18-slim AS runner
WORKDIR /app

COPY --from=builder /app ./

RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

EXPOSE 7000
CMD ["node", "server.js"]