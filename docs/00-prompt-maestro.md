# PROMPT MAESTRO – {{APP_NAME}}
## Desarrollo de aplicación móvil de encuentros y conexiones entre hombres

Actúa como un equipo senior de desarrollo de software especializado en aplicaciones sociales, geolocalización, mensajería en tiempo real, inteligencia artificial, sistemas de suscripción y plataformas SaaS.

Tu objetivo es diseñar y desarrollar una aplicación llamada **{{APP_NAME}}**, una plataforma de encuentros y conexiones entre hombres, inspirada funcionalmente en aplicaciones como Grindr, pero con identidad visual, arquitectura, código y experiencia de usuario propios.

No quiero únicamente un prototipo visual. Necesito desarrollar una aplicación funcional, escalable, segura y preparada para publicarse comercialmente.

> **NOTA SOBRE EL NOMBRE:** `{{APP_NAME}}` es un marcador. El nombre definitivo de la aplicación AÚN NO está decidido. Nunca escribas el nombre de la app directamente en el código, en nombres de carpetas, paquetes, tablas, clases ni variables. Toda referencia al nombre, logotipo, colores, dominio y correos debe salir de la configuración de marca descrita en la sección 0.

---

# 0. CONFIGURACIÓN DE MARCA (NOMBRE CAMBIABLE)

El nombre, el logotipo y la paleta de colores cambiarán antes del lanzamiento, y podrían cambiar después. El sistema debe permitir cambiarlos sin reescribir código.

## 0.1 Identificadores técnicos neutros

Usar identificadores técnicos que NO contengan el nombre comercial, porque algunos no se pueden cambiar una vez publicada la app:

- Bundle ID de iOS y applicationId de Android: neutros y definitivos desde el inicio (ejemplo: `mx.expansionmexico.citas`). **Estos no se pueden cambiar después de publicar en las tiendas**, por eso no deben llevar el nombre comercial.
- Nombre del repositorio, paquetes de Dart, módulos de NestJS, base de datos y tablas: nombres genéricos (`app`, `api`, `admin`, `ads`), nunca el nombre comercial.

## 0.2 Archivo único de marca

Crear un único origen de verdad para la marca:

**En la app móvil (Flutter):**
- Un archivo `brand_config` (o variables de compilación `--dart-define` / flavors) con: nombre visible, logotipo, ícono, colores, tipografía, URL de términos y privacidad, correo de soporte.
- El nombre visible bajo el ícono (`CFBundleDisplayName` en iOS, `android:label` en Android) se toma de esa configuración en la compilación.
- Todos los textos que mencionen el nombre usan una variable (ejemplo: `«Bienvenido a {appName}»`) dentro de los archivos de traducción.
- Los colores se definen como tokens de tema (primario, secundario, fondo, superficie, texto, error); ninguna pantalla usa colores fijos.

**En el backend:**
- Tabla `app_settings` (clave/valor) con: `app_name`, `support_email`, `logo_url`, `primary_color`, `secondary_color`, `terms_url`, `privacy_url`.
- Endpoint público y cacheable `GET /config` que la app consulta al iniciar, para que textos y enlaces se actualicen sin publicar una nueva versión.
- Correos transaccionales, notificaciones push, panel administrativo y portal de anunciantes toman el nombre y el logotipo de esa tabla.

## 0.3 Qué exige cambiar el nombre

Documentar en el README la lista exacta de pasos para cambiar la marca:
1. Cambiar valores en `app_settings` (inmediato, sin publicar).
2. Cambiar `brand_config`, ícono y pantalla de carga, y recompilar (requiere nueva versión en las tiendas).
3. Cambiar la ficha en App Store, Google Play y AppGallery.
4. Dominio y correos, si aplica.

---

# 1. OBJETIVO DEL PROYECTO

Desarrollar una aplicación móvil multiplataforma para:

- iOS (App Store).
- Android (Google Play).
- Huawei (AppGallery), en teléfonos sin servicios de Google.

Por compatibilidad con Huawei, la app no debe depender de Google Play Services para funcionar: mapas, notificaciones, inicio de sesión y pagos deben tener una alternativa en dispositivos Huawei (ver secciones 7, 11, 15 y 17).

Mercado inicial: México. Idiomas: español e inglés (todos los textos en archivos de traducción desde el día uno).

La aplicación permitirá a los usuarios:
- Registrarse y crear su perfil.
- Descubrir hombres cercanos.
- Explorar perfiles de otros usuarios.
- Consultar personas mediante un radar geográfico.
- Enviar y recibir mensajes.
- Dar manitas arriba o abajo a otros perfiles.
- Consultar y generar reseñas.
- Personalizar su información y preferencias.
- Contratar una suscripción Premium.

El modelo comercial será Freemium:

**Versión gratuita:**
- Acceso a funcionalidades básicas.
- Límites de exploración.
- Publicidad comercial contratada directamente por anunciantes.

**Versión Premium:**
- Mayor cantidad de perfiles disponibles.
- Filtros avanzados.
- Sistema de reseñas.
- Funcionalidades adicionales que se definirán durante el desarrollo.

---

# 2. IDENTIDAD VISUAL Y DISEÑO

Nombre: {{APP_NAME}} (provisional, configurable según la sección 0).

Estilo visual inicial (los colores son tokens configurables, no valores fijos):
- Interfaz oscura.
- Fondo negro y gris carbón.
- Color principal: configurable (inicial: azul eléctrico).
- Color secundario: configurable (inicial: por definir, derivado del azul eléctrico).
- Botones redondeados.
- Tarjetas de perfiles con fotografías.
- Iconografía moderna.
- Animaciones discretas.
- Diseño minimalista y atractivo.

La aplicación debe sentirse moderna, rápida y sencilla.

Tomar como referencia conceptual la experiencia de navegación de Grindr, sin copiar su marca, logotipo, recursos gráficos ni código.

Todas las pantallas deben diseñarse para dispositivos iOS y Android, adaptándose a diferentes resoluciones.

La navegación principal tendrá cuatro pestañas:

1. Explorar.
2. Radar.
3. Mensajes.
4. Mi perfil.

---

# 3. REGISTRO Y AUTENTICACIÓN

Los usuarios podrán registrarse exclusivamente mediante:

- Correo electrónico y contraseña.
- Cuenta de Google.
- Cuenta de Apple.

No implementar registro mediante número telefónico.

Pantallas necesarias:

1. Pantalla de bienvenida.
2. Crear cuenta.
3. Iniciar sesión.
4. Recuperar contraseña.
5. Restablecer contraseña.
6. Verificación de correo electrónico.
7. Cierre de sesión.
8. Eliminación de cuenta.

El sistema deberá gestionar sesiones de manera segura y permitir recuperar el acceso a la cuenta.

Verificación de correo obligatoria: quien se registre con correo y contraseña debe confirmar su correo (enlace o código de 6 dígitos, con reenvío limitado) antes de entrar al onboarding del perfil. Las cuentas de Google y Apple se consideran verificadas.

