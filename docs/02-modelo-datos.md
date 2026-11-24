# 02. Modelo de datos

- Motor: **MySQL 8.0.16+ o MariaDB 10.6+** (lo que ofrece Hostinger), InnoDB, `utf8mb4`.
- Esquema: [`api/database/schema.sql`](../api/database/schema.sql) · Datos iniciales: [`api/database/seed.sql`](../api/database/seed.sql).
- Validado ejecutándolo en MariaDB 10.11 (46 tablas, seed completo, regla de reseñas probada).

## Tablas por área

| Área | Tablas |
|---|---|
| Configuración y catálogos | `app_settings`, `available_roles`, `interests`, `greetings`, `filters`, `regions` |
| Usuarios y acceso | `users`, `auth_identities`, `refresh_tokens`, `email_codes`, `device_tokens` |
| Perfil | `onboarding_drafts`, `user_profiles`, `user_photos`, `user_interests`, `user_roles` (roles que busca), `user_preferences`, `user_locations` (privada) |
| Planes y pagos | `plans`, `plan_permissions`, `subscriptions`, `payments`, `daily_usage` |
| Social | `profile_interactions`, `favorites`, `blocks`, `reviews`, `reports` |
| Mensajería | `conversations`, `conversation_members`, `messages`, `notifications` |
| Publicidad | `advertisers`, `ad_slots`, `ad_slot_pricing`, `advertising_campaigns`, `campaign_regions`, `advertisements`, `ad_impressions`, `ad_clicks`, `ad_daily_stats` |
| Administración | `admin_users`, `moderation_actions`, `appeals`, `audit_logs`, `stats_daily` |

## Decisiones importantes

1. **Marca fuera del esquema.** Ningún nombre de tabla o columna lleva el nombre comercial; el nombre vive en `app_settings.app_name`.
2. **Ubicación privada.** `user_locations` solo la lee el backend. Búsqueda por bounding box sobre `(lat, lng)`; `geohash6` (~1 km) para colocar marcadores ofuscados. Sin PostGIS.
3. **Límites configurables.** Todo límite comercial está en `plan_permissions` (clave/valor tipado) o `app_settings`; ninguno en código. Valores iniciales en el seed:

   | Permiso | Gratuito | Premium |
   |---|---|---|
   | `maximum_visible_profiles` | 30 | 300 |
   | `maximum_radar_profiles` | 30 | 300 |
   | `maximum_radar_radius_km` | 2 | 20 |
   | `maximum_gallery_photos` | 3 | 10 |
   | `advanced_filters_enabled` | no | sí |
   | `reviews_enabled` (escribir) | no | sí |
   | `reviews_visible` (leer) | no | sí |
   | `maximum_reviews_per_day` | 0 | 3 |
   | `maximum_visible_reviews` | 30 | 30 |
   | `advertising_enabled` | sí | no |
   | `maximum_favorites` | 50 | 500 |
   | `ai_regenerations_per_day` | 3 | 10 |

   Precios: Premium $50 MXN mensual, $400 MXN anual (`plans`).
4. **Reseñas sin restricción única** (`reviewer_user_id`, `reviewed_user_id`), como exige la regla de las últimas 30.
   - «Dentro de las 30»: la reseña más reciente del autor al perfil está entre las 30 más recientes visibles del perfil, ordenadas por `created_at DESC, id DESC`.
   - Al actualizar se cambia `rating`, `comment`, `is_anonymous` y `updated_at`; **`created_at` no cambia**, así la reseña conserva su lugar en la lista.
   - Si el autor borra su cuenta: `reviewer_user_id → NULL`, `reviewer_deleted = 1` → se muestra «Usuario eliminado».
5. **Límite diario atómico.** `daily_usage` con `SELECT … FOR UPDATE` dentro de la transacción de la reseña; la fecha se calcula en `service_timezone`.
6. **Una conversación por pareja.** `conversations.pair_key = "<id menor>:<id mayor>"` con índice único.
7. **Idempotencia de mensajes.** `messages(sender_user_id, client_message_id)` único: reintentar un envío no duplica.
8. **Requisito para reseñar** («le envió al menos un mensaje») se verifica con `idx_msg_sender (conversation_id, sender_user_id)`.
9. **Bandeja rápida.** `conversation_members` copia `last_message_at` y `unread_count` para listar la bandeja con un solo índice.
10. **Anuncios en dos niveles.** Eventos crudos (`ad_impressions`, `ad_clicks`) llegan en lotes, se agregan en `ad_daily_stats` y se purgan a los 90 días, para que la tabla no crezca sin control.

## Consultas críticas

**Regla de las últimas 30 (probada):**
```sql
SELECT r.id,
       r.id IN (SELECT id FROM (SELECT id FROM reviews
                 WHERE reviewed_user_id = :reviewed AND status = 'visible'
                 ORDER BY created_at DESC, id DESC LIMIT 30) t) AS dentro_de_30
FROM reviews r
WHERE r.reviewer_user_id = :reviewer AND r.reviewed_user_id = :reviewed
ORDER BY r.created_at DESC, r.id DESC LIMIT 1;
```

**Cercanos (Explorar / Radar):**
```sql
SELECT l.user_id,
       ST_Distance_Sphere(POINT(l.lng, l.lat), POINT(:lng, :lat)) AS dist_m  -- o fórmula haversine
FROM user_locations l
JOIN user_profiles p ON p.user_id = l.user_id AND p.is_published = 1
JOIN users u ON u.id = l.user_id AND u.status = 'active'
WHERE l.lat BETWEEN :lat_min AND :lat_max
  AND l.lng BETWEEN :lng_min AND :lng_max
  AND l.user_id <> :me
  AND NOT EXISTS (SELECT 1 FROM blocks b WHERE (b.blocker_user_id = :me AND b.blocked_user_id = l.user_id)
                                          OR (b.blocker_user_id = l.user_id AND b.blocked_user_id = :me))
ORDER BY dist_m
LIMIT :limit;
```
Si el hosting no tiene `ST_Distance_Sphere`, se usa la fórmula haversine en SQL (mismo resultado práctico).

## Migraciones
`schema.sql` es la versión inicial (v1). Cambios posteriores irán en `api/database/migrations/NNNN_descripcion.sql`, aplicados en orden por un script del backend.
