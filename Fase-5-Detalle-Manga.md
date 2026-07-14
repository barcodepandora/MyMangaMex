# Fase 5 — Detalle de manga y colección del usuario

## Hipótesis Lean

Ver la ficha completa de un manga y poder registrar ahí mismo los datos de colección (tomos comprados, tomo de lectura, colección completa) cierra el ciclo de valor central del enunciado: "gestionar su colección". Se valida si un usuario puede, desde el listado, llegar al detalle y guardar sus tres datos sin salir de esa pantalla.

## Prerrequisitos

- Fase 4 cerrada (navegación desde el listado hacia el detalle).
- Fase 2 cerrada (repositorio de colección disponible).

## Especificación funcional

- Al seleccionar un manga del listado, se navega a una pantalla de detalle con: título (original/inglés según disponibilidad), portada, autores con su rol, temáticas, géneros, demografías, sinopsis, estado, puntuación, número de tomos y fechas de publicación cuando existan.
- La pantalla de detalle incluye una sección editable con los tres datos de colección del usuario, que se guarda contra el repositorio de la Fase 2 y se recupera si ya existía una entrada previa para ese manga.
- Los cambios en los datos de colección se reflejan de inmediato en la propia pantalla (sin necesidad de recargar) y persisten al volver al listado y regresar al detalle.
- Si el manga no tiene colección de usuario todavía, la sección se muestra en estado "sin datos" con una acción clara para empezar a registrarla, sin forzar al usuario a introducir los tres campos a la vez si no quiere.

## Plan técnico

- `MangaDetailViewModel` `@MainActor` que combina: el manga (recibido desde el listado, o vuelto a pedir por `id` vía `APIRouter.manga(id:)` de Fase 1 si se navega desde una fuente que no lo tenga completo) y la entrada de colección (repositorio de Fase 2).
- Reutilización del componente de imagen asíncrona de la Subfase 4.A para la portada en detalle.
- La sección de edición de colección usa el protocolo de repositorio extraído en la Tarea 2.2 (refactor) para poder testear el ViewModel con un doble de repositorio, sin tocar SwiftData real en los tests de UI/ViewModel.
- Validación de entrada en la UI que respeta las invariantes ya cubiertas en Fase 2 (lectura ≤ comprados, comprados ≥ 0), mostrando el rechazo de forma legible en vez de permitir un estado inconsistente.

## Desglose de tareas TDD

### Tarea 5.1 — Navegación listado → detalle vía Coordinator

- Red: test que, dado un elemento seleccionado en el listado, espera que el Coordinator navegue a detalle con el `id` correcto; falla porque la ruta no existe.
- Green: navegación implementada en el Coordinator (no en la View); test en verde.
- Refactor: ninguno adicional previsto.

### Tarea 5.2 — Carga y presentación de la ficha completa

- Red: test que, con un manga simulado con autores/temas/géneros/demografías, espera que el ViewModel exponga todos esos campos listos para presentación; falla porque el mapeo no existe.
- Green: `MangaDetailViewModel` implementado; test en verde con el JSON de ejemplo del enunciado.
- Refactor: reutilizar el DTO/mapeo de la Fase 1 sin duplicar lógica de decodificación.

### Tarea 5.3 — Carga de colección existente

- Red: test que, para un manga con entrada de colección previa (doble de repositorio), espera que el ViewModel la muestre precargada; falla porque no se consulta el repositorio al entrar en detalle.
- Green: consulta al repositorio implementada al inicializar el ViewModel; test en verde.
- Refactor: ninguno adicional previsto.

### Tarea 5.4 — Guardar datos de colección desde detalle

- Red: test que edita los tres campos y dispara guardar, esperando que el repositorio reciba exactamente esos valores para ese `id` de manga; falla porque la acción de guardar no existe.
- Green: acción de guardar implementada usando el repositorio de Fase 2; test en verde.
- Refactor: ninguno adicional previsto.

### Tarea 5.5 — Rechazo legible de valores inválidos

- Red: test que intenta guardar tomo de lectura mayor que tomos comprados desde el ViewModel de detalle, y espera un estado de error de validación visible, no una escritura silenciosa ni un crash; falla porque no se propaga el rechazo del repositorio (Tarea 2.4).
- Green: el ViewModel traduce el rechazo del repositorio a un estado de error legible; test en verde.
- Refactor: mensaje de validación revisado contra la sección 7 de la constitución (legibilidad).

### Tarea 5.6 — Persistencia visible al volver a entrar

- Red: test de integración (repositorio real en memoria, no doble) que guarda, "sale" del detalle (nueva instancia de ViewModel) y "vuelve a entrar", esperando los mismos datos; falla si el estado no sobrevive a una nueva instancia del ViewModel.
- Green: confirmado que la fuente de verdad es el repositorio persistente, no estado en memoria del ViewModel; test en verde.
- Refactor: ninguno adicional previsto.

## Elementos de aprobación (Gate de cierre de Fase 5)

- [ ] Todos los tests de la Fase 5 están en verde vía MCP de Xcode.
- [ ] Desde el listado se llega al detalle de cualquier manga visible, en iPhone y iPad.
- [ ] El detalle muestra autores (con rol), temáticas, géneros, demografías y portada del JSON de ejemplo sin campos vacíos inesperados.
- [ ] Guardar los tres datos de colección persiste correctamente y se refleja al reabrir el detalle.
- [ ] Los valores inválidos (lectura > comprados, comprados negativos) se rechazan de forma legible, sin crash y sin force unwrap.

## Señal de validación y pivot trigger

- Validación: el propio desarrollador, actuando como usuario, registra su colección real de 3–5 mangas conocidos y los datos sobreviven a cerrar y reabrir la app.
- Pivot trigger: si registrar los tres datos a la vez resulta tedioso en la prueba de uso, se reconsidera (dentro de esta fase) permitir guardarlos de forma incremental en vez de exigir los tres juntos.

## Corte de contexto

Fase cerrable en una sola sesión con contexto limpio al finalizar. No tiene subfases anidadas.
