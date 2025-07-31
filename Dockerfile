# --- Build Go generator ---
FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY main.go .
# No need to copy .env here

# Pass build arguments to the Go build process if main.go uses them at build time
# If main.go only reads env vars at runtime, then you don't need ARG here.
# Assuming main.go reads env vars at runtime, we'll focus on runtime env.
RUN go build -o generate-web-yml

# --- Final Prometheus image ---
FROM prom/prometheus:latest

# Copy Prometheus config
COPY --chown=65534:65534 prometheus.yml /etc/prometheus/prometheus.yml

# Copy Go binary
COPY --from=builder /app/generate-web-yml /usr/local/bin/generate-web-yml
# No need to copy .env here

USER root
RUN chmod +x /usr/local/bin/generate-web-yml
USER 65534

# Modify the ENTRYPOINT to explicitly call generate-web-yml with the necessary env vars
ENTRYPOINT ["/bin/sh", "-c", "PROMETHEUS_WEB_USERNAME=${PROMETHEUS_WEB_USERNAME} PROMETHEUS_WEB_PASSWORD_HASH=${PROMETHEUS_WEB_PASSWORD_HASH} /usr/local/bin/generate-web-yml && /bin/prometheus --web.config.file=/etc/prometheus/web.yml --config.file=/etc/prometheus/prometheus.yml --web.listen-address=:9091"]
