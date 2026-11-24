# 07. Pendientes y decisiones abiertas

## Decisiones del dueño
| # | Pendiente | Bloquea | Valor temporal |
|---|---|---|---|
| 1 | Nombre comercial definitivo | Publicación (fase 7) | `{{APP_NAME}}` |
| 2 | Bundle ID / applicationId definitivo (no se cambia después de publicar) | Firebase, Apple Sign-In, tiendas (fase 4e) | `mx.expansionmexico.app` |
| 3 | Color secundario | Fase 2 | Gris carbón `#1C1C1E` |
| 4 | Proveedor de IA para la descripción | Fase 4e | Adaptador; el desarrollador propone el más barato en pruebas |
| 5 | Saludos en inglés (100) | Lanzamiento en inglés | Solo español |
| 6 | Mapas: Protomaps autoalojado o Stadia Starter | Fase 4a | Protomaps |
| 7 | Facturación (CFDI) a anunciantes | Fase 5b | Sin factura automática |
| 8 | Precios reales de los espacios publicitarios | Venta de anuncios | Valores de ejemplo en `seed.sql` |
| 9 | Textos legales (términos, privacidad) revisados por abogado | Publicación | Borrador por hacer |
| 10 | Precio exacto en tiendas (deben usar montos permitidos por cada tienda) | Fase 4d | $50 / $400 MXN como referencia |

## Supuestos tomados (confirmar)
- Precios con IVA incluido.
- Reseñas: bloqueado por el reseñado → no puede reseñarlo.
- Al actualizar una reseña dentro de las 30, conserva su posición (`created_at` no cambia).
- Si un Premium vuelve a gratuito, sus fotos extra se ocultan (no se borran).
- Límites iniciales: radar 2 km / 20 km; galería 3 / 10; favoritos 50 / 500; regeneraciones de IA 3 / 10 por día.
- Filtros gratuitos iniciales: edad y conectados ahora.
- Precios de anuncios de ejemplo: banner $150/día, $60 CPM, $4 CPC (ajustar).
