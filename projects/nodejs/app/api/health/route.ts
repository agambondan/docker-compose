import { NextResponse } from 'next/server'

export async function GET() {
  return NextResponse.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'nextjs-development',
    environment: 'docker',
    databases: {
      postgresql: 'postgres-main:5432',
      mongodb: 'mongodb-server:27017',  
      redis: 'redis-main:6379',
      elasticsearch: 'elasticsearch-master:9200'
    }
  })
}
