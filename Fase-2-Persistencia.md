# Fase 2 — Persistencia local (SwiftData)

## Hipótesis Lean

Guardar localmente solo los tres datos de colección exigidos por el enunciado (tomos comprados, tomo por el que va leyendo, colección completa) es suficiente para que el usuario perciba valor de "gestionar su colección" sin necesidad de sincronizar toda la ficha del manga. Se valida si Fase 5 puede construir la edición de colección sin pedir campos adicionales a esta capa.

## Prerrequisitos

- Fase 0 cerrada.
- Puede desarrollarse en paralelo a la Fase 1 (no depende de la capa de red, solo del identificador de manga que la API expone).

## Especificación funcional

- El sistema puede guardar, para un manga identificado por su `id` de la API, tres datos de colección del usuario:
  - Número de tomos comprados.
  - Tomo por el que va leyendo.
  - Si tiene o no la colección completa.
- El sistema puede consultar si un manga dado ya tiene entrada de colección, y en tal caso recuperar esos tres datos.
- El sistema puede actualizar una entrada existente sin duplicarla.
- El sistema puede listar todos los mangas que el usuario tiene en su colección (para uso futuro en filtros/categorización).
- Los datos persisten entre lanzamientos de la app.

## Plan técnico

- Un modelo SwiftData `MangaCollectionEntry` (o nombre equivalente) con: identificador de manga (clave de relación con el catálogo remoto), tomos comprados, tomo actual de lectura, flag de colección completa.
- Un repositorio `nonisolated` (o `@ModelActor` si la concurrencia estricta lo requiere) que expone operaciones de alto nivel: crear-o-actualizar entrada, leer entrada por id de manga, listar todas las entradas. Los `ViewModel`s no tocan el `ModelContext` directamente.
- Validación de invariantes a nivel de repositorio: el tomo de lectura no puede superar los tomos comprados; los tomos comprados no pueden ser negativos. Estas reglas se testean como parte del dominio, no como validación de UI únicamente.
- Sin dependencia de la capa de red: el repositorio solo conoce el `id` de manga como referencia, no el DTO completo.

## Desglose de tareas TDD

### Tarea 2.1 — Modelo SwiftData de colección

- Red: test que intenta guardar una entrada de colección y falla porque el modelo no existe.
- Green: `MangaCollectionEntry` definido como `@Model`; test guarda y recupera una entrada en un contenedor SwiftData en memoria.
- Refactor: nombres de propiedades alineados con el dominio (no con nombres crudos del JSON de la API).

### Tarea 2.2 — Repositorio: crear y leer

- Red: test que crea una entrada para un `id` de manga y espera poder leerla de vuelta; falla porque el repositorio no existe.
- Green: repositorio implementado con operaciones `guardar` y `obtener(por: id)`; test en verde.
- Refactor: extraer protocolo del repositorio para permitir dobles de test en fases posteriores (Fase 5 lo necesitará).

### Tarea 2.3 — Repositorio: actualizar sin duplicar

- Red: test que guarda dos veces para el mismo `id` de manga con valores distintos y espera una única entrada con el valor más reciente; falla si aparecen dos filas.
- Green: lógica de "crear o actualizar" (upsert) implementada; test en verde.
- Refactor: ninguno adicional previsto.

### Tarea 2.4 — Invariantes de dominio

- Red: tests que intentan guardar tomo de lectura mayor que tomos comprados, y tomos comprados negativos; ambos deben fallar de forma controlada (no crash, no force unwrap).
- Green: repositorio rechaza o normaliza esos valores según la regla definida; tests en verde sin ningún `!`.
- Refactor: mensajes/errores de validación revisados para que una futura UI pueda mostrarlos de forma legible.

### Tarea 2.5 — Listado de colección persistida

- Red: test que guarda tres entradas y espera recuperarlas todas en una consulta de listado; falla porque la operación no existe.
- Green: operación de listado implementada; test en verde.
- Refactor: ninguno adicional previsto.

## Elementos de aprobación (Gate de cierre de Fase 2)

- [ ] Todos los tests de la Fase 2 están en verde vía MCP de Xcode.
- [ ] Los tres campos exigidos por el enunciado (tomos comprados, tomo de lectura, colección completa) están modelados y persisten entre relanzamientos del contenedor SwiftData.
- [ ] Ningún `ViewModel` accede al `ModelContext` directamente; todo pasa por el repositorio.
- [ ] Las invariantes (lectura ≤ comprados, comprados ≥ 0) están cubiertas por test y no dependen de force unwrap.
- [ ] El repositorio no depende de tipos de la capa de red (Fase 1).

## Señal de validación y pivot trigger

- Validación: se puede guardar, cerrar y reabrir la app (o el contenedor de test persistente) y los tres datos siguen disponibles.
- Pivot trigger: si en Fase 5 se descubre que se necesita un dato adicional de colección no previsto aquí, se vuelve a esta fase a extender el modelo antes de seguir, en vez de improvisar persistencia paralela.

## Corte de contexto

Fase cerrable en una sola sesión con contexto limpio al finalizar. No tiene subfases anidadas.
