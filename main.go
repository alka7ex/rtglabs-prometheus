package main

import (
	"fmt"
	"log"
	"os"
	// Remove this import if godotenv is no longer needed anywhere else
	// "github.com/joho/godotenv"
)

func main() {

	username := os.Getenv("PROMETHEUS_WEB_USERNAME")
	passwordHash := os.Getenv("PROMETHEUS_WEB_PASSWORD_HASH")

	// This check is good and should remain, but it now relies solely on OS environment variables
	if username == "" || passwordHash == "" {
		log.Fatal("❌ Missing PROMETHEUS_WEB_USERNAME or PROMETHEUS_WEB_PASSWORD_HASH in environment variables.")
	}

	// Build web.yml content
	webYML := fmt.Sprintf("basic_auth_users:\n  %s: %s\n", username, passwordHash)

	outputPath := "/etc/prometheus/web.yml" // <--- Corrected output path for web.yml
	err := os.WriteFile(outputPath, []byte(webYML), 0644)
	if err != nil {
		log.Fatalf("❌ Failed to write %s: %v", outputPath, err)
	}

	fmt.Printf("✅ %s generated successfully.\n", outputPath)
}
