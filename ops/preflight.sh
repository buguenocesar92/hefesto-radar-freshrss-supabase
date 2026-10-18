#!/bin/sh
set -eu
[ "$SUPABASE_DEDICATED_CONFIRMED" = true ] || { echo 'Confirme proyecto Supabase exclusivo'; exit 1; }
[ "$SUPABASE_DATA_API_DISABLED" = true ] || { echo 'Desactive Data API y confirme variable'; exit 1; }
if [ "${PGSSLMODE:-verify-full}" = verify-full ] || [ "${PGSSLMODE:-verify-full}" = verify-ca ]; then
  [ -s "$PGSSLROOTCERT" ] || { echo 'Falta certificado CA'; exit 1; }
else
  # Sin TLS la CA no aplica; psql no debe intentar cargarla.
  unset PGSSLROOTCERT || true
fi
export PGCONNECT_TIMEOUT=15
psql --no-psqlrc -v ON_ERROR_STOP=1 -f /opt/hefesto/preflight.sql
