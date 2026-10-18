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

Pasos operativos obligatorios antes de publicar el dominio (no los saltes, el compose no los hace por ti):

- **Bootstrap en Coolify.** La imagen `freshrss/freshrss` requiere una instalación inicial con `HEFESTO_BOOTSTRAP=true`. Levanta `compose.bootstrap.yaml` desde una terminal del servidor con el **mismo nombre de proyecto** que Coolify asignó al clon (`-p <proyecto-coolify> docker compose -f compose.bootstrap.yaml up`), así los volúmenes `data` y `extensions` que crea el bootstrap coinciden con los del servicio `app` que Coolify va a monitorear. Termina con `down` una vez que la URL muestra el login y no la pantalla de setup.
- **Base propia dentro del Postgres compartido.** Si `DB_NAME=mvp_<slug>` (recomendado para Coolify), corre `sql/01-supabase-app.sql` conectado **a esa base** en el SQL Editor del proyecto Supabase, **no** a `postgres`: cambia `DATABASE postgres` por `DATABASE mvp_<slug>` en `GRANT CONNECT ON DATABASE … TO freshrss_app` y en `ALTER ROLE freshrss_app IN DATABASE … SET search_path=public`. Antes de correr el SQL verifica que la base está vacía en `public`, igual que el check actual del archivo.
- **Volúmenes en instalaciones existentes.** Quitar `name:` de la raíz y de los volúmenes cambia los nombres reales: lo que antes era `hefesto-radar-data` y `hefesto-radar-extensions` ahora se nombran `<proyecto>_data` y `<proyecto>_extensions`. Para conservar los datos de una instalación previa tienes dos opciones: (a) fijar `COMPOSE_PROJECT_NAME=hefesto-radar` en Coolify y copiar el contenido de los volúmenes antiguos a los nuevos con un `docker run --rm -v viejo:/from -v nuevo:/to alpine cp -a /from/. /to`; o (b) migrar los datos a un volumen nuevo ya con los nombres actualizados. Si no haces esto, el primer arranque caerá sobre un volumen limpio y `start.sh` abortará al no encontrar la instalación previa.