En iOS y Android deben implementarse correctamente los mecanismos de autenticación de Google y Apple.

En dispositivos Huawei sin servicios de Google, ocultar el botón de Google y ofrecer correo y Apple (Apple funciona vía web). Detectar la disponibilidad de servicios en tiempo de ejecución.

Sesiones ligeras: token de acceso JWT de vida corta (15 min) + token de renovación guardado en almacenamiento seguro del dispositivo. Validar el JWT sin consultar la base de datos en cada petición.

---

# 4. CREACIÓN DEL PERFIL – ONBOARDING

Este es uno de los módulos más importantes de la aplicación.

El registro de perfil debe realizarse mediante un asistente de varias pantallas.

Todas las pantallas tendrán:
- Indicador de progreso.
- Botón Siguiente.
- Botón Atrás.
- Validación de campos.
- Conservación automática de los datos durante el proceso.

El usuario podrá regresar a cualquier pantalla anterior sin perder información.

**IMPORTANTE:** El perfil no se publicará ni se considerará creado hasta que el usuario presione el botón final «Crear perfil».

Todos los campos del onboarding serán obligatorios.

## Paso 1. Tu identidad

Solicitar:

- Nombre.
- Nombre de usuario.

El nombre de usuario debe ser único dentro de la plataforma.

Validar disponibilidad en tiempo real y evitar duplicados.

## Paso 2. Tu información

Solicitar:

- Fecha de nacimiento.
- Rol.
- Estatura.
- Peso.

La fecha de nacimiento será obligatoria.

**Restricción de edad:**

La aplicación es exclusivamente para mayores de 18 años.

Si la fecha de nacimiento indica que el usuario es menor de edad:
- No permitir continuar.
- No permitir crear el perfil.
- Mostrar un mensaje indicando que debe ser mayor de 18 años.

No utilizar una simple casilla de confirmación de mayoría de edad como sustituto de la validación de fecha de nacimiento.

Los roles iniciales serán:

- Activo.
- Pasivo.
- Versátil.

El usuario selecciona un solo rol (selección única, obligatoria). Si se identifica con ambos, elige Versátil. El catálogo de roles es administrable desde el backend.

## Paso 3. Tu foto de perfil

Solicitar una fotografía personal obligatoria.

Características:
- Subir desde la galería.
- Tomar una fotografía con la cámara.
- Recortar y ajustar.
- Mostrar vista previa.
- Permitir cambiarla antes de crear el perfil.

Esta será la fotografía principal que aparecerá en los resultados de exploración.

Galería: después de crear el perfil, el usuario podrá agregar más fotos a su galería desde «Mi perfil». El número máximo de fotos depende del plan y se configura desde el panel (`maximum_gallery_photos`; valores iniciales: 3 en gratuito, 10 en Premium). Si un usuario Premium vuelve a gratuito, sus fotos extra no se borran: quedan ocultas hasta que vuelva a Premium o elija cuáles mostrar. Todas las fotos pasan por moderación.

Implementar moderación de imágenes para impedir contenido ilegal, menores de edad y material no permitido.

Flujo de moderación (automática + revisión manual):
1. Al subir la foto, un servicio de moderación automática la clasifica en segundos.
2. Si es claramente aceptable, se publica de inmediato.
3. Si es claramente prohibida (desnudez explícita en foto pública, violencia, posible menor de edad), se rechaza y se avisa al usuario.
4. Si el resultado es dudoso, la foto queda «en revisión» (solo el dueño la ve) y entra a la cola del módulo Moderación del panel.
5. Los umbrales de aprobación y rechazo son configurables desde el panel.
6. Toda decisión (automática o manual) se guarda en moderation_actions.

## Paso 4. Descríbete en una imagen

Mostrar una pantalla con el título:

**«Descríbete en una imagen»**

Solicitar que el usuario suba una fotografía adicional de sí mismo.

La pantalla debe destacar claramente el mensaje:

**«Esta imagen NO será publicada».**

La fotografía se utilizará exclusivamente para generar una descripción personal mediante inteligencia artificial.

Funcionamiento:

1. El usuario selecciona una fotografía.
2. La aplicación envía temporalmente la imagen al servicio de inteligencia artificial.
3. La IA analiza los elementos visuales no sensibles y genera una descripción atractiva.
4. La descripción se entrega al usuario para que pueda revisarla.
5. La fotografía original se elimina después del procesamiento, incluyendo los archivos temporales controlados por el sistema.
6. No se incorpora a la galería pública ni al perfil.

No realizar reconocimiento facial ni inferir atributos sensibles de la persona.

La imagen temporal no debe utilizarse para entrenar modelos ni conservarse para otros fines.

## Paso 5. Tu descripción

Mostrar el texto generado por inteligencia artificial.

El usuario podrá:

- Editar libremente la descripción.
- Aceptar la descripción generada.
- Regenerar una descripción.
- Escribir una descripción desde cero.

La descripción tendrá un límite configurable de caracteres.

El texto debe tener un tono natural, atractivo y adecuado para conocer personas.

No debe inventar características físicas o personales que no estén sustentadas por la información proporcionada.

## Paso 6. Invita a los demás a conocerte

Esta debe ser una pantalla independiente.

Título:

**«Invita a los demás a conocerte».**

Subtítulo:

«Elige un saludo o escribe el tuyo para invitar a otros a conocerte».

Los saludos NO los genera la inteligencia artificial: salen de un catálogo administrable de 100 saludos (Anexo A), clasificados en 5 niveles de picardía con 20 saludos cada uno:

1. Pícaro.
2. Coqueto.
3. Juguetón.
4. Casual.
5. Amigable.

Funcionamiento:
- En cada perfil nuevo, la pantalla muestra 5 saludos al azar: exactamente 1 de cada nivel, ordenados del más pícaro al más amigable.
- El servidor elige los 5 al azar entre los saludos activos de cada nivel.
- Botón «Ver otros»: vuelve a sortear 5 saludos, uno por nivel.
- El catálogo (texto, nivel, idioma, activo) se administra desde el panel (Catálogos → Saludos sugeridos); se pueden agregar, editar o desactivar saludos y el sorteo se adapta solo.
- Los saludos del catálogo deben ser sugerentes pero nunca explícitos, para cumplir las reglas de App Store, Google Play y AppGallery.

El usuario tendrá dos alternativas:

1. Seleccionar uno de los cinco saludos.
2. Escribir un saludo completamente personalizado (límite de caracteres configurable, pasa por el filtro de moderación de texto).

Solo podrá seleccionar uno.

El saludo elegido aparecerá posteriormente en su perfil.

## Paso 7. Tus intereses

Mostrar una colección de etiquetas seleccionables.

Ejemplos iniciales:

