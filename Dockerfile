FROM ruby:3.2-slim AS builder

WORKDIR /site

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential git \
 && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local path vendor/bundle \
 && bundle install --jobs 4

COPY . .

ARG SITE_URL=https://landing.carbonix.vn
RUN printf 'url: "%s"\n' "${SITE_URL}" > _config.docker.yml \
 && bundle exec jekyll build --config _config.yml,_config.docker.yml

FROM nginx:1.27-alpine AS runner

RUN apk add --no-cache openssl

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
COPY --from=builder /site/_site /usr/share/nginx/html

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
