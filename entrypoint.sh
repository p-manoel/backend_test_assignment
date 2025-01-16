#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
wait-for-it.sh db:5432 -t 60

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Run database migrations
bundle exec rails db:migrate 2>/dev/null || bundle exec rails db:setup

# Then exec the container's main process
exec "$@"
