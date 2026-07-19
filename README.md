# Carbonix Landing Site

Static marketing site (Jekyll) for Carbonix/NIX — bilingual Vietnamese and English. Showcase shipped features for investors and clients.

Spec: [`specs/F10-landing-site/`](../specs/F10-landing-site/)

## Prerequisites

- Ruby 3.x
- Bundler (`gem install bundler`)

On macOS:

```bash
brew install ruby
```

## Local development

```bash
cd landing_site
make install    # first run or after Gemfile change
make serve      # http://127.0.0.1:4000/ (VI) and /en/ (EN)
```

Other targets:

| Command | Description |
|---------|-------------|
| `make build` | Build static site to `_site/` |
| `make preview` | Build then serve production artifact |
| `make check` | Build + verify VI/EN pages exist |
| `make clean` | Remove `_site` and Jekyll caches |

Variables: `PORT=4000`, `HOST=127.0.0.1`, `DRAFTS='--drafts'`

Example — expose on LAN:

```bash
make serve HOST=0.0.0.0
```

## Docker deploy (production / local stack)

Service `landing_site_web` in root `docker-compose.yml` — Jekyll build → nginx.

| Environment | URL |
|-------------|-----|
| Local (Caddy dev) | https://landing.localhost |
| Production | https://landing.carbonix.vn |

```bash
# From repo root
make deploy

# Or build image only
make -C landing_site docker-build
```

**DNS (production):** A record `landing.carbonix.vn` → server IP (cùng host với `app` / `admin`).

`SITE_URL` build arg mặc định `https://landing.carbonix.vn` (xem `Dockerfile`).

## GitHub Pages deploy

### Option A: GitHub Actions (recommended for monorepo)

Workflow: [`.github/workflows/landing-pages.yml`](../.github/workflows/landing-pages.yml)

1. Push to `main` (changes under `landing_site/` trigger build).
2. Repo **Settings → Pages → Build and deployment → Source: GitHub Actions**.
3. After workflow succeeds, site is published from `gh-pages` branch.

### Option B: Manual build

```bash
cd landing_site
make install && make build
# Upload contents of _site/ to gh-pages branch or Pages artifact
```

### Custom domain

1. **Settings → Pages → Custom domain:** `carbonix.vn` hoặc `landing.carbonix.vn` tùy chiến lược.
2. Override `url` khi build (Jekyll 4 không còn flag `--url`):

```bash
printf 'url: "https://carbonix.vn"\n' > _config.pages.yml
bundle exec jekyll build --config _config.yml,_config.pages.yml
```

3. Ensure `baseurl: ""` trong `_config.yml`.

If using `https://<user>.github.io/<repo>/`, set `baseurl: "/<repo>"` in `_config.yml`.

## Content

Edit copy in [`_data/site.yml`](_data/site.yml) (`vi` and `en` keys). Sections: hero, problem, how it works, features, audiences, platform, CTA.

## Out of scope

- GitHub Pages và Docker có thể dùng song song; production Docker dùng `landing.carbonix.vn`.
- Only showcases **shipped** features (no voucher redemption, NIX Hub, etc.).
