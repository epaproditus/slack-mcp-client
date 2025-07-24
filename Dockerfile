# ---- Build Go binary ----
FROM golang:1.24-bullseye AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o slack-mcp-client ./cmd/

# ---- Final image ----
FROM node:20-bullseye

# Install Python 3, pip, and curl for uv/uvx
RUN apt-get update && \
    apt-get install -y python3 python3-pip curl && \
    rm -rf /var/lib/apt/lists/*

# Install uv (which provides uvx)
RUN pip3 install uv

WORKDIR /root/

# Copy Go binary and config.json
COPY --from=builder /app/slack-mcp-client .
COPY config.json ./

# (Optional) Install any global npm packages your MCP servers need
# RUN npm install -g <your-global-npm-package>

ENTRYPOINT ["./slack-mcp-client"]
