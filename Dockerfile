# --- Build Go generator ---
FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY go.mod .
COPY go.sum .
RUN go mod download # Download dependencies

COPY main.go .

RUN go build -o generate-web-yml

# --- Final Prometheus image ---
FROM prom/prometheus:latest

COPY --chown=65534:65534 prometheus.yml /etc/prometheus/prometheus.yml

COPY --from=builder /app/generate-web-yml /usr/local/bin/generate-web-yml

USER root
RUN chmod +x /usr/local/bin/generate-web-yml
USER 65534

# Run generator then Prometheus
# PROMETHEUS_WEB_USERNAME and PROMETHEUS_WEB_PASSWORD_HASH will be directly available from the container's environment
ENTRYPOINT ["/bin/sh", "-c", "/usr/local/bin/generate-web-yml && /bin/prometheus --web.config.file=/etc/prometheus/web.yml --config.file=/etc/prometheus/prometheus.yml --web.listen-address=:9091"]
