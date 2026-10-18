# Hefesto Radar — FreshRSS + Supabase
Kit de despliegue de FreshRSS 1.30.1: lectura RSS/Atom, categorías, búsquedas, favoritos y seguimiento de novedades. Producto sugerido para vender implementación, selección de fuentes, capacitación y mantenimiento a pequeñas empresas o profesionales.

Incluye Docker Compose para Coolify, SQL de rol dedicado, configuración TLS, arranque privado, actualización de fuentes cada 30 minutos, respaldos y restauración. No es una instancia desplegada, un robot de prospección ni una herramienta de scraping universal.

## Stack
- FreshRSS oficial 1.30.1, imagen Debian fijada por digest.
- Supabase PostgreSQL 16/17 exclusivo; conexión nativa, no Data API.
- Volúmenes locales data y extensions. Usuarios y configuración también residen en data: el dump SQL por sí solo NO es un respaldo completo.
- Login propio FreshRSS. Sin Supabase Auth/Storage, IA, pagos ni WhatsApp integrados.

Empiece por docs/instalacion.md. Requiere VPS con Docker y Compose v2, Python 3.11+, dominio HTTPS y proyecto Supabase. No se incluyen cuentas ni secretos reales.

**Estado:** revisión estática del kit y de opciones upstream. Pendientes: ejecutar PHP/Docker, instalar en Supabase y probar los flujos y la recuperación. No se presenta como listo para producción sin esas pruebas.

## Despliegue en Coolify (MVP Hefesto)

Coolify levanta `compose.yaml` como **build pack Docker Compose** detrás de Traefik (TLS y dominio los pone Coolify, no el kit). El servicio `app` queda accesible sólo por la red interna del stack y expone 80 al proxy; no publiques puertos ni agregues `container_name` al compose.

Variables nuevas (defaults preservan el comportamiento anterior):

- `DB_NAME` (default `postgres`): nombre de la base dentro del Postgres compartido. Coolify debe apuntar a una base propia (`mvp_<slug>`).
- `DB_SSLMODE` (default `verify-full`): modo TLS del DSN. Si la base no es Supabase Cloud y conectas por la red interna, usa `DB_SSLMODE=disable`; el certificado `certs/ca.crt` no es obligatorio en ese modo y los scripts `ops/preflight.sh` y `ops/configure.php` no lo exigen.
- Las preexistentes (`DB_HOST`, `DB_USER`, `DB_PASSWORD`, `PUBLIC_URL`, `SUPABASE_DEDICATED_CONFIRMED=true`, `SUPABASE_DATA_API_DISABLED=true`, `TRUSTED_PROXY` con CIDR de la red de Coolify) siguen siendo obligatorias.

Validación previa al push:

```
bash scripts/coolify-check.sh
```