- Cine.
- Teatro.
- Nintendo.
- Videojuegos.
- Música.
- Antro.
- Viajes.
- Gym.
- Lectura.
- Comida.
- Regalos.
- Mascotas.
- Series.
- Tecnología.
- Deportes.

El usuario podrá:
- Seleccionar varias etiquetas.
- Buscar etiquetas.
- Crear etiquetas personalizadas.
- Eliminar selecciones.

El catálogo de etiquetas debe ser administrable desde el backend.

## Paso 8. Roles que buscas

Mostrar los roles disponibles:

- Activo.
- Pasivo.
- Versátil.

El usuario podrá seleccionar uno o varios roles de interés.

Esta información se utilizará posteriormente para los filtros de búsqueda.

## Paso 9. Revisar y crear perfil

Mostrar un resumen de toda la información capturada:

- Nombre.
- Usuario.
- Fecha de nacimiento.
- Rol.
- Estatura.
- Peso.
- Fotografía.
- Descripción.
- Saludo.
- Intereses.
- Roles que busca.

Permitir editar cualquier sección regresando a su pantalla correspondiente.

Botón principal:

**«Crear perfil».**

Al presionarlo:
1. Validar todos los campos.
2. Guardar la información.
3. Crear el perfil.
4. Publicar el perfil en la plataforma.
5. Redirigir a la pantalla de confirmación.

Mostrar:

«¡Perfil creado! Comienza a conocer personas cerca de ti».

Botón:

«Explorar ahora».

---

# 5. MÓDULO DE EXPLORACIÓN DE PERFILES

Será la pantalla principal después de iniciar sesión.

Mostrar una cuadrícula de perfiles mediante tarjetas con:

- Fotografía.
- Nombre.
- Edad.
- Distancia aproximada.
- Indicador de conexión, cuando el usuario permita mostrarlo.

La interfaz debe permitir desplazarse verticalmente.

Los resultados dependerán del tipo de cuenta.

## Usuarios gratuitos

- Mostrar con foto visible los 30 perfiles más cercanos (el número 30 es configurable desde el panel: `maximum_visible_profiles`).
- La lista NO es fija por día: siempre son los 30 más cercanos en ese momento. Si el usuario se mueve o llegan personas nuevas, la lista se recalcula.
- Al seguir desplazándose, los perfiles posteriores se siguen mostrando en la cuadrícula, pero con la foto difuminada y sin acceso al detalle; al tocarlos se ofrece Premium.
- El difuminado debe hacerse en el servidor (enviar solo una miniatura ya difuminada de muy baja resolución, sin nombre ni datos), nunca solo con un efecto visual en la app, para que no se pueda saltar.
- Aplicar filtros básicos.

## Usuarios Premium

- Mostrar con foto visible los 300 perfiles más cercanos en ese momento (valor configurable: `maximum_visible_profiles` del plan Premium).
- Los perfiles posteriores se muestran difuminados, con la misma lógica del plan gratuito.
- Acceso a filtros avanzados.
- Mayor capacidad de personalización de resultados.

Los límites deberán validarse desde el backend y no únicamente desde la aplicación.

**Configurable:** los valores 30 (gratuito) y 300 (Premium) NO se escriben en el código. Cada plan tiene su propio `maximum_visible_profiles` en `plan_permissions`, editable desde el panel administrativo (módulo Planes). Un cambio en el panel debe aplicarse en la siguiente carga de Explorar, sin publicar una nueva versión de la app. El panel debe validar que el valor sea un entero positivo.

Los perfiles ya consultados deben administrarse correctamente para evitar inconsistencias y duplicados en una misma sesión de exploración.

El algoritmo de selección, ordenamiento y distribución de perfiles se desarrollará posteriormente. Debe quedar desacoplado para permitir modificaciones sin reconstruir toda la aplicación.

---

## Filtros

Filtros disponibles: edad, conectados ahora, rol, roles que busca, estatura, peso, intereses y distancia.

Cada filtro se marca como básico (gratuito) o avanzado (solo Premium) desde el panel administrativo, sin publicar una nueva versión. Valores iniciales: edad y conectados ahora son básicos; el resto son avanzados.

---

# 6. DETALLE DEL PERFIL DE OTRO USUARIO

Al seleccionar un perfil, abrir una pantalla de detalle.

Mostrar:

- Fotografía principal.
- Galería de fotografías.
- Nombre.
- Edad.
- Distancia aproximada.
- Estado de conexión, si está disponible.
- Descripción personal.
- Saludo.
- Rol.
- Estatura.
- Peso.
- Intereses.
- Roles que busca.
- Calificación promedio y reseñas, cuando corresponda.

Cada perfil tendrá tres acciones principales:

### Acción 1. Manita arriba

Permitir indicar que el perfil resulta interesante.

Guardar la interacción y evitar registros duplicados innecesarios.

### Acción 2. Manita abajo

Permitir indicar que el perfil no resulta interesante.

Registrar la interacción para que el sistema pueda utilizarla posteriormente en la personalización de resultados.

### Acción 3. Enviar mensaje

Abrir una conversación privada con el usuario.

### Reseñas

Cualquier perfil puede tener reseñas y calificaciones; solo los usuarios Premium pueden verlas.

Las reglas completas se especifican en el módulo de reseñas.

---

# 7. RADAR Y GEOLOCALIZACIÓN

Crear una pestaña independiente llamada Radar.

Mostrar un mapa interactivo con usuarios cercanos.

Cada usuario podrá representarse mediante un marcador con su fotografía de perfil.

Características:

- Mostrar usuarios cercanos.
- Mostrar distancia aproximada.
- Actualizar posiciones según permisos.
- Seleccionar un usuario para abrir su perfil.
- Configurar el radio de búsqueda.
- Aplicar filtros disponibles según el plan.
- Permitir desactivar la visibilidad en el radar.

Utilizar servicios de mapas compatibles con iOS, Android y Huawei: usar `flutter_map` con mosaicos (tiles) de OpenStreetMap autoalojados con Protomaps (archivo PMTiles) o mediante un proveedor de pago económico (Stadia Maps o similar; los planes gratuitos de estos proveedores suelen ser solo para uso no comercial), no Google Maps. Esto evita la dependencia de Google en Huawei y reduce costos.

Rendimiento del radar:
- No usar consultas geográficas pesadas. Guardar la ubicación como celda de cuadrícula o geohash (precisión ~1 km) con índice B-tree, y buscar por las celdas vecinas.
- Esto también sirve como ofuscación: el servidor nunca entrega coordenadas exactas, solo la celda aproximada y una distancia redondeada (ejemplo: «a 2 km»).
- Actualizar la ubicación solo al abrir la app o si el usuario se movió más de 500 m, nunca en segundo plano continuo (ahorra batería y servidor).
- Limitar el número de marcadores devueltos por consulta (ejemplo: 100) y agrupar marcadores cercanos.

**Seguridad de ubicación:**

Nunca exponer las coordenadas exactas de los usuarios a otros usuarios.

