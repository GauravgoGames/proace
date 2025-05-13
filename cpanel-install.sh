#!/bin/bash

# ProAce Predictions Simple Installer
echo "===== ProAce Predictions Installer ====="

# Check if running in cPanel environment
if [ ! -d "/home/$(whoami)/public_html" ]; then
  echo "Error: This script should be run in a cPanel environment."
  exit 1
fi

# Ask for installation directory
read -p "Enter installation directory (e.g., predictions): " INSTALL_DIR
INSTALL_PATH="/home/$(whoami)/public_html/$INSTALL_DIR"

# Create installation directory
mkdir -p "$INSTALL_PATH"
cd "$INSTALL_PATH"

# Clone the repository
echo "Downloading application files..."
git clone https://github.com/GauravgoGames/proace.git .

# Clean up Git files
rm -rf .git

# Ask for database credentials
echo "Please enter your PostgreSQL database credentials:"
read -p "Database name: " DB_NAME
read -p "Database user: " DB_USER
read -s -p "Database password: " DB_PASS
echo
read -p "Database host (usually localhost): " DB_HOST
read -p "Database port (usually 5432): " DB_PORT

# Create environment config
echo "Creating configuration..."
cat > .env <<EOL
DATABASE_URL=postgres://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}
SESSION_SECRET=$(openssl rand -hex 32)
EOL

# Create database schema file
cat > db_schema.sql <<EOL
-- Create tables
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(255),
  display_name VARCHAR(255),
  profile_image VARCHAR(255),
  role VARCHAR(50) NOT NULL DEFAULT 'user',
  points INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS teams (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  logo_url VARCHAR(255),
  is_custom BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS matches (
  id SERIAL PRIMARY KEY,
  tournament_name VARCHAR(255) NOT NULL,
  team1_id INTEGER NOT NULL REFERENCES teams(id),
  team2_id INTEGER NOT NULL REFERENCES teams(id),
  location VARCHAR(255) NOT NULL,
  match_date TIMESTAMP NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'upcoming',
  toss_winner_id INTEGER REFERENCES teams(id),
  match_winner_id INTEGER REFERENCES teams(id),
  team1_score VARCHAR(100),
  team2_score VARCHAR(100),
  result_summary TEXT
);

CREATE TABLE IF NOT EXISTS predictions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  match_id INTEGER NOT NULL REFERENCES matches(id),
  predicted_toss_winner_id INTEGER REFERENCES teams(id),
  predicted_match_winner_id INTEGER REFERENCES teams(id),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  points_earned INTEGER
);

CREATE TABLE IF NOT EXISTS points_ledger (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  match_id INTEGER NOT NULL REFERENCES matches(id),
  points INTEGER NOT NULL,
  reason VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS site_settings (
  id SERIAL PRIMARY KEY,
  key VARCHAR(255) NOT NULL UNIQUE,
  value TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sessions (
  sid VARCHAR(255) NOT NULL PRIMARY KEY,
  sess JSON NOT NULL,
  expire TIMESTAMP(6) NOT NULL
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_predictions_user_id ON predictions(user_id);
CREATE INDEX IF NOT EXISTS idx_predictions_match_id ON predictions(match_id);
CREATE INDEX IF NOT EXISTS idx_points_ledger_user_id ON points_ledger(user_id);
CREATE INDEX IF NOT EXISTS idx_matches_status ON matches(status);
CREATE INDEX IF NOT EXISTS idx_sessions_expire ON sessions(expire);

-- Create admin user
INSERT INTO users (username, password, role, display_name)
VALUES ('admin', '$2b$12$NGI6640R20K5y1q/J2nNd.9GQeGfGCifZ8fXLYN4SfUEGCFfP9L72', 'admin', 'Administrator')
ON CONFLICT (username) DO NOTHING;
EOL

# Set up upload directories
echo "Creating upload directories..."
mkdir -p public/uploads/teams
mkdir -p public/uploads/profiles
mkdir -p public/uploads/site
chmod -R 755 public/uploads

# Install dependencies
echo "Installing dependencies..."
npm install

# Build client
echo "Building client..."
npm run build

# Set up database
echo "Setting up database..."
PGPASSWORD="$DB_PASS" psql -U "$DB_USER" -h "$DB_HOST" -d "$DB_NAME" -f db_schema.sql

# Create Node.js setup file
cat > setup_nodeapp.txt <<EOL
Application path: $INSTALL_PATH
Application URL: https://$(hostname)/$INSTALL_DIR
Application startup file: server/index.js
Application environment: production
Node.js version: 20.x
EOL

echo "===== Installation Complete ====="
echo "Your ProAce Predictions application has been installed to $INSTALL_PATH"
echo ""
echo "Next steps:"
echo "1. Go to cPanel > Setup Node.js App"
echo "2. Click 'Create Application'"
echo "3. Use the settings in the setup_nodeapp.txt file"
echo "4. After creating the Node.js application, you can access your site"
echo ""
echo "Default admin credentials:"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
echo "IMPORTANT: Change the admin password after first login!"