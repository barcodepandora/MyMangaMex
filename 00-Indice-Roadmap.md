# My Manga Mex — Índice y Roadmap por Fases

Plan de desarrollo generado a partir de `Statement.md` (enunciado del proyecto) y `Main Prompt.md` (especificaciones técnicas y de proceso), siguiendo el estándar **Spec-Kit** (`constitution → specify → clarify → plan → tasks → analyze → implement → checklist`) para desarrollo dirigido por especificación (SDD) con TDD, ejecutado mediante Claude Code.

Este índice **no contiene código**. Cada fase es un artifact Markdown independiente, autocontenido, pensado para poder cerrarse con limpieza de contexto salvo que se indique explícitamente que tiene tareas anidadas.

## Cómo usar estos artifacts con Claude Code / Spec-Kit

1. Ejecutar una vez `/speckit.constitution` usando `01-Constitucion.md` como fuente — fija los principios no negociables del proyecto.
2. Para cada fase, en orden: `/speckit.specify` (sección "Especificación funcional"), `/speckit.clarify` si quedan ambigüedades, `/speckit.plan` (sección "Plan técnico"), `/speckit.tasks` (sección "Desglose de tareas TDD"), `/speckit.implement` tarea a tarea, `/speckit.checklist` contra "Elementos de aprobación".
3. Una fase no se declara cerrada hasta que su **Gate de cierre** está satisfecho. Solo entonces se limpia el contexto y se abre la siguiente fase en sesión nueva.
4. Ninguna fase empieza sin que su(s) prerrequisito(s) estén marcados como cerrados.

## Supuesto de nomenclatura (a confirmar por el usuario)

`<NOMBRE_PROYECTO>` = `MyMangaMex` → Bundle ID: `com.uzupis.MyMangaMex`. Se asume por continuidad con el título del enunciado ("MY MANGA MEX"); si se prefiere otro nombre, es el único valor a sustituir en Fase 0.

## Alcance obligatorio vs. opcional

El enunciado define una **versión básica obligatoria (MVP)** y "niveles" superiores no detallados en el documento anexo. Por principio Lean de "eliminar desperdicio", las Fases 0–8 cubren únicamente lo obligatorio. La Fase 9 es un backlog de candidatos post-MVP, sin construir hasta validar el MVP.

## Roadmap y dependencias

| Fase | Artifact | Objetivo | Prerrequisito | Tipo de cierre |
|---|---|---|---|---|
| 0 | `Fase-0-Bootstrap.md` | Proyecto Xcode, config Swift 6.2, esqueleto MVVM-C, Spec-Kit init | Constitución aprobada | Contexto limpio |
| 1 | `Fase-1-Networking.md` | `enum APIRouter`, cliente HTTP, DTOs Codable, errores | Fase 0 cerrada | Contexto limpio |
| 2 | `Fase-2-Persistencia.md` | Modelos SwiftData de colección de usuario + repositorio | Fase 0 cerrada (paralela a Fase 1) | Contexto limpio |
| 3 | `Fase-3-Arranque-UX.md` | Coordinator raíz, Splash, Loading, transición a listado | Fases 1 y 2 cerradas | Contexto limpio |
| 4 | `Fase-4-Listado-Mangas.md` | Listado paginado + scroll infinito 75% + categorización + portada | Fase 3 cerrada | Anidada (2 subfases) |
| 5 | `Fase-5-Detalle-Manga.md` | Detalle completo + edición de datos de colección | Fase 4 cerrada | Contexto limpio |
| 6 | `Fase-6-Busqueda.md` | Búsquedas simples + búsqueda avanzada POST | Fase 4 cerrada (paralela a Fase 5) | Anidada (2 subfases) |
| 7 | `Fase-7-Adaptabilidad-UI.md` | Layout iPhone/iPad, tipografías .ttf, HIG, accesibilidad | Fases 5 y 6 cerradas | Contexto limpio |
| 8 | `Fase-8-QA-Cierre-MVP.md` | Validación end-to-end, build demostrable, gate final MVP | Fase 7 cerrada | Contexto limpio |
| 9 | `Fase-9-Backlog-Post-MVP.md` | Candidatos de siguientes niveles (no se construyen ahora) | Fase 8 cerrada | N/A (backlog) |

## Diagrama de dependencias

```
Constitución
     │
   Fase 0
   ┌─┴─┐
 Fase 1 Fase 2
   └─┬─┘
   Fase 3
     │
   Fase 4
   ┌─┴─┐
 Fase 5 Fase 6
   └─┬─┘
   Fase 7
     │
   Fase 8 (gate MVP)
     │
   Fase 9 (backlog, no bloquea el MVP)
```

## Convenciones usadas en cada artifact de fase

- **Hipótesis Lean**: qué se valida con esta fase (Build-Measure-Learn).
- **Prerrequisitos**: fases/artefactos que deben estar cerrados antes de empezar.
- **Especificación funcional**: qué debe hacer el sistema, en términos de comportamiento observable, sin código.
- **Plan técnico**: capas MVVM-C afectadas y contratos, sin código.
- **Desglose de tareas TDD**: por tarea, ciclo Red → Green → Refactor con criterio de aceptación verificable.
- **Elementos de aprobación (Gate)**: condiciones objetivas para dar la tarea/fase por cerrada.
- **Señal de validación y pivot trigger**: métrica o evidencia Lean que confirma o cuestiona la hipótesis.
- **Corte de contexto**: si la fase se puede cerrar en una sesión limpia o si tiene subfases anidadas que deben completarse juntas.