Utilizar coordenadas aproximadas, técnicas de ofuscación y controles contra triangulación.

Solicitar permiso de ubicación de manera transparente.

Permitir utilizar la aplicación sin compartir ubicación, aunque algunas funciones de proximidad puedan quedar limitadas.

La ubicación no debe mostrarse cuando el usuario haya desactivado su visibilidad.

Límites del radar por plan (ambos configurables desde el panel, sin publicar nueva versión):
- Cantidad máxima de usuarios con foto visible en el mapa (`maximum_radar_profiles`; inicial: 30 gratuito, 300 Premium). Los usuarios adicionales aparecen como marcadores difuminados, igual que en Explorar.
- Radio máximo de búsqueda (`maximum_radar_radius_km`; inicial: 2 km gratuito, 20 km Premium). El usuario puede elegir un radio menor, nunca mayor al de su plan.
- El servidor aplica siempre el menor de los dos límites.

---

# 8. MENSAJERÍA

Crear una sección independiente de mensajes.

Mostrar una lista de conversaciones con:

- Fotografía del usuario.
- Nombre.
- Último mensaje.
- Fecha u hora.
- Indicador de mensajes no leídos.
- Estado de conexión, si está disponible.

Al abrir una conversación:

- Mostrar historial.
- Enviar mensajes de texto.
- Recibir mensajes en tiempo real (ver arquitectura de tiempo real en la sección 17).
- Mostrar fecha y hora.
- Guardar conversaciones en caché local (SQLite) para abrirlas al instante, y sincronizar solo los mensajes nuevos con un cursor (`after_id`).
- Envío optimista: el mensaje aparece de inmediato y se confirma al responder el servidor.
- Mostrar notificaciones.
- Mostrar indicador de mensajes no leídos.

Diseñar la arquitectura para permitir incorporar posteriormente:

- Fotografías.
- Videos.
- Notas de voz.
- Stickers.
- Videollamadas.

Implementar protección contra spam, acoso y envío automatizado de mensajes.

Los mensajes deben contar con herramientas para bloquear y reportar usuarios.

Mensajería sin límite de conversaciones para ambos planes: cualquier usuario puede iniciar conversaciones con quien quiera (salvo bloqueos y perfiles que no puede ver, como los difuminados). La única restricción es la protección anti-spam: límite de velocidad de envío (ejemplo: máximo de conversaciones nuevas por hora), detección de mensajes idénticos repetidos y bloqueo temporal automático, todo configurable desde el panel.

Los límites de contenido multimedia podrán configurarse posteriormente por plan.

---

# 9. SISTEMA DE RESEÑAS Y REPUTACIÓN

Este módulo tiene reglas específicas que deben implementarse exactamente.

## 9.1 Quién puede dejar reseñas

Únicamente los usuarios Premium podrán dejar reseñas.

Requisito para reseñar: el autor debe haberle enviado al menos un mensaje al usuario que va a reseñar (no es necesario que el otro haya respondido). El servidor valida que exista ese mensaje antes de aceptar la reseña. Si el usuario reseñado bloqueó al autor, no se puede reseñar.

Límite:

**Máximo 3 reseñas por día por usuario.**

Las reseñas incluirán:

- Calificación de 1 a 5 estrellas.
- Comentario escrito.
- Opción de mostrar el username o publicarla como anónima.
- Usuario que realiza la reseña.
- Usuario que recibe la reseña.
- Fecha de creación.
- Fecha de última actualización.

Implementar controles para evitar abuso, difamación, hostigamiento y reseñas fraudulentas.

## 9.2 Quién puede consultar las reseñas

Cualquier usuario (gratuito o Premium) puede recibir reseñas. Un usuario gratuito recibe y acumula reseñas, pero no puede verlas; si se hace Premium, ve las que ya tenía (las últimas 30 visibles, según 9.3).

Visibilidad de las reseñas de otros perfiles:
- Un usuario Premium puede ver las reseñas (últimas 30, calificación promedio y número de reseñas) de cualquier perfil que abra, sea gratuito o Premium.
- Un usuario gratuito no ve las reseñas de ningún perfil, ni las suyas.

Los usuarios Premium podrán consultar las reseñas recibidas en su propio perfil.

Cada perfil mostrará a los usuarios Premium únicamente sus últimas 30 reseñas.

Mostrar:
- Calificación promedio.
- Número de reseñas.
- Comentarios.
- Autor de la reseña: al escribirla, el autor elige si se muestra su nombre de usuario (username) o si sale como «Anónimo». Aunque sea anónima, el sistema siempre guarda el autor real para moderación, para la regla de actualización (9.3) y para el límite diario; el autor real nunca se expone en la app ni en la API pública, solo en el panel administrativo.
- Fecha de actualización.

El historial completo permanecerá guardado en la base de datos.

## 9.3 Regla especial de actualización de reseñas

Esta lógica es obligatoria.

Cuando un usuario vuelve a dejar una reseña a otro usuario:

1. Consultar si ya existe una reseña de ese autor dentro de las últimas 30 reseñas visibles del perfil receptor.
2. Si existe dentro de esas 30, actualizar ese mismo registro.
3. Reemplazar la calificación anterior por la nueva.
4. Reemplazar el comentario anterior por el nuevo, y también la opción de anonimato.
5. Actualizar la fecha de modificación.
6. Si la reseña anterior ya no está entre las últimas 30, crear un nuevo registro.
7. Conservar todos los registros históricos.

Ejemplo:

Un perfil tiene 30 reseñas visibles.

Carlos ya había dejado una reseña anteriormente.

Caso A:
La reseña de Carlos todavía está entre las últimas 30.

Resultado: actualizar su reseña existente.

Caso B:
La reseña de Carlos ya no aparece entre las últimas 30.

Resultado: crear una nueva reseña.

No eliminar reseñas antiguas por superar el límite de visualización.

Si el autor elimina su cuenta, sus reseñas permanecen en los perfiles que reseñó, pero se muestran como «Usuario eliminado» (anónimas), y su promedio sigue contando. Sus datos personales se eliminan según la política de conservación; la reseña conserva solo calificación, comentario y fechas.

## 9.4 Límite diario

El límite de tres reseñas debe validarse desde el servidor.

Cada envío de reseña cuenta como una acción, incluyendo las actualizaciones de reseñas existentes.

El límite debe ser de tres acciones por día natural según la zona horaria configurada para el servicio.

Evitar que el usuario pueda superar el límite mediante solicitudes simultáneas o manipuladas.

---

# 10. FAVORITOS

Implementar un sistema de favoritos.

Permitir:
- Agregar perfiles.
- Eliminar perfiles.
- Consultar la lista.
- Abrir perfiles guardados.

El límite de favoritos para usuarios gratuitos y Premium será configurable posteriormente.

---

# 11. PLANES GRATUITOS Y PREMIUM

Implementar un sistema Freemium.

