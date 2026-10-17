# Instalación inicial
1. Cree un proyecto Supabase exclusivo, PostgreSQL 16 o 17. Desactive Data API en ajustes. Ejecute sql/01-supabase-app.sql como administrador desde SQL Editor; aborta si public contiene tablas.
2. Ejecute `python3 scripts/configure.py`. Genera .env 0600 y dos secretos hexadecimales. Configure DB_HOST y DB_USER. Asigne DB_PASSWORD a freshrss_app mediante `\password freshrss_app` en psql administrativo. Mantenga ADMIN_PASSWORD generado para el bootstrap; no contiene espacios ni caracteres interpretables por el entrypoint upstream.
3. Descargue la CA de su proyecto a certs/ca.crt. Use conexión directa 5432 (IPv6 o complemento IPv4). Si el servidor solo dispone de IPv4, evalúe Session pooler 5432 con host exacto del panel y usuario `freshrss_app.REFERENCIA`. No use Transaction pooler 6543. Para migraciones y backups prefiera conexión directa y compruebe la ruta desde el VPS.
4. Configure PUBLIC_URL HTTPS sin barra final y marque las dos confirmaciones Supabase como true después de cumplirlas. Son declaraciones del operador; preflight valida permisos y tablas, no consulta los ajustes del panel.
5. `docker compose config --quiet` y `docker compose run --rm preflight`.
6. Valide PHP en la imagen: `docker compose run --rm --no-deps --entrypoint php app -l /opt/hefesto/configure.php`.
7. Arranque privado: `docker compose -f compose.yaml -f compose.bootstrap.yaml up -d app`. Revise logs; el instalador nativo configura PostgreSQL y crea admin sin feeds de demostración. La app productiva se niega a arrancar hasta que existan instalación y cuenta admin.
8. Desde su equipo: `ssh -L 8096:127.0.0.1:8096 usuario@servidor`. Visite http://localhost:8096. Ingrese con admin y ADMIN_PASSWORD; cambie la contraseña desde la interfaz. Revise idioma español y permisos.
9. Quite el override y ejecute `docker compose up -d --force-recreate app`. Asigne dominio HTTPS mediante proxy/Coolify al puerto interno 80. Confirme que el puerto 8096 desapareció. El nuevo arranque actualiza base_url al dominio productivo y activa cron a los minutos 7 y 37.
10. Quite ADMIN_PASSWORD de .env después de la instalación y conserve una credencial actual en su gestor. No se utiliza en Compose productivo. No vuelva a ejecutar el bootstrap para cambiar contraseñas.

## Coolify
Importe el directorio completo desde un repositorio privado o servidor; seleccione compose.yaml. Mantenga ops y certs montados y cargue variables como secretos. Haga bootstrap por terminal y túnel antes de asignar acceso público, utilizando exactamente el mismo nombre de proyecto Compose y nombres de volúmenes que usará Coolify. Valide que Coolify no cambia esos nombres; no cree una segunda instalación accidental.

Configure el dominio al servicio app:80, sin puertos públicos en Compose. El proxy debe preservar Host y X-Forwarded-Proto; establezca TRUSTED_PROXY solo con IP/CIDR real del proxy cuando corresponda. No confíe en todas las redes. No se configura SSO en este kit.

## Campos administrados
El arranque actualiza DB, URL, título, usuario predeterminado admin, login por formulario, API desactivada, lectura anónima desactivada, registro cerrado, WebSub desactivado y actualizaciones web desactivadas. Esos campos deben cambiarse en ops/configure.php si se requiere otra política, no solo desde la interfaz. Se preservan salt y opciones ajenas. No renombre admin sin adaptar las comprobaciones.

El instalador nativo usa sus propias migraciones. No copie SQL de otras aplicaciones. Una cuenta adicional se crea desde administración; la lectura de cada usuario tiene sus propias suscripciones, no es un tablero colaborativo compartido.
