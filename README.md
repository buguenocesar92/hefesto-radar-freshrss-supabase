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
