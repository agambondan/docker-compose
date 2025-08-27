package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"
)

type LogEntry struct {
	Timestamp   time.Time   `json:"timestamp"`
	Level       string      `json:"level"`
	Message     string      `json:"message"`
	Service     string      `json:"service"`
	Environment string      `json:"environment"`
	Data        interface{} `json:"data,omitempty"`
}

func sendToElasticsearch(data LogEntry) error {
	jsonData, err := json.Marshal(data)
	if err != nil {
		return err
	}

	resp, err := http.Post("http://elasticsearch-master:9200/app-logs/_doc", 
		"application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	fmt.Printf("Sent to Elasticsearch: %+v\n", data)
	return nil
}

func sendToLogstash(data LogEntry) error {
	jsonData, err := json.Marshal(data)
	if err != nil {
		return err
	}

	resp, err := http.Post("http://logstash-server:8080", 
		"application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	fmt.Printf("Sent to Logstash: %+v\n", data)
	return nil
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	response := map[string]interface{}{
		"status":      "healthy",
		"timestamp":   time.Now(),
		"service":     "go-development",
		"environment": "development",
	}
	json.NewEncoder(w).Encode(response)
}

func testElasticsearchHandler(w http.ResponseWriter, r *http.Request) {
	logEntry := LogEntry{
		Timestamp:   time.Now(),
		Level:       "INFO",
		Message:     "Test message from Go to Elasticsearch",
		Service:     "go-development",
		Environment: "development",
		Data: map[string]interface{}{
			"user_id":    456,
			"action":     "test_log",
			"ip_address": r.RemoteAddr,
		},
	}

	err := sendToElasticsearch(logEntry)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "success"})
}

func testLogstashHandler(w http.ResponseWriter, r *http.Request) {
	logEntry := LogEntry{
		Timestamp:   time.Now(),
		Level:       "INFO",
		Message:     "Test message from Go to Logstash",
		Service:     "go-development",
		Environment: "development",
		Data: map[string]interface{}{
			"user_id":    789,
			"action":     "test_log",
			"ip_address": r.RemoteAddr,
		},
	}

	err := sendToLogstash(logEntry)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "success"})
}

func main() {
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/test-elasticsearch", testElasticsearchHandler)
	http.HandleFunc("/test-logstash", testLogstashHandler)

	// Send initial log
	initialLog := LogEntry{
		Timestamp:   time.Now(),
		Level:       "INFO",
		Message:     "Go development server started",
		Service:     "go-development",
		Environment: "development",
	}
	
	go func() {
		time.Sleep(5 * time.Second) // Wait for other services to start
		sendToElasticsearch(initialLog)
	}()

	fmt.Println("Go development server starting on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
