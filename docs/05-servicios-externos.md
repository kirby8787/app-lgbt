# 05. Servicios externos y costos

Precios consultados en noviembre de 2026, en USD salvo que se indique. Confirmar al contratar.
Escenario de referencia: **500 usuarios recurrentes**, 50–150 simultáneos.

| Servicio | Para qué | Plan sugerido al inicio | Costo estimado/mes | Notas |
|---|---|---|---|---|
| Hostinger Cloud Startup | API Node.js, MySQL, panel y portal estáticos, fotos en disco | Ya contratado | $0 adicional | Sin WebSockets entrantes ni workers; ver [01-arquitectura §4](01-arquitectura.md#4-restricciones-del-hosting-y-cómo-se-resuelven) |
| Ably | Chat en tiempo real | Free (200 conexiones simultáneas, 6 M mensajes/mes) | $0 | Siguiente plan: Standard ~$29/mes |
| Firebase Cloud Messaging | Push Android/iOS | Gratis | $0 | También para inicio de sesión con Google |
| APNs | Push iOS | Incluido en Apple Developer | $0 | |
| Huawei Push Kit + IAP | Push y compras en Huawei | Gratis | $0 | Requiere cuenta de AppGallery (gratuita) |
| Mapas (mosaicos) | Radar | **Opción A:** Protomaps (archivo PMTiles de México autoalojado en Hostinger/R2) · **Opción B:** Stadia Maps Starter | A: $0 · B: ~$20 | Los planes gratuitos de MapTiler y Stadia son solo para uso no comercial |
| IA visión + texto | Descripción del perfil | Pago por uso (modelo económico) | < $5 con 500 registros/mes (estimado) | Imagen reducida a ~768 px; límite de regeneraciones |
| Moderación de imágenes | Fotos de perfil y galería | Sightengine Free (2,000 op/mes, 500/día) → Starter $29 (10,000 op) | $0–29 | 1 operación por modelo por imagen |
| Mercado Pago | Premium en web y pagos de anunciantes | Checkout / Suscripciones | Comisión por venta | Tarjeta al instante: 3.49% + $4 MXN + IVA (menor si se espera 7 o 30 días) |
| App Store / Google Play / AppGallery | Publicación y cobro dentro de la app | Cuentas existentes (Apple, Google); AppGallery pendiente | Apple $99/año · Google $25 único · Huawei $0 | Comisión de tiendas sobre suscripciones (15% con programas para desarrolladores pequeños; confirmar en cada tienda) |
| Correo transaccional | Verificación, recuperación, avisos | SMTP de Hostinger | $0 | Si hay problemas de entrega, migrar a un servicio dedicado |
| Almacenamiento S3 (futuro) | Fotos cuando el disco no alcance | Cloudflare R2 | $0 hasta 10 GB | Adaptador listo desde el inicio |

**Costo mensual adicional estimado al lanzar: $0 a ~$55 USD**, según opción de mapas y volumen de moderación.

## Cuándo crecer
| Señal | Acción |
|---|---|
| > 150 conexiones simultáneas en el chat | Ably Standard o migrar a VPS con WebSockets propios |
| API p95 > 300 ms sostenido o límites de CPU/RAM del hosting | VPS (el código ya usa adaptadores) |
| Disco de fotos > 50 GB | Activar adaptador R2 |
| > 2,000 fotos nuevas/mes | Moderación Starter o superior |

## Cuentas que debe crear el dueño del proyecto
Las credenciales nunca se comparten en chat ni se suben al repositorio: van en las variables de entorno del servidor (`api/.env`, plantilla en `api/.env.example`).

1. Firebase (proyecto, apps Android/iOS con el Bundle ID definitivo).
2. Apple Developer: App ID, Sign in with Apple (Services ID + llave), llave APNs, productos de suscripción.
3. Google Play Console: app, productos de suscripción, cuenta de servicio para validar compras.
4. Huawei AppGallery Connect (al final).
5. Ably (API key).
6. Proveedor de IA (API key).
7. Sightengine (API user + secret).
8. Mercado Pago (credenciales de prueba y producción, webhook).
9. Mapas: opción A (sin cuenta) u opción B (Stadia).
