ARG RUBY_VERSION=3.1.0

FROM ruby:${RUBY_VERSION}-alpine as builder

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN apk add --no-cache git build-base
RUN bundle config path vendor/bundle && bundle install


##########
# RUNNER #
##########
FROM ruby:${RUBY_VERSION}-alpine

WORKDIR /app

# Copy vendor cache over from builder
RUN bundle config path vendor/bundle
COPY --from=builder /app/vendor ./vendor
COPY . .

CMD ["./main.rb"]
