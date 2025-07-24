FROM golang:1.24-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o slack-mcp-client ./cmd/

# Use Node.js for MCP servers in the final image
FROM node:20-bullseye

WORKDIR /root/

# Install any extra tools (uvx, etc.)
RUN npm install -g uvx

# Install Alpine tools if you need them (optional)
RUN apt-get update && apt-get install -y ca-certificates tzdata && rm -rf /var/lib/apt/lists/*

# Copy the Go binary and config.json
COPY --from=builder /app/slack-mcp-client .
COPY config.json ./

ENTRYPOINT ["./slack-mcp-client"]
