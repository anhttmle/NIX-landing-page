#!/bin/sh
set -e

CERT_DIR=/etc/nginx/certs
mkdir -p "$CERT_DIR"

if [ ! -f "$CERT_DIR/server.crt" ]; then
  EXTRA_SAN=""
  if [ -n "$LAN_IP" ]; then
    EXTRA_SAN=",IP:${LAN_IP}"
  fi
  openssl req -x509 -nodes -days 825 -newkey rsa:2048 \
    -keyout "$CERT_DIR/server.key" \
    -out "$CERT_DIR/server.crt" \
    -subj "/CN=nix-landing-local" \
    -addext "subjectAltName=DNS:localhost,DNS:landing.localhost,IP:127.0.0.1${EXTRA_SAN}"
fi

exec nginx -g 'daemon off;'
