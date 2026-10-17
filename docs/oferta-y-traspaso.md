# Oferta comercial y entrega
Paquete sugerido: configuración inicial, catálogo de fuentes por sector, categorías, capacitación, alojamiento, copias y mantenimiento mensual. Complemento opcional de trabajo humano: selección semanal de enlaces relevantes. No se incluyen campañas automáticas, resúmenes con IA ni extracción masiva de datos.

Ejemplos de organización manual:
- Estudio/agencia: novedades tecnológicas, competidores y clientes.
- Comercio: proveedores, tendencias y novedades sectoriales.
- Profesional: publicaciones especializadas, oportunidades y noticias locales.

Acordar alcance por fuentes, cuentas, retención y atención. No se inventan precios de mercado, clientes ni resultados comerciales. Redistribuir artículos completos puede requerir permiso; al entregar informes, priorizar enlaces y notas propias.

## Plantilla para configurar manualmente
Categorías: Sector / Competidores / Herramientas / Oportunidades. Cada fuente debe registrar URL RSS/Atom, titular, propósito, frecuencia esperada y responsable. Favoritos para artículos a revisar y etiquetas según el flujo del cliente. No se incluyen fuentes inventadas ni contenido precargado.

## Traspaso a otro servidor
Entregar acceso al dominio/proxy, propiedad Supabase, rol de aplicación, Compose, versión/digest, volúmenes y backup restaurado de prueba. Transferir secretos mediante gestor seguro, rotar accesos del operador saliente y documentar retención y soporte. Una instalación y proyecto Supabase por cliente; si comparte host, usar COMPOSE_PROJECT_NAME y VOLUME_PREFIX únicos conservados en todos los comandos.

## Relación con Odoo
FreshRSS permanece como herramienta de seguimiento. Para trasladar un hallazgo a CRM, crear oportunidad o tarea con título, enlace de origen, fecha, nota y responsable. Es una integración por construir, no instalada aquí. Odoo no sustituye automáticamente el lector RSS; no importar el dump PostgreSQL en la base Odoo.

OPML exporta suscripciones y categorías, no todo el historial, usuarios o favoritos. Para mover toda la instalación use los respaldos DB+data+extensions. Para n8n u otro cliente, diseñar integración de API y habilitarla con credenciales específicas tras pruebas; la API está desactivada inicialmente.

FreshRSS se distribuye con licencia AGPL-3.0; conservar créditos y cumplir obligaciones aplicables si se modifica. El kit distribuye configuración y scripts de operación, no los binarios upstream.
