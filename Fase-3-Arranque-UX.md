# Fase 3 — Arranque UX (Splash → Loading → Listado)

## Hipótesis Lean

Una secuencia de arranque clara (splash, carga, contenido) comunica al usuario que la app está viva mientras se resuelve la primera petición de red, reduciendo la percepción de fallo o bloqueo. Se valida si un usuario de prueba identifica sin ayuda las tres pantallas y su orden.

## Prerrequisitos

- Fase 1 cerrada (para poder disparar la primera carga real desde la pantalla de loading).
- Fase 2 cerrada (para poder comprobar en loading si ya hay datos de colección persistidos, si el diseño de Fase 4 lo requiere).

## Especificación funcional

- Al abrir la app se muestra primero una pantalla splash (marca/identidad de la app).
- Tras el splash se muestra una pantalla de loading mientras se resuelve la primera carga de datos (puede reutilizar la misma imagen que el splash, según el enunciado).
- Al completarse la carga inicial, la navegación pasa automáticamente a la pantalla de listado de mangas (contenido de Fase 4), sin acción manual del usuario.
- Si la primera carga falla (sin red, error de API), el usuario ve un estado de error legible con opción de reintentar, en vez de quedarse indefinidamente en loading.
- El usuario no puede volver atrás desde loading hacia splash, ni desde listado hacia loading/splash mediante gestos de navegación.

## Plan técnico

- `AppCoordinator` (de Fase 0) orquesta tres estados de arranque: `splash`, `loading`, `listado`. La transición de estado ocurre en el propio Coordinator, no en las Views.
- `SplashView` y `LoadingView` como Views `@MainActor` sin lógica de negocio; la lógica de "cuánto dura el splash" y "cuándo terminó la carga" vive en un `ViewModel`/estado del Coordinator, no en la View.
- La pantalla de loading dispara, a través del `APIRouter` (Fase 1), la primera página del listado principal (`/list/mangas`, página 1, `per` por defecto acordado en Fase 4), y solo transiciona a listado cuando esa respuesta llega (éxito) o expone el estado de error (fallo).
- Reutilización de un único recurso de imagen entre splash y loading, según el enunciado.

## Desglose de tareas TDD

### Tarea 3.1 — Máquina de estados de arranque

- Red: test que instancia el estado de arranque del Coordinator y espera que empiece en `splash`; falla porque el estado no existe.
- Green: estado `splash → loading → listado` (con rama `error`) implementado y testeado por transición; tests en verde.
- Refactor: modelar el estado como enum cerrado (sin `Any`) para que las transiciones inválidas sean irrepresentables.

### Tarea 3.2 — Transición splash → loading

- Red: test que verifica que, tras el tiempo/condición de splash definida, el estado pasa a `loading`; falla porque la transición no está implementada.
- Green: transición implementada; test en verde.
- Refactor: extraer el criterio de duración/condición de splash a una constante nombrada, no un valor mágico.

### Tarea 3.3 — Transición loading → listado (éxito) y loading → error (fallo)

- Red: dos tests con un transporte de red falso (inyectado): uno que responde con éxito y espera estado `listado`, otro que responde con error y espera estado `error`; ambos fallan porque la lógica no existe.
- Green: transición implementada conectando con `APIRouter`/cliente de Fase 1; ambos tests en verde.
- Refactor: mensaje de error de la rama `error` revisado por legibilidad, sin volcar detalles técnicos crudos.

### Tarea 3.4 — Reintento desde estado de error

- Red: test que, desde estado `error`, dispara la acción de reintento y espera volver a `loading`; falla porque la acción no existe.
- Green: acción de reintento implementada; test en verde.
- Refactor: evitar duplicar la lógica de "disparar carga" entre la transición inicial y el reintento (misma función interna).

### Tarea 3.5 — Vistas Splash y Loading (sin lógica de negocio)

- Red: no aplica test unitario clásico; el criterio de "rojo" es que las vistas no existen y el Coordinator no tiene nada que presentar.
- Green: `SplashView` y `LoadingView` implementadas, `@MainActor`, presentadas por el Coordinator según el estado de la Tarea 3.1; verificación manual/visual vía Simulator (MCP de Xcode) de que ambas comparten la misma imagen.
- Refactor: extraer estilos comunes (tipografía, color) si se repiten literalmente entre ambas vistas.

## Elementos de aprobación (Gate de cierre de Fase 3)

- [ ] Todos los tests de la Fase 3 están en verde vía MCP de Xcode.
- [ ] En Simulator, la secuencia observada al abrir la app es exactamente splash → loading → listado (o loading → error si se simula fallo de red).
- [ ] No hay gesto ni botón que permita volver de listado a loading/splash.
- [ ] Splash y loading comparten el mismo recurso de imagen.
- [ ] El estado de error es legible y ofrece reintento funcional.

## Señal de validación y pivot trigger

- Validación: un usuario de prueba (o el propio desarrollador) confirma, sin explicación previa, que entendió que la app estaba cargando y no bloqueada.
- Pivot trigger: si el tiempo real de la primera carga en condiciones normales de red hace que loading se perciba como "colgado", se ajusta el criterio de la Tarea 3.2/3.3 (p. ej. duración mínima de splash, indicador de progreso) dentro de esta misma fase.

## Corte de contexto

Fase cerrable en una sola sesión con contexto limpio al finalizar. No tiene subfases anidadas.
