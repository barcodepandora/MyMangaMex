# Fase 7 — Adaptabilidad UI y HIG

## Hipótesis Lean

El pulido de layout adaptativo, tipografía propia y accesibilidad es lo que separa una app funcional de una app percibida como de calidad, y es explícitamente exigido por el enunciado ("layout funcional para iPhone y iPad") y por la especificación de UX del Main Prompt. Se valida si la app pasa una revisión visual en ambos tamaños de pantalla sin ajustes de emergencia.

## Prerrequisitos

- Fase 5 cerrada (detalle funcional).
- Fase 6 cerrada (búsqueda funcional).
- Todas las pantallas de producto (splash, loading, listado, detalle, búsqueda) existen y son navegables antes de empezar el pulido, para no adaptar layouts que aún van a cambiar de estructura.

## Especificación funcional

- Listado, detalle y búsqueda usan un layout específico para iPad (aprovechando el ancho, p. ej. múltiples columnas o vista maestro-detalle) distinto del layout de iPhone, no una simple ampliación del layout de iPhone.
- Toda la tipografía de la app proviene de archivos `.ttf` embebidos, no de la fuente del sistema, salvo fallback documentado si una fuente no carga.
- El texto respeta Dynamic Type: aumentar el tamaño de texto del sistema no rompe el layout ni recorta contenido crítico (título, portada, datos de colección).
- La navegación entre pantallas sigue patrones estándar de HIG (p. ej. `NavigationStack`/split view nativo según corresponda), sin gestos ni controles no estándar que confundan al usuario.
- Contraste de color suficiente para legibilidad en modo claro y oscuro.

## Plan técnico

- Revisión transversal de las Views ya construidas en Fases 3–6 para introducir layouts condicionados por clase de tamaño (`horizontalSizeClass`/`UIUserInterfaceIdiom` según corresponda), sin duplicar lógica de negocio de los ViewModels (que no cambian en esta fase).
- Registro de las fuentes `.ttf` en el proyecto (vía MCP de Xcode, no edición manual de `.pbxproj`) y un punto único de definición de estilos tipográficos reutilizado por todas las Views.
- Revisión de accesibilidad: etiquetas de accesibilidad en portadas e iconos de acción, verificación de Dynamic Type en las pantallas con más contenido (detalle, formulario de búsqueda avanzada).

## Desglose de tareas TDD

### Tarea 7.1 — Registro y aplicación de tipografía `.ttf`

- Red: no aplica test unitario estricto (es un recurso visual); el criterio de "rojo" es que las Views actuales usan la fuente del sistema por defecto.
- Green: fuentes `.ttf` registradas vía MCP de Xcode y aplicadas a través de un punto único de estilos; verificación visual en Simulator de que ninguna pantalla usa la fuente del sistema salvo el fallback documentado.
- Refactor: consolidar cualquier estilo de texto definido ad-hoc en pantallas previas dentro del punto único de estilos.

### Tarea 7.2 — Layout específico de iPad en listado y detalle

- Red: test de snapshot/estado de layout (si la infraestructura de test lo permite) o checklist visual que constata que, en clase de tamaño regular (iPad), listado y detalle no son una simple versión ampliada del layout de iPhone; falla en el estado actual.
- Green: layout condicionado implementado; verificación en Simulator de iPad.
- Refactor: extraer el criterio de "qué layout usar" a un punto reutilizable si se repite entre listado, detalle y búsqueda.

### Tarea 7.3 — Soporte de Dynamic Type sin recorte

- Red: verificación en Simulator con el tamaño de texto de accesibilidad más grande del sistema; se documenta qué pantallas recortan contenido crítico (estado "rojo" inicial).
- Green: ajustes de layout (wrapping, scroll, prioridades de compresión) hasta que ninguna pantalla crítica recorte título, portada o datos de colección con el tamaño de texto más grande.
- Refactor: ninguno adicional previsto más allá de simplificar cualquier `frame` fijo que haya causado el recorte.

### Tarea 7.4 — Navegación conforme a HIG

- Red: checklist contra HIG (patrones de navegación, iconografía estándar, controles nativos) sobre el estado actual de las pantallas; se documentan desviaciones como estado "rojo".
- Green: desviaciones corregidas usando componentes/patrones nativos de navegación; checklist en verde.
- Refactor: ninguno adicional previsto.

### Tarea 7.5 — Contraste y accesibilidad básica

- Red: verificación de contraste en modo claro y oscuro sobre las pantallas actuales; se documentan combinaciones insuficientes como estado "rojo".
- Green: paleta ajustada hasta cumplir contraste suficiente en ambos modos; etiquetas de accesibilidad añadidas a portadas e iconos de acción.
- Refactor: ninguno adicional previsto.

## Elementos de aprobación (Gate de cierre de Fase 7)

- [ ] Todos los tests/checklists de la Fase 7 están en verde vía MCP de Xcode y revisión visual en Simulator.
- [ ] Ninguna pantalla usa fuente del sistema fuera del fallback documentado.
- [ ] iPad presenta un layout propio (no una ampliación de iPhone) en listado y detalle.
- [ ] Con el tamaño de texto de accesibilidad más grande, ninguna pantalla crítica recorta título, portada o datos de colección.
- [ ] Navegación revisada contra HIG sin desviaciones pendientes.
- [ ] Contraste suficiente verificado en modo claro y oscuro.

## Señal de validación y pivot trigger

- Validación: revisión visual completa en Simulator de iPhone y iPad, en modo claro/oscuro y con Dynamic Type grande, sin encontrar recortes ni fuente incorrecta.
- Pivot trigger: si el layout maestro-detalle de iPad introduce complejidad de navegación no prevista en el Coordinator (Fase 0/3), se revisa el Coordinator dentro de esta fase antes de cerrarla, sin dejarlo pendiente para Fase 8.

## Corte de contexto

Fase cerrable en una sola sesión con contexto limpio al finalizar. No tiene subfases anidadas.
