#!/bin/sh
set -eu
cd /var/www/FreshRSS
if [ "${HEFESTO_BOOTSTRAP:-false}" = true ]; then
  # The native entrypoint expands FRESHRSS_USER. Only generated hexadecimal secrets are accepted.
  case "${ADMIN_PASSWORD:-}" in ''|*[!0-9a-f]*) echo 'ADMIN_PASSWORD debe ser hexadecimal generado'; exit 1;; esac
  [ "${#ADMIN_PASSWORD}" -ge 64 ] || { echo 'Clave inicial demasiado corta'; exit 1; }
else
  [ -f data/applied_migrations.txt ] && [ -f data/users/admin/config.php ] || {
    echo 'Instalacion inicial pendiente; use compose.bootstrap.yaml por tunel privado'; exit 1;
  }
fi
php -f /opt/hefesto/configure.php
exec ./Docker/entrypoint.sh "$@"
