# Fase 8 — QA y cierre del MVP

## Hipótesis Lean

Un MVP solo cuenta como "entregado" bajo Lean si produce un build demostrable y validado end-to-end, no solo código que compila fase a fase. Se valida si el build resultante puede entregarse a un tercero (evaluador/usuario) sin acompañamiento del desarrollador.

## Prerrequisitos

- Fase 7 cerrada (todas las pantallas del MVP funcionales y adaptadas).
- Fases 0–6 con sus Gates cerrados (ninguna deuda pendiente declarada como "se revisa después").

## Especificación funcional

- Existe un recorrido completo verificable: abrir app → splash → loading → listado con portadas → aplicar filtro de categorización → abrir detalle → registrar/editar datos de colección → volver → buscar por título → buscar de forma avanzada, todo sin crash ni estado inconsistente.
- El comportamiento en iPhone y en iPad es equivalente en funcionalidad (aunque distinto en layout, según Fase 7).
- La app produce un build ejecutable en Simulator (y, si el entorno lo permite, un `.ipa`) que constituye la entrega demostrable del nivel MVP del enunciado.

## Plan técnico

- No se introduce funcionalidad nueva en esta fase: es exclusivamente verificación, corrección de defectos encontrados y empaquetado.
- Cualquier defecto encontrado se corrige con el mismo ciclo TDD (test que reproduce el defecto en rojo, corrección en verde) dentro de esta fase, referenciando la fase de origen del defecto si procede.
- Recolección de evidencia de cumplimiento de cada Gate de las Fases 0–7 en un único documento de cierre (este mismo artifact).

## Desglose de tareas TDD

### Tarea 8.1 — Suite de tests completa en verde

- Red: ejecución de la suite completa (Fases 0–7) vía MCP de Xcode; se documenta cualquier test en rojo como estado inicial.
- Green: todos los tests en verde, incluidos los de regresión introducidos por defectos encontrados en esta fase.
- Refactor: eliminar tests obsoletos o redundantes detectados durante la consolidación.

### Tarea 8.2 — Recorrido end-to-end manual en iPhone

- Red: ejecución del recorrido completo descrito en la especificación funcional en Simulator de iPhone; se documentan fallos encontrados como estado "rojo".
- Green: recorrido completo sin crash ni estado inconsistente; cada fallo encontrado se corrige con su propio test de regresión (ciclo TDD) antes de marcar esta tarea como cerrada.
- Refactor: ninguno adicional previsto.

### Tarea 8.3 — Recorrido end-to-end manual en iPad

- Red: mismo recorrido en Simulator de iPad; se documentan fallos encontrados como estado "rojo".
- Green: recorrido completo sin crash ni estado inconsistente, con el layout específico de iPad de la Fase 7 funcionando en todo el recorrido.
- Refactor: ninguno adicional previsto.

### Tarea 8.4 — Verificación de reglas de código (Gate transversal)

- Red: búsqueda en el proyecto de usos de `Any` y de force unwrap no documentado; cualquier hallazgo es estado "rojo".
- Green: cero usos de `Any`, y todo force unwrap restante documentado y justificado según la sección 6 de la constitución.
- Refactor: sustituir por alternativas seguras cualquier hallazgo que no esté justificable.

### Tarea 8.5 — Build demostrable

- Red: no existe aún un build empaquetado como entrega.
- Green: build generado y ejecutado vía MCP de Xcode en Simulator (y `.ipa` si el flujo del entorno lo soporta), correspondiente exactamente al estado verificado en las tareas 8.2 y 8.3.
- Refactor: ninguno adicional previsto.

## Elementos de aprobación (Gate de cierre de Fase 8 — Gate del MVP)

- [ ] Suite de tests completa (Fases 0–7) en verde vía MCP de Xcode.
- [ ] Recorrido end-to-end completo sin crash en iPhone y en iPad.
- [ ] Cero usos de `Any` en el proyecto; todo force unwrap restante está documentado y justificado.
- [ ] Todos los Gates de las Fases 0–7 están marcados como cumplidos (verificación cruzada contra cada artifact).
- [ ] Build demostrable disponible (Simulator y/o `.ipa`).
- [ ] Los tres datos de colección del enunciado (tomos comprados, tomo de lectura, colección completa) son consultables y editables de extremo a extremo.
- [ ] Existe al menos una categorización funcional en listados/filtros, tal como exige la versión básica del enunciado.

## Señal de validación y pivot trigger

- Validación: un usuario real (o el propio desarrollador actuando como tal) completa el recorrido end-to-end del enunciado sin intervención del equipo de desarrollo y confirma que puede "consultar cualquier referencia bibliográfica de manga" y "gestionar su colección".
- Pivot trigger: si la prueba de uso revela que falta algo exigido explícitamente por la versión básica del enunciado (no un "nivel" superior), se trata como defecto de esta fase y se corrige antes de declarar el MVP cerrado; si lo que falta pertenece a un nivel superior, se traslada a Fase 9 sin bloquear el cierre.

## Corte de contexto

Fase cerrable en una sola sesión con contexto limpio al finalizar. Marca el cierre formal del MVP obligatorio del enunciado.
