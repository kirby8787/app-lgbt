# 01. Arquitectura

Fuente de verdad de requisitos: [00-prompt-maestro.md](00-prompt-maestro.md). Este documento explica **cómo** se construye.

## 1. Metas que guían todas las decisiones

| Meta | Valor |
|---|---|
| Usuarios recurrentes soportados desde el lanzamiento | ≥ 500 (margen hasta 2,000 sin cambiar arquitectura) |
| Usuarios simultáneos en hora pico | 50–150 |
| Respuesta de API (p95) | < 300 ms |
| Abrir app → ver Explorar | < 2 s con caché, < 3 s sin caché |
| Miniatura de foto en la cuadrícula | < 30 KB |
| Servidor | Hostinger Cloud Startup (Node.js gestionado + MySQL) |

## 2. Configuración de marca

El nombre, logo y colores cambiarán. Reglas:

- **Identificadores técnicos neutros**: repo `app-lgbt`, paquete Dart `app`, base de datos `app`, Bundle ID / applicationId **pendiente** (temporal: `mx.expansionmexico.app`; definir antes de crear Firebase, Apple Sign-In y fichas de tiendas, porque después de publicar no se cambia).
- **App móvil**: `mobile/lib/brand/brand_config.dart` + `--dart-define` (nombre, colores, URLs). Textos con `{appName}` en los archivos de traducción (`es`, `en`). Colores solo como tokens del tema.
- **Backend**: tabla `app_settings` + `GET /v1/config` (público, cacheable). Correos, push, panel y portal leen de ahí.
- Colores iniciales: negro / gris carbón + **azul eléctrico** (secundario por definir).

Procedimiento para cambiar la marca: ver sección 0.3 del prompt maestro.

## 3. Diagrama general

```
 ┌──────────────┐  HTTPS/JSON   ┌───────────────────────────┐     ┌────────────┐
 │ App Flutter  │──────────────▶│ API NestJS (Fastify)      │────▶│ MySQL      │
 │ iOS/Android/ │◀──────────────│ Hostinger Cloud Startup   │     │ (Hostinger)│
 │ Huawei       │               │ - REST /v1                │     └────────────┘
 └──────┬───────┘               │ - Webhooks (tiendas, MP)  │     ┌────────────┐
        │                       │ - /internal/cron/*        │────▶│ Disco + CDN│
        │ tiempo real (solo     └──────┬──────────┬─────────┘     │ (fotos)    │
        │ app abierta)                 │ publica  │ envía         └────────────┘
        ▼                              ▼          ▼
 ┌──────────────┐               ┌────────────┐ ┌──────────────────────┐
 │ Ably         │◀──────────────│ Ably REST  │ │ FCM / APNs / Huawei  │
 │ (WebSocket)  │               └────────────┘ │ Push Kit             │
 └──────────────┘                              └──────────────────────┘
 ┌──────────────┐ ┌──────────────┐     Otros: IA (descripción), moderación de imágenes,
 │ Panel admin  │ │ Portal ads   │     mosaicos de mapa (Protomaps/Stadia), Mercado Pago,
 │ (estático)   │ │ (estático)   │     validación de compras (Apple/Google/Huawei).
 └──────────────┘ └──────────────┘
```

## 4. Restricciones del hosting y cómo se resuelven

| Restricción de Hostinger Cloud Startup | Solución |
|---|---|
| No hay WebSockets entrantes | Chat en tiempo real con **Ably** (el backend publica por REST); respaldo con consulta cada 3–5 s solo con el chat abierto; push con la app cerrada |
| No hay procesos permanentes / colas | Tareas programadas con el **cron del hosting** que llama a `POST /internal/cron/<tarea>` con secreto |
| Peticiones cortadas a 120 s | Ninguna operación larga en una petición; la IA tiene tiempo máximo de 25 s |
| El proceso se duerme sin tráfico | Arranque ligero (< 2 s), ping cada 5 min desde el cron |
| Solo MySQL/MariaDB, sin PostGIS | Ubicación por **bounding box** sobre columnas indexadas + celda geohash para ofuscar |
| Sin Redis | Caché LRU en memoria del proceso + contadores atómicos en MySQL |
| Conexiones MySQL limitadas por usuario | Pool de 10 conexiones |

Todo lo anterior está detrás de **adaptadores** (`RealtimePort`, `StoragePort`, `PushPort`, `AiPort`, `ModerationPort`, `PaymentsPort`), para migrar a VPS cambiando configuración.

## 5. Tecnologías

