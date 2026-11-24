# 03. API

REST + JSON sobre HTTPS. Prefijo `/v1`. Autenticación `Authorization: Bearer <access_token>` salvo donde dice *público*.

## Convenciones
- **Paginación por cursor:** `?cursor=<opaco>&limit=` → respuesta `{ items: [...], next_cursor: "..." | null }`. Nunca `OFFSET`.
- **Errores:** `{ "error": { "code": "REVIEW_DAILY_LIMIT", "message": "…", "details": {} } }` con HTTP 400/401/403/404/409/422/429.
- **Permisos:** cada endpoint con límite comercial consulta `PermissionsService`; si no alcanza → `403 PLAN_REQUIRED` con `{ required_plan: "premium" }`.
- **Idempotencia:** escrituras repetibles aceptan `Idempotency-Key` (mensajes usan `client_message_id`).
- **Fechas:** ISO 8601 en UTC. Distancias: número entero de km o `"<1"`; nunca coordenadas.
- **Límite de solicitudes:** por IP y por usuario; respuesta `429` con `Retry-After`.

## Configuración y catálogos
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/v1/config` *(público, cacheable)* | Marca (`app_name`, colores, logo, URLs), límites de texto, versión mínima de la app |
| GET | `/v1/catalogs` *(público, cacheable)* | Roles, intereses activos, filtros con su bandera premium |

## Autenticación
| Método | Ruta | Descripción |
|---|---|---|
| POST | `/v1/auth/register` | Correo + contraseña → envía código de verificación |
| POST | `/v1/auth/verify-email` | Código de 6 dígitos → tokens |
| POST | `/v1/auth/resend-code` | Reenvío limitado |
| POST | `/v1/auth/login` | Correo + contraseña → tokens (error si no verificado) |
| POST | `/v1/auth/google` · `/v1/auth/apple` | Token del proveedor → tokens (correo verificado) |
| POST | `/v1/auth/refresh` | Rota refresh token |
| POST | `/v1/auth/logout` | Revoca el refresh token del dispositivo |
| POST | `/v1/auth/forgot-password` · `/v1/auth/reset-password` | Recuperar y restablecer |
| DELETE | `/v1/me` | Eliminar cuenta (confirmación con contraseña o re-login) |

## Onboarding
| Método | Ruta | Descripción |
|---|---|---|
| GET/PUT | `/v1/onboarding/draft` | Leer/guardar borrador (paso + datos) |
| GET | `/v1/onboarding/username-available?u=` | Disponibilidad en tiempo real |
| POST | `/v1/onboarding/photo` | Foto principal (multipart) → moderación |
| POST | `/v1/onboarding/describe` | Foto temporal (multipart) → `{ description }`; la foto no se guarda |
| GET | `/v1/onboarding/greetings` | 5 saludos al azar, uno por nivel (llamar de nuevo = «Ver otros») |
| POST | `/v1/onboarding/complete` | Valida todo (edad ≥ 18) y publica el perfil |

## Mi perfil
| Método | Ruta | Descripción |
|---|---|---|
| GET/PATCH | `/v1/me/profile` | Ver/editar perfil |
| POST/DELETE/PATCH | `/v1/me/photos[/:id]` | Galería (límite `maximum_gallery_photos`), orden |
| PUT | `/v1/me/location` | Actualizar ubicación (rechaza > 1 vez cada 2 min) |
| GET/PATCH | `/v1/me/preferences` | Notificaciones, radio, filtros guardados, visibilidad |
| GET | `/v1/me/plan` | Plan actual + permisos efectivos |
| GET | `/v1/me/reviews` | Reseñas recibidas (solo si `reviews_visible`) |
| POST/DELETE | `/v1/me/devices` | Registrar token push (FCM/APNs/HMS) |

## Explorar, radar y perfiles
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/v1/explore?cursor=&filters=` | Cuadrícula: N visibles + resto difuminado (`{ visible: bool, ... }`) |
| GET | `/v1/radar?radius_km=` | Marcadores ofuscados con límites del plan |
| GET | `/v1/profiles/:id` | Detalle (403 si está fuera del límite visible del plan, bloqueado u oculto) |
| PUT | `/v1/profiles/:id/interaction` | `{ type: "up" \| "down" }` (una por pareja) |
| DELETE | `/v1/profiles/:id/interaction` | Quitar manita |
| GET | `/v1/profiles/:id/reviews?cursor=` | Últimas 30 (solo Premium) |
| POST | `/v1/profiles/:id/reviews` | `{ rating, comment, is_anonymous }` → `{ action: "created" \| "updated" }` |
| POST | `/v1/profiles/:id/block` · DELETE | Bloquear / desbloquear |
| POST | `/v1/reports` | Reportar usuario, foto, mensaje, reseña o anuncio |
| GET/POST/DELETE | `/v1/favorites[/:id]` | Favoritos |

## Mensajería
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/v1/conversations?cursor=` | Bandeja (foto, nombre, último mensaje, no leídos, en línea) |
| POST | `/v1/conversations` | `{ user_id }` → crea u obtiene la conversación de la pareja |
| GET | `/v1/conversations/:id/messages?before_id=&after_id=` | Historial / mensajes nuevos |
| POST | `/v1/conversations/:id/messages` | `{ client_message_id, type, body }` |
| POST | `/v1/conversations/:id/read` | `{ last_read_message_id }` |
| POST | `/v1/realtime/token` | Token de Ably limitado a sus conversaciones |

## Suscripciones
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/v1/plans` | Planes y precios de referencia |
| POST | `/v1/subscriptions/verify` | Recibo de App Store / Google Play / Huawei → activa Premium |
| POST | `/v1/subscriptions/mercadopago/checkout` | Liga de pago web |
| POST | `/v1/webhooks/apple` · `/google` · `/huawei` · `/mercadopago` | Notificaciones de renovación, cancelación y reembolso (firma verificada) |

## Anuncios (lado app)
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/v1/ads?slot=&region=` | Anuncios activos para el espacio (vacío si `advertising_enabled = false`) |
| POST | `/v1/ads/events` | Lote de impresiones y clics `{ events: [{ ad_id, type, at }] }` |

## Portal de anunciantes (`/v1/advertisers/*`, sesión propia)
Registro, login, verificación de correo · empresa y datos fiscales · `GET /slots` (espacios, modelos y precios) · campañas CRUD · subir imágenes · `POST /campaigns/:id/quote` (costo) · `POST /campaigns/:id/checkout` (Mercado Pago) · estadísticas por día · `GET /campaigns/:id/report.csv`.

## Panel administrativo (`/v1/admin/*`, sesión propia + 2FA, permisos por rol)
- **Usuarios:** buscar, ver perfil/plan/actividad, suspender, reactivar, eliminar.
- **Moderación:** cola de fotos `pending_review`, reportes, reseñas, apelaciones.
- **Planes:** editar permisos y precios (invalida caché).
- **Publicidad:** anunciantes, aprobar/rechazar campañas y anuncios, espacios y precios por modelo.
- **Catálogos:** roles, intereses, filtros (básico/avanzado), saludos (texto y nivel), `app_settings` (incluye marca).
- **Estadísticas:** `stats_daily` por rango de fechas.
- Toda acción queda en `audit_logs`.

## Internos (cron)
`POST /internal/cron/{keepalive|ads-budget|subscriptions-expire|cleanup|stats-daily}` con encabezado `X-Cron-Secret`.