## 11.1 Plan gratuito

Características definidas:

- Crear y mantener perfil.
- Ver con foto los 30 perfiles más cercanos (configurable); el resto difuminado.
- Los perfiles posteriores al límite se muestran difuminados.
- Filtros básicos.
- Acceso a la exploración.
- Acceso al radar, sujeto a sus reglas.
- Acceso a mensajería.
- Dar manitas arriba y abajo.
- No puede dejar reseñas.
- No puede consultar las reseñas de otros perfiles.
- Puede ver publicidad comercial.

## 11.2 Plan Premium

Características definidas:

- Ver con foto los 300 perfiles más cercanos (configurable); el resto difuminado.
- Filtros avanzados.
- Puede dejar hasta tres reseñas diarias.
- Puede consultar las reseñas de su perfil, con un máximo de 30 visibles.
- Acceso a funcionalidades avanzadas de exploración.

Las funcionalidades adicionales Premium deberán poder activarse o desactivarse desde el panel administrativo.

## 11.3 Cobro de suscripciones

- Periodos y precios iniciales (MXN, IVA incluido):
  - Mensual: $50.
  - Anual: $400 (equivale a ~$33 al mes, 33% de ahorro frente al mensual).
- Los precios NO se escriben en el código: se administran desde el panel (módulo Planes). En las tiendas (App Store, Google Play, AppGallery) el precio se define en cada consola; el panel guarda el precio de referencia y el de Mercado Pago, y la app muestra el precio que reporta cada tienda.
- Dentro de la app: compras de la tienda correspondiente (App Store, Google Play Billing y Huawei IAP), como lo exigen las reglas de las tiendas para suscripciones digitales.
- En web: Mercado Pago, respetando las reglas vigentes de cada tienda sobre enlaces a pagos externos.
- El backend valida cada compra con el servidor de la tienda o el webhook de Mercado Pago, y es el único que activa o desactiva Premium.

## 11.4 Arquitectura de planes

No codificar los límites directamente en múltiples pantallas.

Crear un sistema centralizado de permisos y planes.

Cada funcionalidad debe consultar los permisos correspondientes.

Ejemplos:

- maximum_visible_profiles.
- advanced_filters_enabled.
- reviews_enabled.
- maximum_reviews_per_day.
- maximum_visible_reviews.
- maximum_gallery_photos.
- maximum_radar_profiles.
- maximum_radar_radius_km.
- advertising_enabled.

Esto permitirá modificar los planes sin actualizar las aplicaciones móviles.

---

# 12. SISTEMA DE PUBLICIDAD

La aplicación gratuita tendrá anuncios comerciales.

**IMPORTANTE: No utilizar Google AdSense ni Google Ads como sistema publicitario.**

La publicidad será contratada directamente por empresas o anunciantes mediante un portal web propio.

Crear un módulo publicitario que permita:

- Mostrar banners.
- Mostrar perfiles patrocinados.
- Mostrar espacios publicitarios dentro de la exploración.
- Configurar campañas.
- Definir fechas de inicio y finalización.
- Configurar ciudades o regiones de publicación.
- Subir imágenes.
- Registrar impresiones.
- Registrar clics.
- Consultar estadísticas.

Los anuncios deben estar claramente identificados como publicidad.

No utilizar conversaciones, roles sexuales, preferencias íntimas ni coordenadas precisas para segmentar campañas.

El modelo de facturación publicitaria es configurable por espacio publicitario desde el panel. Modelos soportados:
- Por días de campaña (precio fijo por día, según espacio y ciudad/región).
- Por impresiones (CPM: precio por cada 1,000 impresiones, con tope de presupuesto).
- Por clics (CPC: precio por clic, con tope de presupuesto).

Reglas:
- El administrador define qué modelos acepta cada espacio y sus precios.
- El anunciante elige el modelo al contratar, y el portal calcula el costo antes de pagar.
- En CPM y CPC la campaña se pausa automáticamente al agotar su presupuesto (la verificación se hace en la tarea programada y al registrar los lotes de impresiones y clics).
- Contar impresiones y clics válidos: descartar duplicados del mismo usuario en poco tiempo y clics automatizados.
- Pago del anunciante por Mercado Pago, con factura (CFDI) como pendiente a definir.

Premium no muestra anuncios de ningún tipo (ni banners ni perfiles patrocinados). Se controla con `advertising_enabled = false` en el plan Premium, configurable desde el panel.

---

# 13. PORTAL WEB PARA ANUNCIANTES

Desarrollar un sitio web independiente de la aplicación móvil.

Los anunciantes podrán:

1. Registrarse.
2. Iniciar sesión.
3. Crear una empresa.
4. Registrar información comercial.
5. Crear campañas.
6. Subir imágenes.
7. Seleccionar espacios publicitarios.
8. Seleccionar ciudades o regiones.
9. Elegir fechas de publicación.
10. Consultar costos.
11. Contratar campañas.
12. Consultar impresiones.
13. Consultar clics.
14. Consultar resultados.
15. Descargar reportes.

Crear un sistema de aprobación de anuncios por parte del administrador.

Las campañas no deben publicarse hasta que hayan sido aprobadas y se cumplan las condiciones de contratación.

---

# 14. PANEL ADMINISTRATIVO

Crear un panel web privado para administrar {{APP_NAME}}.

Debe incluir los siguientes módulos:

### Usuarios
- Consultar usuarios.
- Buscar por nombre o username.
- Consultar perfiles.
- Consultar tipo de plan.
- Suspender usuarios.
- Reactivar usuarios.
- Eliminar cuentas conforme a las políticas de conservación.
- Consultar actividad.

### Moderación
- Revisar reportes.
- Moderar fotografías.
- Moderar reseñas.
- Revisar contenido denunciado.
- Suspender cuentas.
- Gestionar apelaciones.

### Planes
- Crear planes.
- Modificar planes.
- Configurar límites.
- Activar funcionalidades Premium.
- Administrar precios.
- Consultar suscripciones.

### Publicidad
- Gestionar anunciantes.
- Aprobar campañas.
- Rechazar campañas.
- Gestionar espacios publicitarios.
- Consultar impresiones y clics.
- Administrar precios.

### Catálogos
- Administrar roles.
- Administrar intereses.
- Administrar etiquetas.
- Administrar saludos sugeridos.
- Configurar parámetros de la aplicación.

### Estadísticas
- Usuarios registrados.
- Usuarios activos diarios.
- Usuarios activos mensuales.
- Usuarios gratuitos.
- Usuarios Premium.
- Nuevas suscripciones.
- Cancelaciones.
- Ingresos.
- Número de mensajes.
- Perfiles consultados.
- Reseñas creadas.
- Impresiones publicitarias.
- Clics en anuncios.

---

# 15. NOTIFICACIONES

Implementar notificaciones push para:

- Nuevos mensajes.
- Actividad relevante.
- Nuevas interacciones.
- Nuevas reseñas.
- Notificaciones administrativas.
- Promociones.

