# ===========================================================================
# Example Dockerfile for the "app" service in your docker-compose.yml
# ===========================================================================
#
# This file builds a Docker image for a Rails application that can be used
# in place of the existing ghcr.io/maybe-finance/maybe:latest image.
#
# Usage:
# ------
# 1. Place this Dockerfile at the root of your Rails project.
# 2. Copy your Gemfile and Gemfile.lock into the same directory.
# 3. Run "docker build -t my-maybe-app ." to build your image.
# 4. Update docker-compose.yml to use image: "my-maybe-app" (or your tag).
#

# Use a lightweight Ruby base image (adjust version as needed).
FROM ruby:3.2-slim

# Set up environment for Rails.
ENV RAILS_ENV=production \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

# Install system dependencies needed for building gems (e.g., for Rails).
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create a directory for the application code.
WORKDIR /app

# Copy Gemfiles first; this helps in leveraging Docker’s build cache.
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copy the rest of the application’s code.
COPY . .

# Expose Rails app port.
EXPOSE 3000

# Environment variables from docker-compose.yml (you can override via -e or Compose).
# Setting defaults to placeholders or empty. Production secrets should be injected
# externally, not committed here.
ENV SELF_HOSTED="true" \
    RAILS_FORCE_SSL="false" \
    RAILS_ASSUME_SSL="false" \
    GOOD_JOB_EXECUTION_MODE="async" \
    SECRET_KEY_BASE="" \
    DB_HOST="postgres" \
    POSTGRES_DB="maybe_production" \
    POSTGRES_USER="maybe_user" \
    POSTGRES_PASSWORD=""

# Create a volume for Rails Active Storage (similar to app-storage).
# In practice, you may rely on a named volume in docker-compose.yml.
VOLUME ["/app/storage"]

# Start the Rails server. Adjust if you have a different start command.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
