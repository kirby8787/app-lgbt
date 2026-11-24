# 04. Pantallas y navegación (app móvil)

## Flujo principal

```
Bienvenida ─┬─ Crear cuenta ── Verificar correo ─┐
            ├─ Iniciar sesión ───────────────────┤
            ├─ Google / Apple ───────────────────┤
            └─ Recuperar contraseña → Restablecer│
                                                 ▼
                  ¿perfil publicado? ── no ──▶ Onboarding (9 pasos) ──▶ «¡Perfil creado!»
                          │ sí                                               │
                          ▼                                                  ▼
            ┌──────────────────── Pestañas ─────────────────────────────────┐
            │ Explorar │ Radar │ Mensajes │ Mi perfil                        │
            └──────────────────────────────────────────────────────────────┘
```

## Onboarding (cada paso: progreso, Atrás, Siguiente, validación, borrador guardado)
1. Tu identidad — nombre, username (disponibilidad en vivo).
2. Tu información — fecha de nacimiento (bloquea < 18), rol (uno), estatura, peso.
3. Tu foto de perfil — galería/cámara, recorte, vista previa.
4. Descríbete en una imagen — «Esta imagen NO será publicada».
5. Tu descripción — editar, aceptar, regenerar (límite por día), escribir desde cero.
6. Invita a los demás a conocerte — 5 saludos (uno por nivel) + «Ver otros» + escribir el tuyo.
7. Tus intereses — etiquetas, búsqueda, crear propias.
8. Roles que buscas — uno o varios.
9. Revisar y crear perfil — resumen con «Editar» por sección → «Crear perfil».

## Pestañas
| Pestaña | Pantallas |
|---|---|
| **Explorar** | Cuadrícula (visibles + difuminadas → hoja «Hazte Premium») · Filtros (avanzados con candado) · Banner/tarjeta de anuncio (solo gratuito) · Detalle de perfil (galería, datos, manitas, mensaje, favoritos, reseñas si Premium, bloquear/reportar) · Escribir reseña |
| **Radar** | Mapa con marcadores · selector de radio (tope del plan) · interruptor «Visible en el radar» · sin ubicación → aviso y acceso a ajustes |
| **Mensajes** | Bandeja · Conversación · Bloquear/reportar desde el chat |
| **Mi perfil** | Ver/editar perfil y galería · Favoritos · Mis reseñas (Premium) · Premium (planes, comprar, restaurar) · Notificaciones · Privacidad (en línea, radar) · Idioma · Términos y privacidad · Cerrar sesión · Eliminar cuenta |

## Componentes reutilizables
Tarjeta de perfil (normal / difuminada / patrocinada), botón primario/secundario, campo validado, selector de etiquetas, indicador de pasos, hoja de Premium, burbuja de chat, marcador de radar, estado vacío, estado de error con reintentar, esqueleto de carga.

## Reglas de UX para velocidad
- Esqueletos de carga en lugar de pantallas en blanco; mostrar caché primero y actualizar después.
- Miniaturas en cuadrícula y radar; foto mediana en detalle; completa solo al ampliar.
- Precargar la siguiente página de Explorar al llegar al 70 % del desplazamiento.
- Animaciones discretas (≤ 200 ms).
