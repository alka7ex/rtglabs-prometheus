package main

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
)

func main() {
	// Load .env
	err := godotenv.Load()
	if err != nil {
		log.Fatal("❌ Error loading .env file")
	}

	username := os.Getenv("PROMETHEUS_WEB_USERNAME")
	passwordHash := os.Getenv("PROMETHEUS_WEB_PASSWORD_HASH")

	if username == "" || passwordHash == "" {
		log.Fatal("❌ Missing PROMETHEUS_WEB_USERNAME or PROMETHEUS_WEB_PASSWORD_HASH in .env")
	}

	// Build web.yml content
	webYML := fmt.Sprintf("basic_auth_users:\n  %s: %s\n", username, passwordHash)

	// Write to web.yml
	err = os.WriteFile("web.yml", []byte(webYML), 0644)
	if err != nil {
		log.Fatalf("❌ Failed to write web.yml: %v", err)
	}

	fmt.Println("✅ web.yml generated successfully.")
}
