#!/bin/sh
set -e

# Clean up stale PID file
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Ensure Bundler is used to run all commands
exec bundle exec "$@"