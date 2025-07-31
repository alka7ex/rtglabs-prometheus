# --- Build Go generator ---
# Change the base image to a Go version >= 1.24.0
FROM golang:1.24-alpine AS builder

WORKDIR /app
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY main.go .

# The build output name should reflect its new purpose
RUN go build -o generate-config

# --- Final Prometheus image ---
FROM prom/prometheus:latest

# The prometheus.yml will now be generated at runtime, so we don't need to copy it
# COPY --chown=65534:65534 prometheus.yml /etc/prometheus/prometheus.yml

# Copy the new generator binary
COPY --from=builder /app/generate-config /usr/local/bin/generate-config

USER root
# Ensure the binary is executable
RUN chmod +x /usr/local/bin/generate-config
USER 65534

# Update the ENTRYPOINT to run the new generator and then Prometheus
# The generator now creates both web.yml and prometheus.yml
ENTRYPOINT ["/bin/sh", "-c", "/usr/local/bin/generate-config && /bin/prometheus --web.config.file=/etc/prometheus/web.yml --config.file=/etc/prometheus/prometheus.yml --web.listen-address=:9091"]
