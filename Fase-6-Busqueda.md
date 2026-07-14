# Fase 6 — Búsqueda

Dos subfases anidadas (6.A y 6.B): comparten el mismo `ViewModel` de búsqueda y su presentación de resultados paginados, por lo que se completan en la misma sesión de contexto.

## Hipótesis Lean

Poder buscar por título es la vía principal para "consultar cualquier referencia bibliográfica" cuando el usuario ya sabe qué manga busca, en vez de depender solo del scroll del listado general. Se valida si un usuario encuentra un manga conocido por búsqueda en menos tiempo que por scroll.

## Prerrequisitos

- Fase 4 cerrada (reutiliza presentación de resultados en formato lista con portada).
- Fase 1 cerrada (endpoints de búsqueda ya disponibles en `APIRouter`).

---

## Subfase 6.A — Búsquedas simples (título y autor)

### Especificación funcional

- El usuario puede escribir texto en un campo de búsqueda y obtener mangas cuyo título empieza por ese texto (`/search/mangasBeginsWith`) o, alternativamente, que lo contienen (`/search/mangasContains`), según el modo de búsqueda activo.
- El usuario puede buscar autores por nombre o apellido (`/search/author`) y ver la lista de autores coincidentes.
- Los resultados de búsqueda por título se presentan paginados con la misma mecánica de scroll infinito al 75% definida en la Fase 4 (Tarea 4.B.1), reutilizada, no reimplementada.
- Una consulta exacta por `id` (`/search/manga/{id}`) está disponible como operación de soporte, reutilizada por la navegación de detalle (Fase 5) cuando sea necesario recargar un manga concreto.

### Plan técnico

- `MangaSearchViewModel` `@MainActor` que reutiliza el mismo componente de paginación/scroll infinito de la Subfase 4.A/4.B mediante composición, no copia de código.
- El modo de búsqueda (empieza-por / contiene) se modela como estado explícito (enum cerrado) que determina qué caso de `APIRouter` se invoca en cada tecleo, con antirrebote (debounce) para no disparar una petición por cada carácter.

### Desglose de tareas TDD

#### Tarea 6.A.1 — Búsqueda por título con antirrebote

- Red: test que simula tecleo rápido de varios caracteres y espera una única petición de red tras el antirrebote, con el texto final; falla porque se disparan varias peticiones.
- Green: antirrebote implementado; test en verde.
- Refactor: parametrizar el tiempo de antirrebote como constante nombrada.

#### Tarea 6.A.2 — Alternancia empieza-por / contiene

- Red: test que cambia el modo de búsqueda y espera que la siguiente petición use el endpoint correspondiente (`mangasBeginsWith` vs `mangasContains`); falla porque el modo no está modelado.
- Green: estado de modo implementado; test en verde.
- Refactor: ninguno adicional previsto.

#### Tarea 6.A.3 — Búsqueda de autores

- Red: test que busca un fragmento de nombre/apellido de autor y espera una lista de autores coincidentes; falla porque no existe el flujo.
- Green: flujo de búsqueda de autores implementado sobre `APIRouter` de Fase 1; test en verde.
- Refactor: ninguno adicional previsto.

#### Tarea 6.A.4 — Reutilización de scroll infinito en resultados de búsqueda

- Red: test que, con resultados de búsqueda simulados, verifica que el mismo umbral del 75% (Tarea 4.B.1) dispara la página siguiente de resultados; falla si la lógica se duplicó en vez de reutilizarse.
- Green: composición confirmada (mismo componente, distinta fuente de datos); test en verde.
- Refactor: eliminar cualquier duplicación detectada respecto a Fase 4.

### Elementos de aprobación (Gate 6.A)

- [ ] Tests de la subfase 6.A en verde vía MCP de Xcode.
- [ ] Buscar un título conocido (p. ej. "dragon") devuelve resultados coherentes en Simulator.
- [ ] Cambiar entre modo "empieza por" y "contiene" cambia el conjunto de resultados de forma coherente con el enunciado.
- [ ] No se dispara más de una petición de red por pausa de tecleo.

