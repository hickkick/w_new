#!/bin/bash
set -e  # Зупинитися при помилці

echo "Running migrations..."
bundle exec sequel -m db/migrations $DATABASE_URL

echo "Starting app..."
exec bundle exec ruby app.rb -p $PORT