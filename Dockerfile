# Use Heroku's official Ruby base image
FROM heroku/heroku:24

# Create a non-root user
RUN useradd -m app
WORKDIR /app

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    nodejs \
    postgresql-client \
    yarn

# Install Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Set ownership to non-root user
RUN chown -R app:app /app
USER app

# Configure the port
ENV PORT=3000
EXPOSE 3000

# Start the application
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"] 