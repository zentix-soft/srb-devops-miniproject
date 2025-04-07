# Stage 1: Build dependencies
FROM ruby:3.2-slim AS builder

# Optional: use libvips for image processing
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  curl \
  git \
  libvips \
  && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Install bundler
ENV BUNDLE_JOBS=4
ENV BUNDLE_RETRY=3

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle config set deployment 'true' && bundle install --without development test

# Stage 2: Runtime
FROM ruby:3.2-slim

WORKDIR /app

# Install runtime packages
RUN apt-get update -qq && apt-get install -y \
  libpq5 \
  libvips \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# Add entrypoint script
COPY entrypoints/docker-entrypoint.sh /entrypoints/docker-entrypoint.sh
RUN chmod +x /entrypoints/docker-entrypoint.sh

# Copy full app source
COPY . .

# Expose ports (3000 for web, 9394 for metrics)
EXPOSE 3000 9394

# Default entrypoint and CMD
ENTRYPOINT ["/entrypoints/docker-entrypoint.sh"]
CMD ["rails", "s", "-b", "0.0.0.0", "-e", "production"]