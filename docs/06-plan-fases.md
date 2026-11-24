# 06. Plan por fases

Cada fase termina con algo que se puede probar. Las fases 3–5 se trabajan módulo por módulo (backend → app → panel) para tener funciones completas de punta a punta lo antes posible.

| Fase | Entregable | Requiere del dueño |
|---|---|---|
| **1. Análisis y arquitectura** ✅ | Este conjunto de documentos, `schema.sql`, `seed.sql` | — |
| **2. Diseño de interfaz** | Tema y componentes en Flutter; prototipo navegable de onboarding y 4 pestañas con datos de prueba | Logo provisional (opcional) |
| **3a. Backend base** | Proyecto NestJS/Fastify, config, permisos, auth (correo), onboarding, perfiles, fotos, catálogos, `GET /config`; despliegue en Hostinger | App Node.js + base MySQL en Hostinger, SMTP |
| **3b. App: registro y onboarding** | Flujo completo conectado al backend real | Mac con Flutter/Xcode/Android Studio |
| **4a. Explorar, detalle, radar** | Cercanos, difuminado, filtros, manitas, favoritos, bloqueo, reporte, mapa | Opción de mapas |
| **4b. Mensajería** | Chat con Ably + respaldo, push | Firebase, APNs, Ably |
| **4c. Reseñas** | Regla de 30, límite diario, anonimato | — |
| **4d. Premium** | Compras en tiendas + Mercado Pago, webhooks, permisos por plan | Productos en tiendas, Mercado Pago |
| **4e. Google / Apple sign-in, IA y moderación** | Inicio de sesión social, descripción con IA, moderación automática | Bundle ID definitivo, claves de IA y Sightengine |
| **5a. Panel administrativo** | Usuarios, moderación, planes, catálogos, estadísticas | — |
| **5b. Portal de anunciantes + publicidad en la app** | Campañas, modelos de cobro, aprobación, estadísticas, reportes | Mercado Pago |
| **6. Pruebas** | Unitarias, integración, API, seguridad, carga (500/150), límites por plan, reseñas, ubicación, cambio de marca | Dispositivos iOS/Android de prueba |
| **7. Publicación** | Fichas de tiendas, certificados, monitoreo, documentación de despliegue | Nombre definitivo, textos legales revisados, cuenta AppGallery |

## Orden de las siguientes sesiones
1. Fase 2 + 3a en paralelo: esqueleto de `api/` y `mobile/` con tema, config de marca y auth.
2. Onboarding de punta a punta (es el módulo más importante).
3. Explorar → Radar → Mensajes → Reseñas → Premium.
4. Panel → Portal de anunciantes.
