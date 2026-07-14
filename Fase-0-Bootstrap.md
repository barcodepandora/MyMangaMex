# Fase 0 — Bootstrap del proyecto

## Hipótesis Lean

Un proyecto Xcode correctamente configurado (Swift 6.2 estricto, MVVM-C, targets de test) es condición necesaria para que cualquier fase posterior pueda aplicar TDD sin fricción. Se valida si Fase 1 puede empezar sin tener que tocar configuración de proyecto.

## Prerrequisitos

- `01-Constitucion.md` revisada y aceptada.
- MCP de Xcode disponible en la sesión de Claude Code. Si no lo está, se solicita expresamente su activación antes de crear el proyecto.
- Nombre de proyecto confirmado (`MyMangaMex` por defecto).

## Especificación funcional

- Al finalizar la fase existe un proyecto iOS que arranca en Simulator mostrando una pantalla en blanco controlada por un Coordinator raíz (sin contenido de producto todavía).
- El proyecto soporta iPhone y iPad como destinos de build.
- Existe un target de tests con Swift Testing capaz de ejecutar al menos un test trivial en verde.

## Plan técnico

- Estructura de carpetas por capa MVVM-C: `App/`, `Coordinators/`, `Features/<Feature>/{Model,View,ViewModel}`, `Networking/`, `Persistence/`, `Resources/Fonts/`, `Tests/`.
- Un `AppCoordinator` `@MainActor` como punto único de entrada de navegación, instanciado desde el punto de arranque de la app.
- Configuración de build settings: modo de lenguaje Swift 6.2, `SWIFT_STRICT_CONCURRENCY = complete`, Approachable Concurrency activado, deployment target mínimo consistente con SwiftData.
- Target de tests unitarios usando Swift Testing, sin dependencias de XCTest.
- Inicialización de Spec-Kit en el repositorio (estructura `.specify/`) para que las fases siguientes puedan consumirse como specs.

## Desglose de tareas TDD

### Tarea 0.1 — Crear proyecto Xcode vía MCP

- Red: no aplica (tarea de infraestructura, no de comportamiento testeable); el criterio de "rojo" es que el proyecto no existe o no compila.
- Green: proyecto creado con bundle id `com.uzupis.MyMangaMex`, compila en Simulator para iPhone y iPad vía MCP de Xcode.
- Refactor: limpiar plantillas/comentarios generados automáticamente que no correspondan al proyecto.

### Tarea 0.2 — Configurar concurrencia estricta y modo de lenguaje

- Red: build con configuración por defecto (concurrencia no estricta).
- Green: build settings actualizados; compilar el proyecto vacío no produce warnings de concurrencia.
- Refactor: documentar en el propio proyecto (comentario de configuración o nota del artifact) que el aislamiento por defecto es `nonisolated` y la UI es `@MainActor` explícito.

### Tarea 0.3 — Esqueleto MVVM-C y Coordinator raíz

- Red: test que instancia `AppCoordinator` y falla porque el tipo no existe.
- Green: `AppCoordinator` `@MainActor` implementado, capaz de presentar una vista raíz vacía; test anterior en verde.
- Refactor: extraer protocolo de Coordinator si se detecta repetición evidente (sin sobre-diseñar para una única fase).

### Tarea 0.4 — Target de test con Swift Testing

- Red: test trivial (`#expect(true)`) que no compila porque el target no existe.
- Green: target de tests creado y corriendo ese test en verde vía MCP de Xcode.
- Refactor: nombrar el target y organizar carpeta de tests siguiendo la misma estructura por feature que el target de app.

### Tarea 0.5 — Inicializar Spec-Kit en el repositorio

- Red: no existe estructura `.specify/` ni constitución registrada.
- Green: `/speckit.constitution` ejecutado con el contenido de `01-Constitucion.md`; estructura `.specify/` presente en el repositorio.
- Refactor: ninguno necesario en esta tarea.

## Elementos de aprobación (Gate de cierre de Fase 0)

- [ ] Proyecto compila y corre en Simulator de iPhone y de iPad sin warnings de concurrencia, verificado vía MCP de Xcode.
- [ ] Bundle ID es exactamente `com.uzupis.MyMangaMex`.
- [ ] Target de tests Swift Testing ejecuta al menos un test en verde.
- [ ] `AppCoordinator` existe, es `@MainActor` y es el único punto de navegación raíz.
- [ ] No existe ningún uso de `Any` ni force unwrap en el código generado.
- [ ] `.specify/memory/constitution.md` refleja el contenido de `01-Constitucion.md`.

## Señal de validación y pivot trigger

- Validación: se puede abrir Fase 1 sin necesidad de volver a tocar configuración de Xcode.
- Pivot trigger: si el MCP de Xcode no permite alguna operación de configuración necesaria, se detiene la fase y se pide intervención manual antes de continuar (no se recurre a `xcodebuild`).

## Corte de contexto

Fase cerrable en una sola sesión con contexto limpio al finalizar. No tiene subfases anidadas.
