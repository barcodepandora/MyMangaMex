# Fase 4 — Listado de mangas (núcleo del MVP)

Esta fase tiene **dos subfases anidadas** (4.A y 4.B): comparten el mismo `ViewModel` de listado y su estado de paginación, por lo que dividirlas en sesiones de contexto separadas obligaría a reconstruir ese estado compartido dos veces. Se completan en la misma sesión.

## Hipótesis Lean

Mostrar el listado completo de mangas con portada y paginación coherente, más al menos un filtro de categorización, es el valor mínimo que el enunciado exige como entregable obligatorio ("consulta de cualquier referencia bibliográfica" + "al menos una categorización en listados o filtros"). Se valida si un usuario puede encontrar un manga conocido y filtrarlo por una categoría sin instrucciones.

## Prerrequisitos

- Fase 3 cerrada (la app llega a esta pantalla desde el flujo de arranque).
- Fase 1 cerrada (paginación y filtros ya disponibles en `APIRouter`).

---

## Subfase 4.A — Listado paginado con portada

### Especificación funcional

- El listado muestra, por cada manga, al menos: título, portada (imagen desde la URL remota) y una referencia bibliográfica mínima (p. ej. estado o puntuación) suficiente para identificarlo.
- El listado usa un `per` fijo elegido para toda la sesión de listado (coherente con la Tarea 1.2), no cambia entre páginas de la misma consulta.
- Mientras la imagen de portada carga, se muestra un placeholder; si la URL falla, se muestra un estado alternativo (no un hueco vacío ni crash).
- El listado funciona en layout de iPhone y de iPad (composición básica; el pulido fino de adaptabilidad se trata en Fase 7).

### Plan técnico

- `MangaListViewModel` `@MainActor` que mantiene: página actual, `per` fijo, elementos acumulados, metadata de la última respuesta, estado de carga.
- Uso de `APIRouter.listMangas(page:per:)` (Fase 1) para obtener cada página; el ViewModel no conoce detalles de `URLRequest`.
- Carga de imagen remota desacoplada del modelo de datos (componente de imagen asíncrona reutilizable), para no bloquear el hilo principal.

### Desglose de tareas TDD

#### Tarea 4.A.1 — Carga de primera página

- Red: test que crea `MangaListViewModel`, dispara la carga inicial y espera elementos poblados desde una respuesta simulada; falla porque el ViewModel no existe.
- Green: `MangaListViewModel` implementado; test en verde con datos simulados.
- Refactor: extraer el mapeo DTO → modelo de presentación si el ViewModel empieza a conocer detalles del DTO de red.

#### Tarea 4.A.2 — Consistencia de `per` entre páginas

- Red: test que carga página 1 y luego pide "más elementos", y espera que la segunda petición use el mismo `per` que la primera; falla si se usa el valor por defecto.
- Green: el ViewModel fija `per` en la primera carga y lo reutiliza; test en verde.
- Refactor: ninguno adicional previsto.

#### Tarea 4.A.3 — Renderizado de portada con placeholder y fallback

- Red: test (o verificación de estado observable del componente de imagen) que espera estado `cargando` antes de resolver la URL y estado `fallback` si la carga falla; falla porque esos estados no existen.
- Green: componente de imagen asíncrona con esos tres estados (cargando/cargada/fallback) implementado; tests en verde.
- Refactor: reutilizar el mismo componente en Fase 5 (detalle) sin duplicarlo.

### Elementos de aprobación (Gate 4.A)

- [ ] Tests de la subfase 4.A en verde vía MCP de Xcode.
- [ ] El listado muestra título y portada de cada manga en Simulator, en iPhone y iPad.
- [ ] Ninguna portada rota deja un hueco vacío o produce crash.

---

## Subfase 4.B — Scroll infinito y categorización

### Especificación funcional

