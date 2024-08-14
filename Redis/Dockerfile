FROM ruby:3.2.1

WORKDIR /app
COPY . /app

EXPOSE 4567
EXPOSE 6379

ENV RUNNING_ON_SERVER=true
ENV BASIC_AUTH_USERNAME=admin
ENV BASIC_AUTH_PASSWORD=islander

RUN apt-get update && apt-get install -y redis-server
RUN bundle install

# CMD ["ruby", "./app.rb"]
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
COPY config.ru /app/config.ru

# Start the services
CMD ["/usr/local/bin/start.sh"]
