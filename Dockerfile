# --- Build Go generator ---
FROM golang:1.22-alpine AS builder

WORKDIR /app
# Copy go.mod and go.sum first to leverage Docker layer caching
COPY go.mod .
COPY go.sum .
RUN go mod download # Download dependencies

# Copy your main application code
COPY main.go .

# Build the Go application
RUN go build -o generate-web-yml

# --- Final Prometheus image ---
FROM prom/prometheus:latest

# Copy Prometheus config
COPY --chown=65534:65534 prometheus.yml /etc/prometheus/prometheus.yml

# Copy Go binary
COPY --from=builder /app/generate-web-yml /usr/local/bin/generate-web-yml

USER root
RUN chmod +x /usr/local/bin/generate-web-yml
USER 65534

# Run generator then Prometheus
# Ensure PROMETHEUS_WEB_USERNAME and PROMETHEUS_WEB_PASSWORD_HASH are passed as runtime environment variables by Coolify
ENTRYPOINT ["/bin/sh", "-c", "PROMETHEUS_WEB_USERNAME=${PROMETHEUS_WEB_USERNAME} PROMETHEUS_WEB_PASSWORD_HASH=${PROMETHEUS_WEB_PASSWORD_HASH} /usr/local/bin/generate-web-yml && /bin/prometheus --web.config.file=/etc/prometheus/web.yml --config.file=/etc/prometheus/prometheus.yml --web.listen-address=:9091"]/bin/generate-web-yml && /bin/prometheus --web.config.file=/etc/prometheus/web.yml --config.file=/etc/prometheus/prometheus.yml --web.listen-address=:9091"]
