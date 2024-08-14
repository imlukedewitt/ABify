FROM ruby:3.2.1


WORKDIR /app
COPY . /app

ENV RUNNING_ON_SERVER=true
ENV BASIC_AUTH_USERNAME=admin
ENV BASIC_AUTH_PASSWORD=islander
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/config/keyfile.json

RUN bundle install

# EXPOSE 8080

CMD ["ruby", "./main.rb"]
