import { NextResponse } from 'next/server';

export async function POST() {
  try {
    const testData = {
      timestamp: new Date().toISOString(),
      level: 'INFO',
      message: 'Test message from Next.js to Elasticsearch',
      service: 'nextjs-development',
      environment: 'docker',
      data: {
        user_agent: 'nextjs-app',
        action: 'test_elasticsearch',
        source: 'web_interface'
      }
    }

    // Try direct to Elasticsearch first
    const esResponse = await fetch('http://elasticsearch-master:9200/app-logs/_doc', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(testData),
    })

    if (esResponse.ok) {
      const result = await esResponse.json()
      return NextResponse.json({
        success: true,
        method: 'direct_elasticsearch',
        response: result
      })
    } else {
      // Fallback to Logstash
      const logstashResponse = await fetch('http://logstash-server:8080', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(testData),
      })

      if (logstashResponse.ok) {
        return NextResponse.json({
          success: true,
          method: 'via_logstash',
          message: 'Sent via Logstash pipeline'
        })
      }
    }

    throw new Error('Both Elasticsearch and Logstash are unavailable')

  } catch (error) {
    return NextResponse.json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
      suggestion: 'Try again in a few minutes - Elasticsearch may still be starting'
    }, { status: 500 })
  }
}
