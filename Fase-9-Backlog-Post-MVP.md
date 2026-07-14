# Fase 9 — Backlog post-MVP (niveles avanzados)

Este artifact **no es una fase a ejecutar todavía**. Es el registro Lean de "desperdicio evitado" durante las Fases 0–8: candidatos que el enunciado sugiere como niveles superiores ("a partir de ahí, se puede implementar más funcionalidad") pero que no están detallados en `Statement.md` con la misma precisión que la versión básica, y que por tanto no deben construirse hasta validar el MVP y obtener el detalle de esos niveles.

## Prerrequisitos para activar cualquier ítem de este backlog

- Fase 8 cerrada (MVP validado).
- Detalle concreto del "nivel" a implementar (el enunciado anexo actualmente solo especifica en detalle la versión básica).

## Candidatos identificados a partir de las capacidades ya expuestas por la API pero no exigidas en el MVP

- Categorización combinada (varios géneros/temáticas/demografías a la vez en el listado, no solo en búsqueda avanzada).
- Ordenación configurable del listado más allá de `/list/bestMangas` (p. ej. por fecha, por número de tomos).
- Ficha de autor navegable (listar todos los mangas de un autor desde su propia ficha, usando `/list/mangaByAuthor`, ya soportado por la capa de red).
- Estadísticas de la colección del usuario (total de tomos comprados, progreso de lectura agregado) construidas sobre el repositorio de la Fase 2 sin cambios de esquema.
- Sincronización remota o exportación de la colección del usuario (fuera del alcance de "persistencia en local" exigido por la versión básica).
- Modo sin conexión con caché de listados ya vistos.

## Tratamiento de cada candidato cuando se active

Cada ítem activado desde este backlog se convierte en su propio artifact de fase, siguiendo exactamente la misma plantilla que las Fases 0–8 (hipótesis Lean, prerrequisitos, especificación funcional, plan técnico, desglose TDD, Gate de cierre, señal de validación), para no romper la trazabilidad Spec-Kit del proyecto.

## Corte de contexto

No aplica: este artifact es un documento vivo de backlog, no una fase con Gate propio.
