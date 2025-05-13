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

-- Create admin user (Remember to change this password in production!)
INSERT INTO users (username, password, role, display_name) 
VALUES ('admin', '$2b$12$NGI6640R20K5y1q/J2nNd.9GQeGfGCifZ8fXLYN4SfUEGCFfP9L72', 'admin', 'Administrator')
ON CONFLICT (username) DO NOTHING;