- Cuando el usuario ha visto en pantalla las tres cuartas partes de los elementos cargados en la página actual, la app carga automáticamente la página siguiente y la añade al final del listado, sin acción explícita del usuario.
- El listado ofrece al menos un filtro de categorización (género, demografía o temática) que, al aplicarse, sustituye el listado general por el resultado filtrado (usando los endpoints `/list/mangaByGenre`, `/list/mangaByDemographic` o `/list/mangaByTheme` de Fase 1), manteniendo la misma mecánica de paginación y scroll infinito.
- Cambiar de filtro (o quitarlo) reinicia la paginación desde la página 1 con el nuevo criterio, sin mezclar resultados de distintos filtros.

### Plan técnico

- Extensión de `MangaListViewModel` con un disparador de "cargar siguiente página" basado en el índice del elemento visible más avanzado, comparado contra el 75% del tamaño de la página cargada.
- Estado de filtro activo (enum cerrado: sin filtro, por género, por demografía, por temática, con el valor concreto asociado) que determina qué caso de `APIRouter` se usa para cada página.
- Al cambiar el estado de filtro, se reinicia el estado de paginación de la Subfase 4.A (misma estructura, nueva fuente).

### Desglose de tareas TDD

#### Tarea 4.B.1 — Disparo de carga al 75% de la página visible

- Red: test que simula que el usuario ha visto el elemento en la posición correspondiente al 75% de una página de tamaño conocido, y espera que se dispare la carga de la página siguiente; falla porque el umbral no está implementado.
- Green: lógica de umbral implementada y testeada con distintos tamaños de página (p. ej. 10, 20, 50); tests en verde.
- Refactor: expresar el umbral como función pura testeable de forma aislada (sin depender de la UI) para facilitar variarlo en el futuro.

#### Tarea 4.B.2 — No duplicar ni perder elementos en la carga incremental

- Red: test que carga dos páginas sucesivas por scroll infinito y espera que el total de elementos acumulados sea exactamente la suma de ambas páginas, sin duplicados; falla si se repite el disparo del umbral más de una vez para la misma página.
- Green: guarda de "página ya solicitada" implementada; test en verde.
- Refactor: ninguno adicional previsto.

#### Tarea 4.B.3 — Filtro de categorización (una dimensión, MVP)

- Red: test que aplica un filtro (p. ej. género "Romance") y espera que la siguiente carga use el endpoint de filtro correspondiente en vez del listado general; falla porque el estado de filtro no existe.
- Green: estado de filtro implementado, conectado a los casos de `APIRouter` correspondientes; test en verde.
- Refactor: dejar preparada (sin implementar todavía) la extensión a múltiples dimensiones de filtro simultáneas como candidato de Fase 9, documentado como comentario/nota, no como código muerto.

#### Tarea 4.B.4 — Reinicio de paginación al cambiar de filtro

- Red: test que carga varios elementos con un filtro, cambia a otro filtro y espera que el listado se reinicie desde página 1 sin mezclar resultados; falla si los elementos previos persisten.
- Green: reinicio de estado implementado; test en verde.
- Refactor: ninguno adicional previsto.

### Elementos de aprobación (Gate 4.B)

- [ ] Tests de la subfase 4.B en verde vía MCP de Xcode.
- [ ] En Simulator, hacer scroll hasta el 75% de la página actual dispara la carga de la siguiente sin interacción adicional, verificable visualmente.
- [ ] Aplicar un filtro de categorización sustituye correctamente el listado, y cambiarlo no mezcla resultados de distinto criterio.
- [ ] No hay elementos duplicados tras varias cargas incrementales consecutivas.

---

## Señal de validación y pivot trigger (Fase 4 completa)

- Validación: un usuario de prueba localiza un manga conocido mediante scroll y logra filtrar el listado por al menos una categoría sin ayuda.
- Pivot trigger: si el volumen de datos (64.000+ mangas) hace que el scroll infinito con `per` pequeño resulte lento o con saltos visuales, se ajusta el `per` por defecto dentro de esta fase antes de pasar a Fase 5.

## Corte de contexto

Fase anidada: 4.A y 4.B se completan en la misma sesión de contexto. El contexto se limpia únicamente al cerrar el Gate de la 4.B.
