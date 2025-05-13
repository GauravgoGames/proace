#!/usr/bin/env node

// This script is used to start the application
console.log('Starting ProAce Predictions...');

// Check for environment file
const fs = require('fs');
const path = require('path');

if (!fs.existsSync(path.join(__dirname, '.env'))) {
  console.error('Error: .env file is missing. Please create it first.');
  console.log('Example .env file:');
  console.log('DATABASE_URL=postgres://username:password@localhost:5432/database_name');
  console.log('SESSION_SECRET=your_random_string_here');
  process.exit(1);
}

// Start the server
try {
  require('./server/index');
} catch (error) {
  console.error('Error starting application:', error);
  process.exit(1);
}