Permitir configurar las preferencias de notificación.

Utilizar Firebase Cloud Messaging para Android y APNs para iOS, y Huawei Push Kit para dispositivos Huawei. Crear un servicio de notificaciones con un adaptador por proveedor, para que el resto del código no sepa cuál se usa.

Las notificaciones push son también el mecanismo principal para avisar de mensajes nuevos cuando la app está cerrada; la app no debe mantener conexiones abiertas en segundo plano.

---

# 16. SEGURIDAD, PRIVACIDAD Y MODERACIÓN

La aplicación manejará información personal y fotografías, por lo que la seguridad debe ser una prioridad.

Implementar:

- Validación de mayoría de edad.
- Protección de contraseñas.
- Tokens seguros.
- Control de sesiones.
- Cifrado de comunicaciones.
- Protección contra abuso de APIs.
- Limitación de solicitudes.
- Bloqueo de usuarios.
- Reportes.
- Moderación de imágenes.
- Protección contra cuentas falsas.
- Controles contra spam.
- Protección de ubicación.
- Políticas de privacidad.
- Términos de servicio.
- Eliminación de cuenta.
- Gestión de consentimiento.

No mostrar información privada de los usuarios a terceros sin autorización.

La aplicación debe cumplir las normas aplicables de privacidad y protección de datos, así como los requisitos de Apple App Store y Google Play.

---

# 17. ARQUITECTURA TECNOLÓGICA

Proponer una arquitectura moderna, mantenible y, sobre todo, **ligera**: debe funcionar con pocos recursos en el servidor descrito abajo y escalar después sin reescribirse.

## 17.1 Meta de capacidad

- Diseñar para **al menos 500 usuarios recurrentes** (activos cada día o casi cada día) desde el lanzamiento, con margen para llegar a 2,000 sin cambiar la arquitectura.
- Estimación de trabajo: entre 50 y 150 usuarios conectados al mismo tiempo en hora pico.
- Objetivos de velocidad:
  - Respuesta de la API (p95): menos de 300 ms.
  - Apertura de la app hasta ver la cuadrícula de Explorar: menos de 2 segundos con caché, menos de 3 sin caché.
  - Imágenes de la cuadrícula: miniaturas de menos de 30 KB.
- Incluir una prueba de carga (k6 o similar) que simule 500 usuarios recurrentes y 150 simultáneos, como criterio de aceptación.

## 17.2 Servidor inicial: Hostinger Cloud Startup

El backend se publicará inicialmente en un plan Hostinger Cloud Startup (aplicación Node.js gestionada, subdominio de expansionmexico.com), no en un VPS. Este plan tiene restricciones que la arquitectura DEBE respetar:

- **No admite WebSockets entrantes.** El chat en tiempo real no puede usar un servidor de WebSockets propio en este plan.
- **No admite procesos permanentes en segundo plano.** No usar colas tipo BullMQ/Redis ni workers permanentes. Las tareas programadas (limpieza de fotos temporales, cierre de campañas, estadísticas diarias) se ejecutan con tareas cron del hosting que llaman a endpoints internos protegidos.
- **Las peticiones se cortan a los 120 segundos.** Ningún proceso largo dentro de una petición (el análisis de IA debe responder rápido o procesarse en pasos).
- **La app Node.js se detiene si no recibe tráfico.** Minimizar el tiempo de arranque (arranque en frío) y configurar un ping periódico si es necesario.
- **Base de datos MySQL/MariaDB, no PostgreSQL.** Límite aproximado de conexiones por usuario de base de datos: usar un pool pequeño (10–20 conexiones).
- **Sin Redis.** Cachear en memoria del proceso (LRU con caducidad) y en tablas de MySQL cuando haga falta.

Todo componente que dependa del servidor (tiempo real, almacenamiento, tareas programadas) debe ir detrás de una interfaz/adaptador, para poder migrar a un VPS más adelante cambiando solo la configuración.

## 17.3 Stack definido

### Aplicación móvil
**Flutter** (una sola base de código para iOS, Android y Huawei; buen rendimiento y soporte de Huawei).
- Gestión de estado ligera (Riverpod o Bloc, elegir uno).
- Caché de imágenes en disco (`cached_network_image`).
- Base local SQLite (Drift) para conversaciones, perfiles vistos y configuración.
- Listas con carga perezosa y paginación por cursor; nunca cargar listas completas.
- Compresión de fotos en el teléfono antes de subirlas (WebP o JPEG, máximo 1080 px).

### Backend
**NestJS sobre Fastify** (no Express), por menor consumo de memoria y mayor velocidad.
- ORM ligero (Prisma o TypeORM, elegir uno) con consultas revisadas; evitar consultas N+1.
- Respuestas JSON compactas y paginadas; compresión gzip/brotli.
- Arranque rápido: sin módulos innecesarios.

### Base de datos
**MySQL 8 / MariaDB** (la que ofrece Hostinger).
- Ubicación con celdas de cuadrícula o geohash e índices B-tree (sin depender de PostGIS ni de funciones espaciales avanzadas).
- Índices para todas las consultas frecuentes; revisar cada consulta con `EXPLAIN`.
- Contadores diarios (perfiles vistos, reseñas del día) en una tabla de uso por usuario y día, con actualización atómica para evitar que se superen los límites con peticiones simultáneas.

### Tiempo real (mensajería)
Como el plan no admite WebSockets entrantes:
- **Fase inicial:** servicio externo de tiempo real con plan gratuito o económico (Ably, Pusher o similar). El backend guarda el mensaje en MySQL y después publica el evento al canal privado de la conversación. Los canales se autorizan desde el backend.
- **Respaldo:** si la conexión en tiempo real falla, la app consulta mensajes nuevos con `after_id` solo mientras la conversación está abierta (cada 3–5 s) y nunca en segundo plano.
- **App cerrada:** notificaciones push.
- **Futuro:** al migrar a VPS, cambiar el adaptador a WebSockets propios (Socket.IO) sin tocar la app.
- La conexión en tiempo real se abre solo con la app en primer plano y se cierra al pasar a segundo plano.

### Almacenamiento de fotos
- Interfaz de almacenamiento con adaptadores: disco del hosting (fase inicial) y almacenamiento compatible con S3 (Cloudflare R2 u otro) para cuando crezca.
- Generar 3 tamaños por foto: miniatura (~200 px), mediana (~600 px) y completa (~1080 px). La cuadrícula y el radar usan SOLO miniaturas.
- Servir imágenes a través de la CDN del hosting con caché larga; nombres de archivo únicos para poder cachearlas para siempre.

### Inteligencia artificial
- Integración por API con un modelo de visión y lenguaje económico.
- Reducir la foto a ~768 px antes de enviarla (menos costo y menos tiempo).
- La IA solo genera la descripción del perfil; los saludos salen del catálogo (Anexo A).
- Limitar las regeneraciones por usuario (configurable) para controlar costos.

