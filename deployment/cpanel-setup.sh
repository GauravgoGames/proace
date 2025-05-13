#!/bin/bash

# ProAce Predictions - cPanel Setup Script
echo "===== ProAce Predictions cPanel Setup ====="

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -f "db_schema.sql" ]; then
  echo "Error: Please run this script from the application root directory."
  exit 1
fi

# Create database configuration
echo "Setting up database configuration..."
read -p "Database name: " DB_NAME
read -p "Database user: " DB_USER
read -s -p "Database password: " DB_PASS
echo
read -p "Database host (usually localhost): " DB_HOST
read -p "Database port (usually 5432): " DB_PORT

# Create environment file
cat > .env <<EOL
DATABASE_URL=postgres://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}
SESSION_SECRET=$(openssl rand -hex 32)
EOL

echo "Created .env file with database configuration."

# Check for needed directories
if [ ! -d "public/uploads" ]; then
  echo "Creating upload directories..."
  mkdir -p public/uploads/teams
  mkdir -p public/uploads/profiles
  mkdir -p public/uploads/site
  chmod -R 755 public/uploads
fi

# Install dependencies
echo "Installing dependencies..."
npm install

# Compile TypeScript
echo "Compiling TypeScript..."
npm install typescript --no-save
npx tsc

echo "===== Setup Complete ====="
echo "Your ProAce Predictions application is ready to run."
echo "You can now set up a Node.js application in cPanel to run this app."
echo "Start command: node dist/server/index.js"
echo
echo "Default admin credentials:"
echo "  Username: admin"
echo "  Password: admin123"
echo
echo "IMPORTANT: Change the admin password after first login!"