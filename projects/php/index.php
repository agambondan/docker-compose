<?php
// Simple PHP application for development
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database connections
$databases = [
    'postgresql' => [
        'host' => 'postgres-main',
        'port' => 5432,
        'dbname' => 'maindb',
        'user' => 'admin',
        'password' => 'admin123'
    ],
    'mongodb' => [
        'host' => 'mongodb-server',
        'port' => 27017,
        'user' => 'admin',
        'password' => 'admin123'
    ],
    'redis' => [
        'host' => 'redis-main',
        'port' => 6379
    ]
];

// Function to send data to Elasticsearch
function sendToElasticsearch($data) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, "http://elasticsearch-master:9200/app-logs/_doc");
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    curl_close($ch);
    return $response;
}

// Function to send data to Logstash
function sendToLogstash($data) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, "http://logstash-server:8080");
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    curl_close($ch);
    return $response;
}

?>
<!DOCTYPE html>
<html>
<head>
    <title>PHP Development Environment</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; }
        .section { margin: 20px 0; padding: 20px; border: 1px solid #ccc; }
        .success { background-color: #d4edda; border-color: #c3e6cb; }
        .error { background-color: #f8d7da; border-color: #f5c6cb; }
        button { padding: 10px 20px; margin: 10px 0; }
        pre { background: #f8f9fa; padding: 10px; overflow: auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>PHP Development Environment</h1>
        
        <div class="section">
            <h2>Database Connections</h2>
            <?php foreach ($databases as $type => $config): ?>
                <h3><?php echo strtoupper($type); ?></h3>
                <pre><?php echo json_encode($config, JSON_PRETTY_PRINT); ?></pre>
            <?php endforeach; ?>
        </div>
        
        <div class="section">
            <h2>Send Test Data to Elasticsearch</h2>
            <button onclick="sendTestData('elasticsearch')">Send to Elasticsearch</button>
            <div id="es-result"></div>
        </div>
        
        <div class="section">
            <h2>Send Test Data to Logstash</h2>
            <button onclick="sendTestData('logstash')">Send to Logstash</button>
            <div id="logstash-result"></div>
        </div>
        
        <div class="section">
            <h2>PHP Info</h2>
            <p>PHP Version: <?php echo PHP_VERSION; ?></p>
            <p>Server Time: <?php echo date('Y-m-d H:i:s'); ?></p>
            <p>Memory Limit: <?php echo ini_get('memory_limit'); ?></p>
        </div>
    </div>

    <script>
        async function sendTestData(target) {
            const data = {
                timestamp: new Date().toISOString(),
                level: 'INFO',
                message: `Test message from PHP to ${target}`,
                service: 'php-development',
                environment: 'development',
                data: {
                    user_id: 123,
                    action: 'test_log',
                    ip_address: '127.0.0.1'
                }
            };
            
            try {
                const response = await fetch(`send_to_${target}.php`, {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(data)
                });
                
                const result = await response.text();
                document.getElementById(`${target}-result`).innerHTML = 
                    `<div class="success">Response: ${result}</div>`;
            } catch (error) {
                document.getElementById(`${target}-result`).innerHTML = 
                    `<div class="error">Error: ${error.message}</div>`;
            }
        }
    </script>
</body>
</html>
