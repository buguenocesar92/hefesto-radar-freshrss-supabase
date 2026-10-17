# Operación y recuperación
## Fuentes y actualización
Importe un OPML del cliente o agregue URLs RSS/Atom desde la interfaz. Empiece con 5 fuentes verificadas. Cron nativo ejecuta el actualizador a los minutos 7 y 37; cada fuente también puede tener un TTL mayor. Esto no garantiza novedades en tiempo real. No se instala un cron en el host ni otra réplica de la aplicación.

Configure límites de retención por usuario antes de cargar cientos de feeds. Revise errores de actualización y consumo de base de datos. El kit mantiene los controles nativos sobre peticiones a hosts internos; no agregue allowlist universal. No se configura correo saliente ni alertas a terceros.

## Respaldo
`python3 scripts/backup.py` detiene app (incluido cron), hace pg_dump de public y archiva data+extensions, .env y Compose. Reinicia solo si estaba activa. Evite tareas CLI, escrituras SQL y despliegues simultáneos. Solo un directorio con manifest completed es completo. Los archivos contienen contraseñas, hashes de usuarios, tokens y posiblemente credenciales de feeds: cifre antes de transferir y guarde copia fuera del VPS. Los hashes detectan daños, no sustituyen autenticación.

Programe y supervise este script según el servicio contratado; el ZIP no registra una programación en el servidor. Conserve el ZIP original y su CA vigente junto al inventario de proxy/DNS.

## Restauración en destino nuevo
1. Prepare otro proyecto Supabase vacío y rol como en instalación; mantenga app detenida. Use la misma imagen 1.30.1 y VOLUME_PREFIX nuevo.
2. Configure .env destino con host/clave nuevos, URL de prueba y CA correcta. No copie ciegamente los datos de conexión antiguos.
3. `docker compose run --rm preflight`
4. `python3 scripts/restore_db.py /ruta/respaldo`
5. `python3 scripts/restore_files.py /ruta/respaldo`
6. `docker compose up -d app` SIN bootstrap. El arranque actualiza las credenciales del config.php restaurado preservando su salt; entrypoint nativo ajusta permisos. Use el login que estaba vigente al respaldar.
7. Verifique usuarios, categorías, feeds, artículos, favoritos y cron antes de cambiar DNS. Evite dos instancias actualizando la misma base.

Los scripts rechazan destinos con contenido. No arrancar app antes de restaurar archivos, porque la imagen puede poblar volúmenes. Ante una restauración parcial fallida, investigar y preparar otro destino vacío; no borrar el origen. No se respalda Supabase Auth/Storage ni el proyecto entero.

Los archivos de extensiones deben ser normales, sin enlaces simbólicos; la restauración rechaza enlaces, rutas fuera del archivo y tipos especiales. Audite extensiones de terceros antes de instalarlas.

## Actualizaciones
Respaldar, ensayar en clon, revisar cambios y después actualizar digest. No use el actualizador web dentro de Docker. Volver solo a una imagen anterior no revierte migraciones: recuperar DB+volúmenes juntos. postgres:17-alpine recibe parches; registre el digest utilizado si requiere reproducibilidad estricta.
