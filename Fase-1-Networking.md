# Fase 1 — Capa de red (APIRouter)

## Hipótesis Lean

Centralizar todo acceso a la API en un único `enum APIRouter` reduce el riesgo de peticiones inconsistentes (paginación, parámetros) y permite testear la capa de red sin depender de la red real. Se valida si las fases de listado y búsqueda pueden implementarse sin añadir ninguna llamada a red fuera de esta capa.

## Prerrequisitos

- Fase 0 cerrada (proyecto, concurrencia, target de tests operativos).
- Especificación de la API (`Statement.md`, sección "Información de la API") disponible como referencia de contrato.

## Especificación funcional

- El sistema puede obtener, para cada endpoint documentado en el enunciado, una respuesta decodificada fuertemente tipada:
  - Listados paginados: `/list/mangas`, `/list/bestMangas`, con parámetros `page` y `per` coherentes entre peticiones sucesivas.
  - Listados no paginados: `/list/authors`, `/list/demographics`, `/list/genres`, `/list/themes`.
  - Listados filtrados: `/list/mangaByGenre/{valor}`, `/list/mangaByDemographic/{valor}`, `/list/mangaByTheme/{valor}`, `/list/mangaByAuthor/{id}`.
  - Búsquedas simples: `/search/mangasBeginsWith/{texto}`, `/search/mangasContains/{texto}`, `/search/author/{texto}`.
  - Consulta exacta: `/search/manga/{id}`.
  - Búsqueda avanzada: `POST /search/manga` con el cuerpo `CustomSearch` (título, nombre/apellido de autor, géneros, temáticas, demografías, flag de coincidencia parcial).
- Toda respuesta paginada expone también los metadatos (`total`, `page`, `per`) para que capas superiores decidan cuándo pedir la siguiente página.
- Ante un error de red, de decodificación o un código HTTP de error, el sistema expone un error tipado y específico (no genérico ni `Any`), distinguible por la UI para mostrar mensajes útiles.

## Plan técnico

- `enum APIRouter`: un caso por endpoint/familia de endpoint, con parámetros asociados fuertemente tipados (p. ej. página, tamaño de página, texto de búsqueda, id). Responsable de construir el `URLRequest` (ruta, método, query/body) y nada más.
- Un cliente HTTP `nonisolated` que recibe un `APIRouter`, ejecuta la petición y decodifica la respuesta a un DTO `Codable`, propagando un tipo de error propio del dominio de red.
- DTOs que reflejan literalmente la forma del JSON del enunciado (manga con autores/temas/géneros/demografías anidados, metadata de paginación, `CustomSearch` como cuerpo de petición).
- Mapeo explícito de fechas (`startDate`, `endDate`) y de campos con comillas anidadas en el JSON de ejemplo (`mainPicture`, `url`) hacia tipos limpios de dominio, aislando esa normalización en la capa de red para que el resto de la app no dependa de las peculiaridades del JSON de origen.
- Ningún `ViewModel` construye URLs o parámetros de red directamente: siempre pasa por `APIRouter`.

## Desglose de tareas TDD

### Tarea 1.1 — Definir `APIRouter` y construcción de `URLRequest`

- Red: tests que, para cada caso del enum, esperan una ruta y método HTTP concretos, y fallan porque `APIRouter` no existe.
- Green: `APIRouter` implementado; tests en verde para todos los casos de listado, filtro, búsqueda simple y búsqueda avanzada.
- Refactor: eliminar duplicación en la construcción de query items entre casos similares (paginación repetida en varios casos).

### Tarea 1.2 — Coherencia de paginación

- Red: test que pide página 1 con `per=20` y luego página 2, y espera que el segundo `URLRequest` conserve `per=20`; falla si el valor por defecto (`per=10`) se cuela.
- Green: el cliente de paginación fuerza el mismo `per` en toda una misma sesión de consulta.
- Refactor: extraer el estado de paginación a un tipo dedicado en vez de parámetros sueltos.

### Tarea 1.3 — DTOs y decodificación de manga anidado

- Red: test que decodifica el JSON de ejemplo del enunciado (Dragon Ball) y falla porque los DTOs no existen o la decodificación produce nils inesperados.
- Green: DTOs y `Decodable` personalizados donde el formato lo requiera (fechas, campos con comillas anidadas); test en verde con el JSON de ejemplo íntegro.
- Refactor: separar DTO de red de modelo de dominio si empiezan a divergir en más de un campo.

### Tarea 1.4 — Decodificación de metadata de paginación

- Red: test que decodifica una respuesta con árbol `metadata` (`total`, `page`, `per`) y falla porque no se expone al llamador.
- Green: el resultado de toda consulta paginada expone `metadata` junto a los elementos.
- Refactor: unificar el envoltorio "página de resultados" para reutilizarlo en todos los listados paginados.

### Tarea 1.5 — Manejo de errores tipado

- Red: tests que simulan (mediante inyección de un transporte falso) un error de red, un código HTTP de error y un JSON inválido, y fallan porque no hay un tipo de error específico que los distinga.
- Green: tipo de error de dominio de red con casos distinguibles; tests en verde.
- Refactor: mensajes de error revisados para legibilidad (sección 7 de la constitución), sin exponer detalles técnicos crudos al usuario final.

### Tarea 1.6 — Búsqueda avanzada `POST /search/manga`

- Red: test que arma un `CustomSearch` con varios campos opcionales a nil y espera un cuerpo JSON concreto; falla porque la codificación no existe o serializa nils como si fueran valores.
- Green: `CustomSearch` codificado correctamente, incluyendo el caso de todas las colecciones vacías/nil; test en verde.
- Refactor: validar que el flag de coincidencia parcial (`searchContains`) se refleja sin ambigüedad en el request.

## Elementos de aprobación (Gate de cierre de Fase 1)

- [ ] Todos los tests de la Fase 1 están en verde vía MCP de Xcode.
- [ ] Ningún `ViewModel` ni `View` construye una URL o `URLRequest` directamente (búsqueda de referencias confirma que todo pasa por `APIRouter`).
- [ ] La decodificación del JSON de ejemplo del enunciado (manga con autores/temas/géneros/demografías) es correcta y estable.
- [ ] Los errores de red son tipos concretos, no `Any` ni `Error` genérico sin distinción de casos.
- [ ] La paginación mantiene el mismo `per` entre páginas de una misma consulta.

## Señal de validación y pivot trigger

- Validación: una llamada real (o contra un doble de test) a `/list/mangas?page=1&per=10` decodifica sin fallos y expone `metadata.total` correctamente.
- Pivot trigger: si el JSON real de la API difiere del ejemplo del enunciado en campos no anticipados, se ajustan los DTOs en esta misma fase antes de avanzar (no se parchea desde fases posteriores).

## Corte de contexto

Fase cerrable en una sola sesión con contexto limpio al finalizar. No tiene subfases anidadas.
