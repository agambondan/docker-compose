// Create application database and user
db = db.getSiblingDB('maindb');

// Create application user
db.createUser({
  user: 'appuser',
  pwd: 'apppass123',
  roles: [
    {
      role: 'readWrite',
      db: 'maindb'
    }
  ]
});

// Create sample collection
db.createCollection('users');

// Insert sample data
db.users.insertMany([
  {
    name: 'Admin User',
    email: 'admin@example.com',
    role: 'admin',
    created: new Date()
  },
  {
    name: 'Regular User',
    email: 'user@example.com',
    role: 'user',
    created: new Date()
  }
]);

print('Database initialized successfully');