### Mapas
`flutter_map` con mosaicos de OpenStreetMap a través de un proveedor de mosaicos (ver sección 7).

### Notificaciones
FCM (Android), APNs (iOS) y Huawei Push Kit (Huawei), detrás de un adaptador.

### Portales web (panel administrativo y portal de anunciantes)
Tecnología web ligera, preferentemente renderizada en servidor o estática, servida por el mismo backend o como sitio estático, con autenticación y permisos independientes de la app móvil.

## 17.4 Reglas de rendimiento para todo el proyecto

1. Toda lista se pagina por cursor (nunca `OFFSET` grandes).
2. Ningún endpoint devuelve más de lo que la pantalla muestra.
3. El endpoint `GET /config` y los catálogos (intereses, roles, saludos) se cachean en la app y en el servidor.
4. La lista de Explorar se recalcula al abrir la pestaña, al cambiar de ubicación (más de 500 m) o al refrescar manualmente, y se cachea unos minutos por usuario; no se recalcula en cada desplazamiento.
5. Las impresiones de anuncios se registran en lotes (la app las acumula y las envía cada cierto tiempo), no una petición por impresión.
6. Limitación de solicitudes por usuario e IP en memoria.
7. Medir: registrar tiempos de respuesta y consultas lentas desde el primer día.

## 17.5 Separación

Separar:
- Backend.
- Aplicación móvil.
- Panel administrativo.
- Portal de anunciantes.
- Base de datos.
- Servicios de almacenamiento.
- Servicios externos.

---

# 18. MODELO DE DATOS

Diseñar una base de datos relacional normalizada.

Como mínimo, considerar las siguientes entidades:

- users.
- user_profiles.
- user_photos.
- user_interests.
- interests.
- user_roles.
- available_roles.
- greetings (id, text, level 1–5, language, is_active).
- user_preferences.
- subscriptions.
- plans.
- plan_permissions.
- profile_interactions.
- reviews.
- conversations.
- conversation_members.
- messages.
- favorites.
- blocks.
- reports.
- user_locations.
- advertisements.
- advertisers.
- advertising_campaigns.
- ad_impressions.
- ad_clicks.
- notifications.
- moderation_actions.
- audit_logs.

La tabla reviews debe contemplar:

- id.
- reviewer_user_id.
- reviewed_user_id.
- rating.
- comment.
- is_anonymous (el autor eligió ocultar su username).
- created_at.
- updated_at.

No implementar una restricción única permanente que impida el comportamiento especial de actualización de las últimas 30 reseñas.

Implementar índices para consultas frecuentes y operaciones geográficas.

Tablas adicionales necesarias por esta versión:
- app_settings (configuración de marca y parámetros, sección 0).
- daily_usage (contadores diarios por usuario: perfiles vistos, reseñas, regeneraciones de IA).
- device_tokens (tokens push por dispositivo y proveedor: FCM, APNs, Huawei).
- payments / store_purchases (compras de tiendas y Mercado Pago).

La base de datos es MySQL/MariaDB (sección 17.2); no usar tipos ni extensiones exclusivas de PostgreSQL.

---

# 19. REGLAS DE NEGOCIO IMPORTANTES

1. Nadie menor de 18 años puede crear un perfil.
2. No se puede publicar un perfil incompleto.
3. El perfil solo se crea al presionar «Crear perfil».
4. Los datos del onboarding deben conservarse al navegar hacia atrás y adelante.
5. La fotografía utilizada para la descripción por IA no debe publicarse y debe eliminarse después de procesarse.
6. Los usuarios gratuitos ven con foto visible los 30 perfiles más cercanos (valor configurable); los siguientes aparecen difuminados.
7. Los usuarios Premium ven con foto visible los 300 perfiles más cercanos (valor configurable); los siguientes aparecen difuminados.
8. Los filtros avanzados son exclusivos de Premium.
9. Solo los usuarios Premium pueden dejar reseñas.
10. El límite de reseñas es de tres acciones diarias.
11. Cada perfil Premium muestra como máximo las últimas 30 reseñas.
12. Las reseñas históricas nunca se eliminan por el límite de visualización.
13. Si el autor vuelve a reseñar y su reseña anterior está entre las últimas 30, se actualiza.
14. Si su reseña anterior ya no está entre las últimas 30, se crea un registro nuevo.
15. Los permisos y límites deben validarse en el backend.
16. La ubicación exacta nunca debe exponerse públicamente.
17. Los usuarios deben poder bloquear y reportar a otros usuarios.
18. La publicidad será gestionada mediante el portal propio de anunciantes.
19. El nombre comercial nunca se escribe directamente en el código; siempre sale de la configuración de marca.
20. La arquitectura debe soportar al menos 500 usuarios recurrentes dentro de los límites del servidor descrito en la sección 17.2.

---

# 20. METODOLOGÍA DE DESARROLLO

No intentes desarrollar todo de manera improvisada en un solo archivo.

Trabaja por fases.

### Fase 1. Análisis y arquitectura
- Revisar todos los requisitos.
- Definir arquitectura.
- Diseñar base de datos.
- Definir APIs.
- Diseñar navegación.
- Definir estructura de carpetas.
- Identificar dependencias externas.

### Fase 2. Diseño de interfaz
- Diseñar todas las pantallas.
- Crear componentes reutilizables.
- Implementar identidad visual.
- Crear prototipos navegables.
- Validar el flujo de onboarding.

### Fase 3. Backend
- Autenticación.
- Gestión de usuarios.
- Perfiles.
- Planes.
- Permisos.
- Exploración.
- Geolocalización.
- Reseñas.
- Mensajería.
- Publicidad.

### Fase 4. Aplicación móvil
- Registro.
- Onboarding.
- Explorar.
- Detalle de perfiles.
- Radar.
- Mensajes.
- Perfil.
- Suscripciones.

### Fase 5. Portales web
- Administración.
- Anunciantes.
- Gestión de campañas.
- Estadísticas.

### Fase 6. Pruebas
- Prueba de carga: 500 usuarios recurrentes y 150 simultáneos con los objetivos de la sección 17.1.
- Prueba de cambio de marca: cambiar nombre y colores siguiendo la sección 0.3 y verificar que no quede el nombre anterior en ninguna pantalla.
- Pruebas unitarias.
- Pruebas de integración.
- Pruebas de APIs.
- Pruebas de seguridad.
- Pruebas de límites gratuitos y Premium.
- Pruebas de reseñas.
- Pruebas de geolocalización.
- Pruebas en iOS y Android.

### Fase 7. Publicación
- Preparación para App Store.
- Preparación para Google Play.
- Preparación para Huawei AppGallery.
- Configuración de servidores.
- Configuración de dominios.
- Configuración de certificados.
- Configuración de notificaciones.
- Monitoreo de errores.
- Documentación de despliegue.

---

