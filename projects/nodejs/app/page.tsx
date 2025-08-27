'use client'

export default function HomePage() {
  const sendToElasticsearch = async () => {
    try {
      const response = await fetch('/api/test-elasticsearch', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      });
      const result = await response.json();
      alert('Elasticsearch test: ' + JSON.stringify(result));
    } catch (error) {
      alert('Error: ' + error);
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md mx-auto bg-white rounded-lg shadow-md p-6">
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900 mb-8">
            Next.js Development Environment
          </h1>
          
          <div className="space-y-4">
            <div className="bg-blue-50 p-4 rounded-lg">
              <h2 className="text-lg font-semibold text-blue-900 mb-2">
                🚀 Development Stack Ready!
              </h2>
              <p className="text-blue-700 text-sm">
                Next.js 15 + React + TypeScript + Tailwind CSS
              </p>
            </div>

            <div className="bg-green-50 p-4 rounded-lg">
              <h3 className="font-semibold text-green-900 mb-2">Database Connections:</h3>
              <ul className="text-sm text-green-700 space-y-1">
                <li>• PostgreSQL: localhost:5432</li>
                <li>• MongoDB: localhost:27017</li>
                <li>• Redis: localhost:6379</li>
                <li>• Elasticsearch: localhost:9200</li>
              </ul>
            </div>

            <div className="space-y-2">
              <button
                onClick={sendToElasticsearch}
                className="w-full bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
              >
                Test Elasticsearch Connection
              </button>
              
              <a
                href="/api/health"
                target="_blank"
                className="block w-full bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded text-center"
              >
                Check API Health
              </a>
            </div>

            <div className="mt-6 p-4 bg-gray-50 rounded">
              <h4 className="font-semibold mb-2">Quick Links:</h4>
              <div className="grid grid-cols-2 gap-2 text-xs">
                <a href="http://localhost:3000" className="text-blue-600 hover:underline">Grafana</a>
                <a href="http://localhost:5601" className="text-blue-600 hover:underline">Kibana</a>
                <a href="http://localhost:9001" className="text-blue-600 hover:underline">MinIO</a>
                <a href="http://localhost:8080" className="text-blue-600 hover:underline">PHP App</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
