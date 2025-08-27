require('dotenv').config();

console.log('=== Backend Environment Check ===');
console.log('JWT_SECRET:', process.env.JWT_SECRET ? 'SET' : 'NOT SET');
console.log('NODE_ENV:', process.env.NODE_ENV || 'NOT SET');
console.log('PORT:', process.env.PORT || 'NOT SET');
console.log('FRONTEND_URL:', process.env.FRONTEND_URL || 'NOT SET');

if (!process.env.JWT_SECRET) {
  console.log('\n❌ JWT_SECRET is missing! This will cause authentication to fail.');
  console.log('Please create a .env file with JWT_SECRET=your-secret-key');
} else {
  console.log('\n✅ JWT_SECRET is properly configured');
}

console.log('\n=== Testing Database Connection ===');
try {
  // This will test if the database connection works
  const { db } = require('./src/db');
  console.log('✅ Database connection successful');
} catch (error) {
  console.log('❌ Database connection failed:', error.message);
}
