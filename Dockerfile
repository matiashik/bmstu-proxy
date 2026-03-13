FROM ruby:4.0.1-slim

ARG CONTAINER_PORT
ENV RACK_ENV="production" \
  PORT=${CONTAINER_PORT}

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN bundle install

EXPOSE ${PORT}

CMD ["ruby", "app.rb"]
