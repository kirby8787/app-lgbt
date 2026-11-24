# app-lgbt

App de encuentros y conexiones entre hombres (iOS, Android y Huawei), con backend, panel administrativo y portal de anunciantes.

> **El nombre comercial NO está decidido.** En el código se usa siempre la configuración de marca (`{{APP_NAME}}`). Ver [docs/01-arquitectura.md](docs/01-arquitectura.md#2-configuración-de-marca).

## Estructura

| Carpeta | Qué es | Tecnología |
|---|---|---|
| `mobile/` | App para iOS, Android y Huawei | Flutter |
| `api/` | Backend (API REST) | NestJS + Fastify, MySQL |
| `api/database/` | Esquema y migraciones | SQL (MySQL 8 / MariaDB) |
| `admin/` | Panel administrativo | Web estática (Vite + React) |
| `ads-portal/` | Portal de anunciantes | Web estática (Vite + React) |
| `seeds/` | Datos iniciales (saludos, intereses, roles) | CSV |
| `docs/` | Requisitos y diseño | Markdown |

## Documentación

0. [Prompt maestro (fuente de verdad de requisitos)](docs/00-prompt-maestro.md)
1. [Arquitectura](docs/01-arquitectura.md)
2. [Modelo de datos](docs/02-modelo-datos.md) · [schema.sql](api/database/schema.sql)
3. [API](docs/03-api.md)
4. [Pantallas y navegación](docs/04-pantallas.md)
5. [Servicios externos y costos](docs/05-servicios-externos.md)
6. [Plan por fases](docs/06-plan-fases.md)
7. [Pendientes y decisiones abiertas](docs/07-pendientes.md)

## Estado

Fase 1 (análisis y arquitectura): en curso.