# 21. CRITERIOS DE CALIDAD Y ENTREGA

El proyecto deberá entregarse con:

1. Código fuente completo.
2. Aplicación iOS funcional.
3. Aplicación Android funcional.
4. Backend funcional.
5. Base de datos y migraciones.
6. Panel administrativo.
7. Portal de anunciantes.
8. Documentación de instalación.
9. Documentación de APIs.
10. Variables de entorno documentadas.
11. Pruebas automatizadas.
12. Instrucciones de despliegue.
13. Documentación de servicios externos.
14. Instrucciones para publicar las aplicaciones.

No utilizar datos simulados como sustituto permanente de funcionalidades reales.

Durante el desarrollo se podrán utilizar usuarios de prueba, pero todos los módulos deberán conectarse posteriormente al backend real.

No dejar botones decorativos que aparenten funcionar y no ejecuten ninguna acción.

No dejar funcionalidades críticas implementadas únicamente en frontend.

Priorizar seguridad, mantenibilidad, rendimiento y escalabilidad.

---

# 22. INSTRUCCIÓN FINAL PARA LA IA DESARROLLADORA

Antes de comenzar a programar:

1. Analiza todo el documento.
2. Identifica requisitos ambiguos.
3. Presenta una propuesta de arquitectura.
4. Presenta el modelo de datos.
5. Presenta la estructura del proyecto.
6. Presenta un plan de ejecución por fases.
7. Identifica servicios externos y sus costos potenciales.
8. Confirma cómo cada módulo respeta las restricciones del servidor (sección 17.2).

Después comienza el desarrollo de manera ordenada.

Mantén los requisitos originales como fuente de verdad y no cambies las reglas de negocio sin autorización.

Si una funcionalidad no está completamente definida, crea una configuración flexible y solicita una decisión antes de implementar reglas irreversibles.

El resultado debe ser una aplicación comercial real, preparada para crecer y competir en el mercado de aplicaciones de encuentros y conexiones.

**Nombre del proyecto: {{APP_NAME}}.**

---

# ANEXO A. CATÁLOGO INICIAL DE SALUDOS (100)

Cargar como datos iniciales (seed) de la tabla `greetings`. Nivel 1 = más pícaro, nivel 5 = amigable.

## Nivel 1. Pícaro

1. ¿Vienes o voy?
2. Tengo planes… y tú sales en todos.
3. Hoy no quiero dormir solo.
4. Escríbeme y te cuento lo que no pongo aquí.
5. ¿Me invitas a tu casa o a la mía?
6. Soy peligroso después de las 10 pm.
7. Busco a alguien que me quite el aburrimiento.
8. Si me escribes, no respondo por mí.
9. Lo bueno se platica en privado.
10. ¿Nos portamos mal un rato?
11. Tengo vino, me falta compañía.
12. Mi cama tiene espacio para dos.
13. Hoy ando con ganas de travesuras.
14. ¿Qué tan cerca estás?
15. Pregúntame lo que quieras… lo que sea.
16. Me sobra energía y me falta con quién gastarla.
17. Te reto a escribirme primero.
18. Soy de los que no se quedan con las ganas.
19. Prometo que no muerdo… mucho.
20. ¿Y si dejamos de vernos solo por la app?

## Nivel 2. Coqueto

1. ¿Me regalas tu mejor sonrisa?
2. Me encantan los ojos que saben mirar.
3. Escríbeme, a ver si me sonrojas.
4. Busco a alguien que me ponga nervioso.
5. ¿Te gusta coquetear tanto como a mí?
6. Me late tu estilo, ¿y a ti el mío?
7. Dime algo bonito y te contesto rápido.
8. Me encantan los besos de buenos días.
9. ¿Nos tomamos algo y vemos qué pasa?
10. Tengo debilidad por las miradas profundas.
11. Si te gusta lo que ves, salúdame.
12. Me dicen que abrazo rico.
13. ¿Te atreves a invitarme un café?
14. Me gustan las sorpresas, ¿eres una?
15. Ojalá seas mi siguiente distracción favorita.
16. Si sonríes así en persona, me rindo.
17. Busco química, de la buena.
18. Me encantan los que saben hacerme reír.
19. Una cita y te convenzo.
20. ¿Hacemos match?

## Nivel 3. Juguetón

1. ¿Te animas?
2. ¿Un plan este fin?
3. Conoce mi lado más divertido.
4. ¿Cena, peli y buena plática?
5. Te invito unos tacos si me escribes.
6. Busco cómplice para mis planes locos.
7. ¿Bailamos este fin?
8. Soy mejor en persona, compruébalo.
9. ¿Mezcal o cerveza? Tú eliges.
10. Si me haces reír, ya ganaste.
11. ¿Aventura o maratón de series?
12. Ando buscando a alguien con buena vibra.
13. Te apuesto a que no adivinas mi signo.
14. ¿Karaoke? Prometo no cantar tan mal.
15. Escríbeme algo que me saque una sonrisa.
16. ¿Quién se anima a un plan improvisado?
17. Tengo buenos chistes malos.
18. Te cambio una plática por un café.
19. ¿Me cuentas tu mejor anécdota?
20. Busco al que se ría de mis memes.

## Nivel 4. Casual

1. ¡Conversemos!
2. ¿Qué tal tu día?
3. Hola, me gustaría conocerte.
4. ¿Qué te trae por aquí?
5. Salúdame sin pena.
6. Siempre listo para una buena plática.
7. ¿Café y conversación?
8. Nuevo por aquí, ¿me recomiendas algo?
9. Me gusta conocer gente con buena energía.
10. ¿Qué haces en tu tiempo libre?
11. Cuéntame algo de ti.
12. Platicar no cuesta nada.
13. Busco conocer gente nueva.
14. ¿Qué música escuchas?
15. Recomiéndame una serie.
16. Hablemos de viajes.
17. Me encanta conocer historias nuevas.
18. ¿Un paseo por el parque?
19. Abierto a conocer a alguien interesante.
20. Escríbeme, contesto rápido.

## Nivel 5. Amigable

1. Busco amigos para salir.
2. Hagamos plan con amigos.
3. ¿Te gusta el gym? Busco compañero de rutina.
4. Amistad primero, siempre.
5. Busco amigos para ir al cine.
6. ¿Jugamos algo en línea?
7. Nuevo en la ciudad, busco amigos.
8. Busco compañero de viajes, ¿te apuntas?
9. Busco con quién ir a conciertos.
10. ¿Salimos a correr un día?
11. Hagamos amistad y luego vemos.
12. Siempre es bueno tener un amigo más.
13. Busco gente buena onda para platicar.
14. ¿Un club de lectura de dos?
15. Busco compa para probar restaurantes.
16. Me gusta conocer gente sin presiones.
17. Buena plática y buena amistad.
18. ¿Vamos a un museo?
19. Busco amigos para el antro.
20. Aquí para hacer amigos, sin prisas.

