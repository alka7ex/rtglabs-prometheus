
# --- Build Go generator ---
FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY main.go .
COPY .env .
RUN go build -o generate-web-yml

# --- Final Prometheus image ---
FROM prom/prometheus:latest

# Copy Prometheus config
COPY --chown=65534:65534 prometheus.yml /etc/prometheus/prometheus.yml

# Copy Go binary and .env
COPY --from=builder /app/generate-web-yml /usr/local/bin/generate-web-yml
COPY .env /etc/prometheus/.env

USER root
RUN chmod +x /usr/local/bin/generate-web-yml
USER 65534

# Run generator then Prometheus
ENTRYPOINT ["/bin/sh", "-c", "/usr/local/bin/generate-web-yml && /bin/prometheus --web.config.file=/etc/prometheus/web.yml --config.file=/etc/prometheus/prometheus.yml --web.listen-address=:9091"]