### App móvil (`mobile/`) — Flutter
- Estado: **Riverpod**. Navegación: **go_router** (4 pestañas: Explorar, Radar, Mensajes, Mi perfil).
- HTTP: **dio** con renovación automática de token.
- Base local: **Drift** (SQLite) para conversaciones, perfiles vistos y config.
- Imágenes: `cached_network_image`; compresión antes de subir (≤ 1080 px).
- Mapa: `flutter_map` + mosaicos OpenStreetMap (Protomaps autoalojado o Stadia; sin Google Maps → funciona en Huawei). Ver [05-servicios-externos](05-servicios-externos.md).
- Push: `firebase_messaging` (Android/iOS) + `huawei_push` (Huawei), detectando servicios en tiempo de ejecución.
- Compras: `in_app_purchase` (App Store / Google Play) + Huawei IAP.
- Idiomas: `es` y `en` desde el día uno.

### Backend (`api/`) — NestJS sobre Fastify
- ORM: **Drizzle** (ligero, tipado, sin motor binario).
- Validación: `class-validator` / esquemas por endpoint.
- Auth: JWT de acceso 15 min (sin consultar BD) + refresh token rotativo guardado con hash.
- Módulos: `auth`, `users`, `profiles`, `onboarding`, `explore`, `radar`, `interactions`, `favorites`, `messages`, `reviews`, `plans`, `payments`, `ads`, `moderation`, `notifications`, `admin`, `config`, `cron`.
- Caché en memoria: config, catálogos, permisos de planes (invalidación al editar en el panel).

### Base de datos — MySQL 8 / MariaDB 10.6+
- InnoDB, `utf8mb4`. Esquema en `api/database/schema.sql`. Detalle en [02-modelo-datos.md](02-modelo-datos.md).

### Panel administrativo (`admin/`) y portal de anunciantes (`ads-portal/`)
- **Vite + React** compilados a archivos estáticos (cero consumo de servidor), servidos por Hostinger.
- Consumen la misma API con roles separados: `/v1/admin/*` (administradores) y `/v1/ads/*` (anunciantes). Cuentas y sesiones independientes de los usuarios de la app.

## 6. Diseño de los módulos críticos

### 6.1 Explorar (límite visible por plan)
1. `GET /v1/explore?cursor=` calcula los perfiles más cercanos **en ese momento** (bounding box del radio + distancia), excluyendo bloqueos, el propio usuario, perfiles ocultos y suspendidos.
2. Los primeros `maximum_visible_profiles` del plan (30 / 300, configurable) se devuelven completos.
3. Los siguientes se devuelven como **tarjetas difuminadas**: solo `blurred_thumb_url` (miniatura ya difuminada en el servidor al subir la foto) y distancia redondeada; sin id utilizable, nombre ni datos.
4. Resultado cacheado 3 min por usuario; se recalcula al abrir la pestaña, al moverse > 500 m o al refrescar.
5. El algoritmo de orden está en `ExploreRanker` (interfaz), para cambiarlo sin tocar el resto.

### 6.2 Radar
- Mismo cálculo con dos límites por plan: `maximum_radar_profiles` y `maximum_radar_radius_km`; se aplica el menor.
- Nunca se devuelven coordenadas reales: el marcador se coloca en el centro de la celda geohash (precisión 6, ~1 km) más un desplazamiento fijo por usuario y día. Distancia redondeada (≥ 1 km → entero; < 1 km → «menos de 1 km»).
- Anti-triangulación: la distancia se calcula contra la posición ofuscada, y se limita la frecuencia de cambios de ubicación propia (máx. 1 cada 2 min).

### 6.3 Mensajería
- Envío: `POST /v1/conversations/{id}/messages` → guarda en MySQL → publica en Ably canal `private:conv:{id}` → si el receptor no está conectado, push.
- Recepción con app abierta: Ably (token emitido por `POST /v1/realtime/token`, solo canales de sus conversaciones).
- Respaldo: `GET /v1/conversations/{id}/messages?after_id=` cada 3–5 s solo si Ably falla.
- Caché local en Drift; envío optimista con `client_message_id` (idempotencia).
- Anti-spam: límites por hora configurables, detección de mensajes idénticos, bloqueo temporal.

### 6.4 Reseñas (regla de las últimas 30)
Transacción única con bloqueo de la fila de uso diario:
1. Verificar plan Premium del autor, que no esté bloqueado y que **haya enviado al menos un mensaje** al reseñado.
2. `SELECT ... FOR UPDATE` sobre `daily_usage(user_id, fecha_servicio)`; si `reviews_count >= maximum_reviews_per_day` → rechazar. Incrementar.
3. Buscar la reseña más reciente de ese autor al reseñado; si su `id` está entre las 30 más recientes (por `created_at`, `id`) del reseñado → **actualizar** (calificación, comentario, anonimato, `updated_at`). Si no → **insertar** nueva.
4. Actualizar agregados del reseñado (`review_count`, `review_avg`) en `user_profiles`.
La fecha del límite diario usa la zona horaria del servicio (`America/Mexico_City`, configurable).

