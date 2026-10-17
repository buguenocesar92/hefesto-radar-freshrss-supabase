# Validación y aceptación
Realizado al crear el kit: revisión de opciones PostgreSQL/TLS y del entrypoint en código FreshRSS 1.30.1; validación YAML y sintaxis Python/shell; generación .env privada sin sobrescritura; verificación de integridad ZIP. PHP, Docker y Supabase no se han ejecutado en este entorno.

Pendiente antes de entregar:
- [ ] php -l en configure.php dentro de la imagen y docker compose config --quiet.
- [ ] Preflight positivo con rol propio y fallo ante CA inválida.
- [ ] Instalación nativa sin errores, admin funcional y registro público cerrado.
- [ ] Conexión productiva HTTPS; sin puerto 8096 público ni modo bootstrap.
- [ ] Dos usuarios con fuentes separadas; permisos correctos y API cerrada.
- [ ] Agregar fuentes RSS/Atom reales, categorizar, buscar y marcar favorito.
- [ ] Actualización de cron comprobada en al menos dos ejecuciones; registrar TTL.
- [ ] Reinicio mantiene cuentas, configuración, artículos y favoritos.
- [ ] Respaldo completo y restauración en otro proyecto/volúmenes; comparar conteos y preferencias.
- [ ] Acordar responsable, retención y RPO/RTO medidos; obtener aceptación del cliente.
