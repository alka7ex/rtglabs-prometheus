package main

import (
	"fmt"
	"log"
	"os"
)

func main() {

	// Get environment variables for web.yml
	webUsername := os.Getenv("PROMETHEUS_WEB_USERNAME")
	passwordHash := os.Getenv("PROMETHEUS_WEB_PASSWORD_HASH")

	// Get environment variables for prometheus.yml basic auth
	prometheusUsername := os.Getenv("PROMETHEUS_WEB_USERNAME") // Assuming the same username
	prometheusPassword := os.Getenv("PROMETHEUS_WEB_PASSWORD")

	// Check for required environment variables
	if webUsername == "" || passwordHash == "" || prometheusPassword == "" {
		log.Fatal("❌ Missing PROMETHEUS_WEB_USERNAME, PROMETHEUS_WEB_PASSWORD_HASH, or PROMETHEUS_WEB_PASSWORD in environment variables.")
	}

	// --- web.yml generation ---
	webYML := fmt.Sprintf("basic_auth_users:\n  %s: %s\n", webUsername, passwordHash)

	webOutputPath := "/etc/prometheus/web.yml"
	err := os.WriteFile(webOutputPath, []byte(webYML), 0644)
	if err != nil {
		log.Fatalf("❌ Failed to write %s: %v", webOutputPath, err)
	}
	fmt.Printf("✅ %s generated successfully.\n", webOutputPath)

	// --- prometheus.yml generation ---
	prometheusYML := fmt.Sprintf(`global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    basic_auth:
      username: '%s'
      password: '%s'
    static_configs:
      - targets: ['localhost:9091']
`, prometheusUsername, prometheusPassword)

	prometheusOutputPath := "/etc/prometheus/prometheus.yml"
	err = os.WriteFile(prometheusOutputPath, []byte(prometheusYML), 0644)
	if err != nil {
		log.Fatalf("❌ Failed to write %s: %v", prometheusOutputPath, err)
	}
	fmt.Printf("✅ %s generated successfully.\n", prometheusOutputPath)
}
