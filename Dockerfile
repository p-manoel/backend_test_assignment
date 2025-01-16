FROM ruby:2.7.2

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  wget \
  # Additional dependencies for Nokogiri
  libxml2-dev \
  libxslt-dev \
  pkg-config

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler:2.2.15

# Force Nokogiri to compile from source
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=1

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle config build.nokogiri --use-system-libraries && \
  bundle config force_ruby_platform true && \
  bundle install

# Install wait-for-it
RUN wget -O /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
  && chmod +x /usr/local/bin/wait-for-it.sh

# Copy the rest of the application
COPY . .

# Add entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]
