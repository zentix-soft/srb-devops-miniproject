#!/bin/sh
set -e

# -----------------------------------------------------------------------------
# 📌 Entrypoint Script for Rails/Sidekiq Docker Containers
#
# This script ensures the container starts reliably by:
# 1. Removing stale Rails server PID file
# 2. Executing all commands via `bundle exec` (Gemfile-safe context)
# 3. Using `exec` to forward signals for graceful shutdowns (e.g., in Kubernetes)
#
# It allows this image to be used for both web (rails server) and background
# worker (sidekiq) roles with clean startup/shutdown behavior.
# -----------------------------------------------------------------------------

# Clean up stale PID file to prevent Rails boot error
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Run command using Bundler context and forward process signals
exec bundle exec "$@"