---

## Subfase 6.B — Búsqueda avanzada (`POST /search/manga`)

### Especificación funcional

- El usuario puede combinar, en un mismo formulario de búsqueda avanzada, cualquier subconjunto de: título, nombre de autor, apellido de autor, uno o varios géneros, una o varias temáticas, una o varias demografías, y un interruptor de "coincidencia parcial" (equivalente a `searchContains`).
- Enviar el formulario ejecuta `POST /search/manga` con el cuerpo `CustomSearch` (Fase 1, Tarea 1.6) y presenta los resultados con la misma mecánica paginada/scroll infinito.
- Dejar todos los campos vacíos y enviar se trata como caso inválido: se pide al usuario introducir al menos un criterio, en vez de lanzar una búsqueda vacía contra 64.000+ mangas.

### Plan técnico

- `AdvancedSearchViewModel` `@MainActor` que construye un `CustomSearch` a partir del estado del formulario, delegando la codificación/envío al `APIRouter` de Fase 1.
- Las listas de géneros, temáticas y demografías seleccionables se obtienen de los endpoints no paginados correspondientes (`/list/genres`, `/list/themes`, `/list/demographics`), no se hardcodean en la UI.

### Desglose de tareas TDD

#### Tarea 6.B.1 — Construcción de `CustomSearch` desde el estado del formulario

- Red: test que, con una combinación parcial de criterios seleccionados, espera un `CustomSearch` con exactamente esos campos poblados y el resto a nil/vacío; falla porque el mapeo no existe.
- Green: mapeo implementado; test en verde.
- Refactor: ninguno adicional previsto.

#### Tarea 6.B.2 — Validación de "al menos un criterio"

- Red: test que intenta enviar el formulario vacío y espera un estado de error de validación en vez de una petición de red disparada; falla porque no hay guarda.
- Green: guarda de validación implementada antes de invocar `APIRouter`; test en verde.
- Refactor: mensaje de validación revisado por legibilidad.

#### Tarea 6.B.3 — Carga de opciones desde catálogo remoto

- Red: test que espera que las opciones de género/temática/demografía del formulario provengan de una respuesta de `APIRouter` simulada, no de una lista fija en código; falla si están hardcodeadas.
- Green: carga dinámica implementada; test en verde.
- Refactor: cachear estas listas (no paginadas, poco cambiantes) para no recargarlas en cada apertura del formulario dentro de la misma sesión.

#### Tarea 6.B.4 — Resultados paginados de búsqueda avanzada

- Red: test que, con una respuesta paginada simulada de `POST /search/manga`, espera que el mismo componente de listado/scroll infinito de Fase 4 presente esos resultados; falla si se reimplementa la presentación.
- Green: composición confirmada; test en verde.
- Refactor: ninguno adicional previsto.

### Elementos de aprobación (Gate 6.B)

- [ ] Tests de la subfase 6.B en verde vía MCP de Xcode.
- [ ] Combinar género + demografía + coincidencia parcial en Simulator devuelve resultados coherentes con esos criterios.
- [ ] Enviar el formulario vacío no dispara ninguna petición de red y muestra un mensaje claro.
- [ ] Las opciones de género/temática/demografía coinciden con las que devuelve la API en ese momento (no una lista desactualizada en código).

---

## Señal de validación y pivot trigger (Fase 6 completa)

- Validación: un usuario de prueba localiza, usando búsqueda avanzada, un manga que no recordaba el título exacto pero sí género y demografía.
- Pivot trigger: si el formulario avanzado resulta confuso en la prueba de uso por exceso de campos simultáneos, se simplifica dentro de esta fase (p. ej. ocultar campos avanzados tras una opción "más filtros") antes de pasar a Fase 7.

## Corte de contexto

Fase anidada: 6.A y 6.B se completan en la misma sesión de contexto. El contexto se limpia únicamente al cerrar el Gate de la 6.B.
