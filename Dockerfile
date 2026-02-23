FROM ruby:4.0.1-slim AS base

ENV RACK_ENV="production" \
  PORT="4567"

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

FROM base

WORKDIR /app

COPY . .

RUN bundle install

EXPOSE $PORT

CMD ["ruby", "app.rb"]
