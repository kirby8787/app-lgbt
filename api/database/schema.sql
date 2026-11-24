-- =====================================================================
-- Esquema de base de datos — app-lgbt
-- Compatible con MySQL 8.0.16+ y MariaDB 10.6+ (InnoDB, utf8mb4)
-- Nombres técnicos neutros: el nombre comercial vive en app_settings.
-- =====================================================================

SET NAMES utf8mb4;
SET foreign_key_checks = 0;

-- ---------------------------------------------------------------------
-- Configuración y catálogos
-- ---------------------------------------------------------------------

CREATE TABLE app_settings (
  setting_key   VARCHAR(64)  NOT NULL PRIMARY KEY,
  setting_value TEXT         NOT NULL,
  is_public     TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '1 = se entrega en GET /v1/config',
  updated_at    DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE available_roles (
  id         SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code       VARCHAR(32)  NOT NULL UNIQUE,
  name_es    VARCHAR(64)  NOT NULL,
  name_en    VARCHAR(64)  NOT NULL,
  sort_order SMALLINT     NOT NULL DEFAULT 0,
  is_active  TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE interests (
  id                 INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  slug               VARCHAR(64)  NOT NULL UNIQUE,
  name_es            VARCHAR(64)  NOT NULL,
  name_en            VARCHAR(64)  NOT NULL,
  is_custom          TINYINT(1)   NOT NULL DEFAULT 0 COMMENT 'creada por un usuario',
  created_by_user_id BIGINT UNSIGNED NULL,
  is_active          TINYINT(1)   NOT NULL DEFAULT 1,
  sort_order         SMALLINT     NOT NULL DEFAULT 0,
  created_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  KEY idx_interests_active (is_active, is_custom, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE greetings (
  id         INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  text       VARCHAR(120) NOT NULL,
  level      TINYINT UNSIGNED NOT NULL COMMENT '1 pícaro, 2 coqueto, 3 juguetón, 4 casual, 5 amigable',
  language   CHAR(2)      NOT NULL DEFAULT 'es',
  is_active  TINYINT(1)   NOT NULL DEFAULT 1,
  created_at DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT chk_greetings_level CHECK (level BETWEEN 1 AND 5),
  KEY idx_greetings_pick (language, is_active, level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE filters (
  code       VARCHAR(32) NOT NULL PRIMARY KEY,
  name_es    VARCHAR(64) NOT NULL,
  name_en    VARCHAR(64) NOT NULL,
  is_premium TINYINT(1)  NOT NULL DEFAULT 1 COMMENT '0 = básico (gratuito), 1 = avanzado (Premium)',
  is_active  TINYINT(1)  NOT NULL DEFAULT 1,
  sort_order SMALLINT    NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE regions (
  id         INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(120) NOT NULL,
  state      VARCHAR(120) NOT NULL,
  country    CHAR(2)      NOT NULL DEFAULT 'MX',
  center_lat DECIMAL(9,6) NOT NULL,
  center_lng DECIMAL(9,6) NOT NULL,
  radius_km  SMALLINT UNSIGNED NOT NULL DEFAULT 30,
  is_active  TINYINT(1)   NOT NULL DEFAULT 1,
  UNIQUE KEY uq_regions (country, state, name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Usuarios y autenticación
-- ---------------------------------------------------------------------

CREATE TABLE users (
  id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  email             VARCHAR(254) NOT NULL,
  email_verified_at DATETIME(3)  NULL,
  password_hash     VARCHAR(255) NULL COMMENT 'argon2id; NULL si solo usa Google/Apple',
  status            ENUM('pending_onboarding','active','suspended','deleted') NOT NULL DEFAULT 'pending_onboarding',
  locale            CHAR(2)      NOT NULL DEFAULT 'es',
  last_active_at    DATETIME(3)  NULL,
  suspended_reason  VARCHAR(255) NULL,
  created_at        DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at        DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_at        DATETIME(3)  NULL,
  UNIQUE KEY uq_users_email (email),
  KEY idx_users_status (status, last_active_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE auth_identities (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id          BIGINT UNSIGNED NOT NULL,
  provider         ENUM('google','apple') NOT NULL,
  provider_user_id VARCHAR(255) NOT NULL,
  created_at       DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_identity (provider, provider_user_id),
  KEY idx_identity_user (user_id),
  CONSTRAINT fk_identity_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE refresh_tokens (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT UNSIGNED NOT NULL,
  token_hash  CHAR(64)     NOT NULL COMMENT 'SHA-256 del token',
  device_id   VARCHAR(64)  NULL,
  expires_at  DATETIME(3)  NOT NULL,
  revoked_at  DATETIME(3)  NULL,
  created_at  DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_refresh_hash (token_hash),
  KEY idx_refresh_user (user_id, revoked_at),
  CONSTRAINT fk_refresh_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE email_codes (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id    BIGINT UNSIGNED NOT NULL,
  purpose    ENUM('verify_email','reset_password') NOT NULL,
  code_hash  CHAR(64)     NOT NULL,
  attempts   TINYINT UNSIGNED NOT NULL DEFAULT 0,
  expires_at DATETIME(3)  NOT NULL,
  used_at    DATETIME(3)  NULL,
  created_at DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  KEY idx_codes_user (user_id, purpose, created_at),
  CONSTRAINT fk_codes_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE device_tokens (
  id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id      BIGINT UNSIGNED NOT NULL,
  provider     ENUM('fcm','apns','hms') NOT NULL,
  token        VARCHAR(512) NOT NULL,
  platform     ENUM('ios','android','huawei') NOT NULL,
  app_version  VARCHAR(20)  NULL,
  last_seen_at DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_device_token (provider, token(255)),
  KEY idx_device_user (user_id),
  CONSTRAINT fk_device_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Onboarding y perfil
-- ---------------------------------------------------------------------

CREATE TABLE onboarding_drafts (
  user_id    BIGINT UNSIGNED NOT NULL PRIMARY KEY,
  step       TINYINT UNSIGNED NOT NULL DEFAULT 1,
  data       JSON         NOT NULL,
  updated_at DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_draft_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_profiles (
  user_id        BIGINT UNSIGNED NOT NULL PRIMARY KEY,
  display_name   VARCHAR(50)  NOT NULL,
  username       VARCHAR(30)  NOT NULL,
  birth_date     DATE         NOT NULL,
  own_role_id    SMALLINT UNSIGNED NOT NULL COMMENT 'un solo rol',
  height_cm      SMALLINT UNSIGNED NOT NULL,
  weight_kg      SMALLINT UNSIGNED NOT NULL,
  description    VARCHAR(1000) NOT NULL,
  greeting_text  VARCHAR(120) NOT NULL,
  greeting_id    INT UNSIGNED NULL COMMENT 'NULL si lo escribió el usuario',
  main_photo_id  BIGINT UNSIGNED NULL,
  is_published   TINYINT(1)   NOT NULL DEFAULT 0,
  show_online    TINYINT(1)   NOT NULL DEFAULT 1,
  show_in_radar  TINYINT(1)   NOT NULL DEFAULT 1,
  review_count   INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'agregado de las últimas 30 visibles',
  review_avg     DECIMAL(3,2) NULL,
  last_seen_at   DATETIME(3)  NULL,
  published_at   DATETIME(3)  NULL,
  updated_at     DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_profiles_username (username),
  KEY idx_profiles_published (is_published, last_seen_at),
  CONSTRAINT chk_profiles_height CHECK (height_cm BETWEEN 120 AND 230),
  CONSTRAINT chk_profiles_weight CHECK (weight_kg BETWEEN 35 AND 250),
  CONSTRAINT fk_profile_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_profile_role FOREIGN KEY (own_role_id) REFERENCES available_roles(id),
  CONSTRAINT fk_profile_greeting FOREIGN KEY (greeting_id) REFERENCES greetings(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_photos (
  id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id           BIGINT UNSIGNED NOT NULL,
  kind              ENUM('main','gallery') NOT NULL,
  status            ENUM('pending_review','approved','rejected') NOT NULL DEFAULT 'pending_review',
  storage_key       VARCHAR(128) NOT NULL COMMENT 'hash único; las variantes se derivan',
  width             SMALLINT UNSIGNED NOT NULL,
  height            SMALLINT UNSIGNED NOT NULL,
  position          TINYINT UNSIGNED NOT NULL DEFAULT 0,
  is_hidden         TINYINT(1)   NOT NULL DEFAULT 0 COMMENT 'oculta por exceder el límite del plan',
  moderation_score  DECIMAL(5,4) NULL,
  created_at        DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  KEY idx_photos_user (user_id, status, kind, position),
  KEY idx_photos_review (status, created_at),
  CONSTRAINT fk_photo_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_interests (
  user_id     BIGINT UNSIGNED NOT NULL,
  interest_id INT UNSIGNED    NOT NULL,
  PRIMARY KEY (user_id, interest_id),
  KEY idx_ui_interest (interest_id),
  CONSTRAINT fk_ui_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_ui_interest FOREIGN KEY (interest_id) REFERENCES interests(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Roles que el usuario BUSCA (uno o varios)
CREATE TABLE user_roles (
  user_id BIGINT UNSIGNED   NOT NULL,
  role_id SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, role_id),
  KEY idx_ur_role (role_id),
  CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES available_roles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_preferences (
  user_id             BIGINT UNSIGNED NOT NULL PRIMARY KEY,
  notify_messages     TINYINT(1) NOT NULL DEFAULT 1,
  notify_interactions TINYINT(1) NOT NULL DEFAULT 1,
  notify_reviews      TINYINT(1) NOT NULL DEFAULT 1,
  notify_promotions   TINYINT(1) NOT NULL DEFAULT 0,
  radar_radius_km     SMALLINT UNSIGNED NOT NULL DEFAULT 2,
  explore_filters     JSON       NULL,
  updated_at          DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_pref_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ubicación PRIVADA: nunca se expone por la API
CREATE TABLE user_locations (
  user_id    BIGINT UNSIGNED NOT NULL PRIMARY KEY,
  lat        DECIMAL(9,6) NOT NULL,
  lng        DECIMAL(9,6) NOT NULL,
  geohash6   CHAR(6)      NOT NULL COMMENT 'celda ~1 km usada para ofuscar',
  region_id  INT UNSIGNED NULL COMMENT 'para segmentación de anuncios',
  updated_at DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  KEY idx_loc_latlng (lat, lng),
  KEY idx_loc_geohash (geohash6),
  KEY idx_loc_region (region_id),
  CONSTRAINT fk_loc_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_loc_region FOREIGN KEY (region_id) REFERENCES regions(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Planes, permisos y suscripciones
-- ---------------------------------------------------------------------

CREATE TABLE plans (
  id                 SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code               VARCHAR(32)  NOT NULL UNIQUE,
  name               VARCHAR(64)  NOT NULL,
  is_default         TINYINT(1)   NOT NULL DEFAULT 0,
  is_active          TINYINT(1)   NOT NULL DEFAULT 1,
  price_monthly_mxn  DECIMAL(10,2) NULL COMMENT 'precio de referencia / Mercado Pago',
  price_yearly_mxn   DECIMAL(10,2) NULL,
  store_product_ids  JSON         NULL COMMENT 'ids de producto en App Store, Google Play y AppGallery',
  updated_at         DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE plan_permissions (
  plan_id    SMALLINT UNSIGNED NOT NULL,
  perm_key   VARCHAR(64)  NOT NULL,
  perm_value VARCHAR(255) NOT NULL,
  value_type ENUM('int','bool','string') NOT NULL,
  PRIMARY KEY (plan_id, perm_key),
  CONSTRAINT fk_pp_plan FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE subscriptions (
  id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id             BIGINT UNSIGNED NOT NULL,
  plan_id             SMALLINT UNSIGNED NOT NULL,
  period              ENUM('monthly','yearly') NOT NULL,
  provider            ENUM('apple','google','huawei','mercadopago','manual') NOT NULL,
  provider_ref        VARCHAR(255) NULL COMMENT 'originalTransactionId, purchaseToken, preapproval id…',
  status              ENUM('active','grace','cancelled','expired','refunded') NOT NULL,
  started_at          DATETIME(3)  NOT NULL,
  current_period_end  DATETIME(3)  NOT NULL,
  auto_renew          TINYINT(1)   NOT NULL DEFAULT 1,
  cancelled_at        DATETIME(3)  NULL,
  created_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at          DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_sub_provider (provider, provider_ref),
  KEY idx_sub_user (user_id, status, current_period_end),
  KEY idx_sub_expiry (status, current_period_end),
  CONSTRAINT fk_sub_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_sub_plan FOREIGN KEY (plan_id) REFERENCES plans(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE payments (
  id                      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id                 BIGINT UNSIGNED NULL,
  advertiser_id           BIGINT UNSIGNED NULL,
  subscription_id         BIGINT UNSIGNED NULL,
  campaign_id             BIGINT UNSIGNED NULL,
  provider                ENUM('apple','google','huawei','mercadopago','manual') NOT NULL,
  provider_transaction_id VARCHAR(255) NOT NULL,
  amount                  DECIMAL(12,2) NOT NULL,
  currency                CHAR(3)      NOT NULL DEFAULT 'MXN',
  status                  ENUM('pending','approved','rejected','refunded') NOT NULL,
  raw_payload             JSON         NULL,
  created_at              DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_payment_tx (provider, provider_transaction_id),
  KEY idx_pay_user (user_id, created_at),
  KEY idx_pay_adv (advertiser_id, created_at),
  KEY idx_pay_date (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Contadores diarios atómicos (fecha en la zona horaria del servicio)
CREATE TABLE daily_usage (
  user_id          BIGINT UNSIGNED NOT NULL,
  usage_date       DATE            NOT NULL,
  reviews_count    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  ai_regenerations SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, usage_date),
  CONSTRAINT fk_usage_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Interacciones, favoritos, bloqueos, reseñas
-- ---------------------------------------------------------------------

CREATE TABLE profile_interactions (
  actor_user_id  BIGINT UNSIGNED NOT NULL,
  target_user_id BIGINT UNSIGNED NOT NULL,
  type           ENUM('up','down') NOT NULL COMMENT 'una fila por par; cambiar de opinión actualiza',
  created_at     DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at     DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (actor_user_id, target_user_id),
  KEY idx_pi_target (target_user_id, type),
  CONSTRAINT fk_pi_actor FOREIGN KEY (actor_user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_pi_target FOREIGN KEY (target_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE favorites (
  user_id        BIGINT UNSIGNED NOT NULL,
  target_user_id BIGINT UNSIGNED NOT NULL,
  created_at     DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (user_id, target_user_id),
  KEY idx_fav_list (user_id, created_at),
  CONSTRAINT fk_fav_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_fav_target FOREIGN KEY (target_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE blocks (
  blocker_user_id BIGINT UNSIGNED NOT NULL,
  blocked_user_id BIGINT UNSIGNED NOT NULL,
  created_at      DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (blocker_user_id, blocked_user_id),
  KEY idx_blocks_blocked (blocked_user_id),
  CONSTRAINT fk_blk_blocker FOREIGN KEY (blocker_user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_blk_blocked FOREIGN KEY (blocked_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sin restricción única (reviewer, reviewed): la regla de las últimas 30
-- permite varias reseñas históricas del mismo autor al mismo perfil.
CREATE TABLE reviews (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  reviewer_user_id BIGINT UNSIGNED NULL COMMENT 'se conserva aunque sea anónima; NULL si el autor borró su cuenta',
  reviewed_user_id BIGINT UNSIGNED NOT NULL,
  rating           TINYINT UNSIGNED NOT NULL,
  comment          VARCHAR(1000) NOT NULL,
  is_anonymous     TINYINT(1)    NOT NULL DEFAULT 0,
  reviewer_deleted TINYINT(1)    NOT NULL DEFAULT 0 COMMENT 'mostrar «Usuario eliminado»',
  status           ENUM('visible','hidden') NOT NULL DEFAULT 'visible' COMMENT 'hidden = ocultada por moderación',
  created_at       DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at       DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5),
  KEY idx_reviews_received (reviewed_user_id, status, created_at, id),
  KEY idx_reviews_pair (reviewer_user_id, reviewed_user_id, created_at),
  CONSTRAINT fk_rev_reviewer FOREIGN KEY (reviewer_user_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_rev_reviewed FOREIGN KEY (reviewed_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE reports (
  id                   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  reporter_user_id     BIGINT UNSIGNED NULL,
  target_type          ENUM('user','photo','message','review','ad') NOT NULL,
  target_id            BIGINT UNSIGNED NOT NULL,
  reason               ENUM('fake','minor','harassment','spam','nudity','violence','scam','other') NOT NULL,
  details              VARCHAR(1000) NULL,
  status               ENUM('open','in_review','resolved','dismissed') NOT NULL DEFAULT 'open',
  resolved_by_admin_id BIGINT UNSIGNED NULL,
  created_at           DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  resolved_at          DATETIME(3) NULL,
  KEY idx_reports_queue (status, created_at),
  KEY idx_reports_target (target_type, target_id),
  CONSTRAINT fk_rep_reporter FOREIGN KEY (reporter_user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Mensajería
-- ---------------------------------------------------------------------

CREATE TABLE conversations (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  pair_key        VARCHAR(41)  NOT NULL COMMENT '"<id menor>:<id mayor>" — una conversación por pareja',
  last_message_id BIGINT UNSIGNED NULL,
  last_message_at DATETIME(3)  NULL,
  created_at      DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_conv_pair (pair_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE conversation_members (
  conversation_id      BIGINT UNSIGNED NOT NULL,
  user_id              BIGINT UNSIGNED NOT NULL,
  last_read_message_id BIGINT UNSIGNED NULL,
  unread_count         INT UNSIGNED NOT NULL DEFAULT 0,
  last_message_at      DATETIME(3)  NULL COMMENT 'copia para ordenar la bandeja sin JOIN',
  is_archived          TINYINT(1)   NOT NULL DEFAULT 0,
  is_muted             TINYINT(1)   NOT NULL DEFAULT 0,
  PRIMARY KEY (conversation_id, user_id),
  KEY idx_cm_inbox (user_id, is_archived, last_message_at),
  CONSTRAINT fk_cm_conv FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
  CONSTRAINT fk_cm_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE messages (
  id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  conversation_id   BIGINT UNSIGNED NOT NULL,
  sender_user_id    BIGINT UNSIGNED NULL,
  client_message_id CHAR(36)     NOT NULL COMMENT 'UUID de la app; evita duplicados al reintentar',
  type              ENUM('text','image','video','voice','sticker') NOT NULL DEFAULT 'text',
  body              TEXT         NULL,
  media_key         VARCHAR(128) NULL,
  created_at        DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  deleted_at        DATETIME(3)  NULL,
  KEY idx_msg_conv (conversation_id, id),
  KEY idx_msg_sender (conversation_id, sender_user_id),
  UNIQUE KEY uq_msg_client (sender_user_id, client_message_id),
  CONSTRAINT fk_msg_conv FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
  CONSTRAINT fk_msg_sender FOREIGN KEY (sender_user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notifications (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id    BIGINT UNSIGNED NOT NULL,
  type       ENUM('message','interaction','review','admin','promotion') NOT NULL,
  title      VARCHAR(120) NOT NULL,
  body       VARCHAR(255) NOT NULL,
  data       JSON         NULL,
  read_at    DATETIME(3)  NULL,
  created_at DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  KEY idx_notif_user (user_id, created_at),
  CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Publicidad
-- ---------------------------------------------------------------------

CREATE TABLE advertisers (
  id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  email          VARCHAR(254) NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  contact_name   VARCHAR(120) NOT NULL,
  phone          VARCHAR(20)  NULL,
  company_name   VARCHAR(160) NULL,
  legal_name     VARCHAR(200) NULL,
  rfc            VARCHAR(13)  NULL,
  tax_address    VARCHAR(255) NULL,
  status         ENUM('pending','active','suspended') NOT NULL DEFAULT 'pending',
  email_verified_at DATETIME(3) NULL,
  created_at     DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at     DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_adv_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ad_slots (
  id          SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code        VARCHAR(32)  NOT NULL UNIQUE,
  name        VARCHAR(80)  NOT NULL,
  type        ENUM('banner','sponsored_profile','explore_card') NOT NULL,
  image_specs VARCHAR(120) NULL COMMENT 'ej. 1080x300 WebP/JPG ≤ 300 KB',
  is_active   TINYINT(1)   NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ad_slot_pricing (
  slot_id       SMALLINT UNSIGNED NOT NULL,
  billing_model ENUM('per_day','cpm','cpc') NOT NULL,
  price_mxn     DECIMAL(10,2) NOT NULL COMMENT 'por día, por 1,000 impresiones o por clic',
  is_active     TINYINT(1)    NOT NULL DEFAULT 1,
  PRIMARY KEY (slot_id, billing_model),
  CONSTRAINT fk_asp_slot FOREIGN KEY (slot_id) REFERENCES ad_slots(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE advertising_campaigns (
  id                   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  advertiser_id        BIGINT UNSIGNED NOT NULL,
  slot_id              SMALLINT UNSIGNED NOT NULL,
  name                 VARCHAR(120) NOT NULL,
  billing_model        ENUM('per_day','cpm','cpc') NOT NULL,
  unit_price_mxn       DECIMAL(10,2) NOT NULL COMMENT 'precio congelado al contratar',
  budget_mxn           DECIMAL(12,2) NOT NULL,
  spent_mxn            DECIMAL(12,2) NOT NULL DEFAULT 0,
  starts_on            DATE         NOT NULL,
  ends_on              DATE         NOT NULL,
  status               ENUM('draft','pending_payment','pending_approval','approved','rejected','active','paused','finished') NOT NULL DEFAULT 'draft',
  rejection_reason     VARCHAR(255) NULL,
  approved_by_admin_id BIGINT UNSIGNED NULL,
  approved_at          DATETIME(3)  NULL,
  paid_at              DATETIME(3)  NULL,
  created_at           DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at           DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT chk_campaign_dates CHECK (ends_on >= starts_on),
  KEY idx_camp_adv (advertiser_id, created_at),
  KEY idx_camp_serving (status, slot_id, starts_on, ends_on),
  CONSTRAINT fk_camp_adv FOREIGN KEY (advertiser_id) REFERENCES advertisers(id),
  CONSTRAINT fk_camp_slot FOREIGN KEY (slot_id) REFERENCES ad_slots(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE campaign_regions (
  campaign_id BIGINT UNSIGNED NOT NULL,
  region_id   INT UNSIGNED    NOT NULL,
  PRIMARY KEY (campaign_id, region_id),
  KEY idx_cr_region (region_id),
  CONSTRAINT fk_cr_campaign FOREIGN KEY (campaign_id) REFERENCES advertising_campaigns(id) ON DELETE CASCADE,
  CONSTRAINT fk_cr_region FOREIGN KEY (region_id) REFERENCES regions(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE advertisements (
  id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  campaign_id       BIGINT UNSIGNED NOT NULL,
  title             VARCHAR(80)  NOT NULL,
  body              VARCHAR(160) NULL,
  image_key         VARCHAR(128) NOT NULL,
  target_url        VARCHAR(500) NULL,
  sponsored_user_id BIGINT UNSIGNED NULL COMMENT 'para perfiles patrocinados',
  status            ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  created_at        DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  KEY idx_ads_campaign (campaign_id, status),
  CONSTRAINT fk_ads_campaign FOREIGN KEY (campaign_id) REFERENCES advertising_campaigns(id) ON DELETE CASCADE,
  CONSTRAINT fk_ads_sponsored FOREIGN KEY (sponsored_user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Eventos crudos (se reciben en lotes); se agregan a ad_daily_stats y se purgan a los 90 días
CREATE TABLE ad_impressions (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  advertisement_id BIGINT UNSIGNED NOT NULL,
  campaign_id      BIGINT UNSIGNED NOT NULL,
  user_id          BIGINT UNSIGNED NULL,
  region_id        INT UNSIGNED    NULL,
  occurred_at      DATETIME(3)     NOT NULL,
  KEY idx_imp_campaign (campaign_id, occurred_at),
  KEY idx_imp_dedupe (advertisement_id, user_id, occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ad_clicks (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  advertisement_id BIGINT UNSIGNED NOT NULL,
  campaign_id      BIGINT UNSIGNED NOT NULL,
  user_id          BIGINT UNSIGNED NULL,
  region_id        INT UNSIGNED    NULL,
  occurred_at      DATETIME(3)     NOT NULL,
  KEY idx_clk_campaign (campaign_id, occurred_at),
  KEY idx_clk_dedupe (advertisement_id, user_id, occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ad_daily_stats (
  campaign_id BIGINT UNSIGNED NOT NULL,
  stat_date   DATE            NOT NULL,
  impressions INT UNSIGNED    NOT NULL DEFAULT 0,
  clicks      INT UNSIGNED    NOT NULL DEFAULT 0,
  cost_mxn    DECIMAL(12,2)   NOT NULL DEFAULT 0,
  PRIMARY KEY (campaign_id, stat_date),
  CONSTRAINT fk_ads_stats_campaign FOREIGN KEY (campaign_id) REFERENCES advertising_campaigns(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Administración, moderación y auditoría
-- ---------------------------------------------------------------------

CREATE TABLE admin_users (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  email         VARCHAR(254) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name          VARCHAR(120) NOT NULL,
  role          ENUM('superadmin','moderator','ads_manager','viewer') NOT NULL,
  totp_secret   VARCHAR(64)  NULL COMMENT 'segundo factor',
  status        ENUM('active','disabled') NOT NULL DEFAULT 'active',
  last_login_at DATETIME(3)  NULL,
  created_at    DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_admin_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE moderation_actions (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  target_type   ENUM('user','photo','message','review','ad','campaign') NOT NULL,
  target_id     BIGINT UNSIGNED NOT NULL,
  action        ENUM('approve','reject','hide','restore','suspend_user','reactivate_user','delete_account') NOT NULL,
  source        ENUM('auto','admin') NOT NULL,
  admin_user_id BIGINT UNSIGNED NULL,
  report_id     BIGINT UNSIGNED NULL,
  reason        VARCHAR(255) NULL,
  score         DECIMAL(5,4) NULL COMMENT 'resultado del moderador automático',
  created_at    DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  KEY idx_mod_target (target_type, target_id),
  KEY idx_mod_date (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE appeals (
  id                   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id              BIGINT UNSIGNED NOT NULL,
  moderation_action_id BIGINT UNSIGNED NOT NULL,
  message              VARCHAR(1000) NOT NULL,
  status               ENUM('open','accepted','rejected') NOT NULL DEFAULT 'open',
  resolved_by_admin_id BIGINT UNSIGNED NULL,
  created_at           DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  resolved_at          DATETIME(3) NULL,
  KEY idx_appeals_queue (status, created_at),
  CONSTRAINT fk_appeal_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_appeal_action FOREIGN KEY (moderation_action_id) REFERENCES moderation_actions(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE audit_logs (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  actor_type  ENUM('admin','advertiser','user','system') NOT NULL,
  actor_id    BIGINT UNSIGNED NULL,
  action      VARCHAR(64)  NOT NULL,
  entity_type VARCHAR(64)  NULL,
  entity_id   BIGINT UNSIGNED NULL,
  data        JSON         NULL,
  ip          VARCHAR(45)  NULL,
  created_at  DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  KEY idx_audit_actor (actor_type, actor_id, created_at),
  KEY idx_audit_entity (entity_type, entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Agregados diarios para el panel de estadísticas (los calcula el cron)
CREATE TABLE stats_daily (
  stat_date DATE        NOT NULL,
  metric    VARCHAR(48) NOT NULL COMMENT 'registered_users, dau, mau, premium_users, new_subscriptions, cancellations, revenue_mxn, messages, profile_views, reviews_created, ad_impressions, ad_clicks',
  value     DECIMAL(14,2) NOT NULL,
  PRIMARY KEY (stat_date, metric)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET foreign_key_checks = 1;