### 6.5 Onboarding
- El borrador vive en el teléfono (Drift) y se sincroniza a `onboarding_drafts` en el servidor para no perder datos si se cierra la app.
- La foto de "Descríbete en una imagen" se sube a `POST /v1/onboarding/describe` (multipart), se procesa en memoria, se envía a la IA y **no se escribe en disco**; se responde solo el texto.
- Saludos: `GET /v1/onboarding/greetings` → 5 al azar, uno por nivel (1 pícaro … 5 amigable).
- `POST /v1/onboarding/complete` valida todo (edad ≥ 18 con fecha real) y crea/publica el perfil en una transacción.

### 6.6 Planes y permisos
- `plans` + `plan_permissions` (clave/valor tipado). Toda validación pasa por `PermissionsService.get(userId, key)`, cacheado en memoria.
- Claves iniciales: `maximum_visible_profiles`, `maximum_radar_profiles`, `maximum_radar_radius_km`, `maximum_gallery_photos`, `advanced_filters_enabled`, `reviews_enabled`, `reviews_visible`, `maximum_reviews_per_day`, `maximum_visible_reviews`, `advertising_enabled`, `maximum_favorites`, `ai_regenerations_per_day`.
- Filtros básicos/avanzados: tabla `filters` con bandera `is_premium`, editable en el panel.

### 6.7 Fotos
- Subida → validación de tipo/tamaño → moderación automática → genera `thumb` (200 px), `medium` (600 px), `full` (1080 px) en WebP y `blurred_thumb` (40 px difuminado) → guarda con nombre único (hash) → URL vía CDN con caché larga.
- Estados: `pending_review`, `approved`, `rejected`. Solo el dueño ve `pending_review`.

### 6.8 Publicidad
- Anuncios por espacio (`ad_slots`): banner, perfil patrocinado, tarjeta en Explorar.
- Segmentación permitida: ciudad/región y fechas. Prohibido: conversaciones, roles, preferencias íntimas, coordenadas.
- Impresiones y clics se envían en lotes desde la app (`POST /v1/ads/events`, cada 30 s o al salir), deduplicados.
- Modelos de cobro por espacio: por día, CPM o CPC (configurable). Pausa automática al agotar presupuesto (cron cada 10 min).

### 6.9 Tareas programadas (cron de Hostinger)
| Tarea | Frecuencia |
|---|---|
| `keepalive` | cada 5 min |
| `ads-budget` (pausar campañas sin presupuesto, activar/terminar por fechas) | cada 10 min |
| `subscriptions-expire` (vencimientos, reintentos) | cada hora |
| `cleanup` (borradores viejos, tokens vencidos, archivos huérfanos) | diaria 3:00 |
| `stats-daily` (agregados del panel) | diaria 3:30 |

## 7. Seguridad (resumen)
- Contraseñas con **argon2id**. Refresh tokens con hash y rotación; revocación al cerrar sesión o borrar cuenta.
- Límite de solicitudes por IP y por usuario (memoria).
- Ubicación: nunca se expone; solo distancia redondeada y posición ofuscada.
- Fotos: moderación automática + manual; sin reconocimiento facial.
- Reseñas anónimas: el autor real solo en el panel.
- Bitácora `audit_logs` para todas las acciones del panel.
- Secretos solo en variables de entorno del servidor (`api/.env`, nunca en el repo).

## 8. Estructura de carpetas (objetivo)

```
app-lgbt/
├── api/
│   ├── database/schema.sql, migrations/
│   ├── src/
│   │   ├── common/ (auth guards, permisos, rate-limit, cache, errores)
│   │   ├── ports/ (realtime, storage, push, ai, moderation, payments)
│   │   ├── adapters/ (ably, disk-storage, s3-storage, fcm, apns, hms, ...)
│   │   └── modules/ (auth, profiles, explore, radar, messages, reviews, ...)
│   └── test/
├── mobile/
│   └── lib/
│       ├── brand/ (brand_config.dart, tema)
│       ├── core/ (api, db local, router, i18n)
│       └── features/ (auth, onboarding, explore, radar, chat, profile, premium)
├── admin/        (Vite + React)
├── ads-portal/   (Vite + React)
├── seeds/
└── docs/
```
