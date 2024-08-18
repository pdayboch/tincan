# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.4
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_WITHOUT="development"


# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
# and generate ssl certs.
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y build-essential \
  git libpq-dev pkg-config openssl

# Generate self signed SSL certs
RUN mkdir -p /etc/ssl/certs && \
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/ssl/private/server.key \
  -out /etc/ssl/certs/server.crt \
  -subj "/C=US/ST=New York/O=Dayboch Labs/CN=localhost"

# Make sure Bundler version matches the bundler version in Gemfile.lock
# and install Bundler
RUN gem install bundler -v 2.5.17

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
  rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
  bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/


# Final stage for app image
FROM base AS deploy

# Create a non-root rails user.
RUN groupadd rails && \
  useradd rails \
  --create-home \
  --shell /bin/bash \
  -g rails


# Install packages needed for deployment
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  curl postgresql-client && \
  rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails
COPY --from=build /etc/ssl/private/server.key /etc/ssl/private/server.key
COPY --from=build /etc/ssl/certs/server.crt /etc/ssl/certs/server.crt

# Own certs and the runtime files as a non-root user for security
RUN chown -R rails:rails \
  db log storage tmp \
  /etc/ssl/private/server.key \
  /etc/ssl/certs/server.crt && \
  chgrp -R rails /etc/ssl/private && \
  chmod 750 /etc/ssl/private

USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3005
CMD ["./bin/rails", "server"]
