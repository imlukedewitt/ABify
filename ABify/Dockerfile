FROM ruby:3.2.1

WORKDIR /app

# Copy only necessary files for bundling first to leverage Docker caching
COPY Gemfile Gemfile.lock ./

# Install dependencies
RUN bundle install

# Copy the application code
COPY . .

# The CMD instruction is fine; it starts your application
CMD ["bundle", "exec", "ruby", "./main.rb"]
