.PHONY: help install serve build preview clean check docker-build

PORT ?= 4000
HOST ?= 127.0.0.1
DRAFTS ?=

# Prefer Homebrew Ruby on macOS when system Ruby is too old for github-pages.
RUBY := $(shell \
	for c in ruby /opt/homebrew/opt/ruby/bin/ruby /usr/local/opt/ruby/bin/ruby; do \
		if command -v $$c >/dev/null 2>&1; then \
			ver=$$($$c -e 'print RUBY_VERSION' 2>/dev/null); \
			major=$$(echo $$ver | cut -d. -f1); \
			minor=$$(echo $$ver | cut -d. -f2); \
			if [ "$$major" -gt 3 ] || { [ "$$major" -eq 3 ] && [ "$$minor" -ge 1 ]; }; then \
				command -v $$c; exit 0; \
			fi; \
		fi; \
	done; \
	command -v ruby)
BUNDLE := $(dir $(RUBY))bundle
JEKYLL := $(BUNDLE) exec jekyll

help:
	@echo "landing_site — Carbonix marketing site (Jekyll)"
	@echo ""
	@echo "  make install    bundle install (first run / after Gemfile change)"
	@echo "  make serve      dev server + live reload (http://$(HOST):$(PORT))"
	@echo "  make build      static build to _site/"
	@echo "  make preview    build then serve production artifact"
	@echo "  make check      build + verify VI/EN pages exist"
	@echo "  make clean      remove _site and Jekyll caches"
	@echo "  make docker-build  build nginx image for docker compose"
	@echo ""
	@echo "Variables: PORT=$(PORT) HOST=$(HOST) DRAFTS='--drafts' (optional)"

install:
	@command -v $(RUBY) >/dev/null 2>&1 || { \
		echo "Error: ruby not found. Install: brew install ruby"; exit 1; \
	}
	@$(RUBY) -e 'v=RUBY_VERSION.split(".").map(&:to_i); exit(v[0]>3 || (v[0]==3 && v[1]>=1) ? 0 : 1)' || { \
		echo "Error: Ruby >= 3.1 required (found $$($(RUBY) -v)). Install: brew install ruby"; exit 1; \
	}
	@command -v $(BUNDLE) >/dev/null 2>&1 || { \
		echo "Error: bundler not found. Install: gem install bundler"; exit 1; \
	}
	@echo "Using Ruby: $$($(RUBY) -v)"
	$(BUNDLE) install

serve: install
	@echo "VI: http://$(HOST):$(PORT)/"
	@echo "EN: http://$(HOST):$(PORT)/en/"
	$(JEKYLL) serve --host $(HOST) --port $(PORT) --livereload $(DRAFTS)

build: install
	$(JEKYLL) build

preview: build
	@echo "Serving production build at http://$(HOST):$(PORT)/"
	$(JEKYLL) serve --host $(HOST) --port $(PORT) --skip-initial-build --no-watch

clean:
	rm -rf _site .jekyll-cache .sass-cache

check: build
	@test -f _site/index.html || (echo "Missing _site/index.html" && exit 1)
	@test -f _site/en/index.html || (echo "Missing _site/en/index.html" && exit 1)
	@echo "check OK: VI and EN pages built"

docker-build:
	docker build -t nix-landing-site-web \
		--build-arg SITE_URL=https://landing.carbonix.vn \
		.
