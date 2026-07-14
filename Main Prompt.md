
Deseo hacer una app. Anexo enunciado .md

Especificaciones:
**Swift 6.2** modo lenguaje. `SWIFT_STRICT_CONCURRENCY = complete`.
- **Approachable Concurrency = YES
- Default actor `nonisolated`. UI explícita `@MainActor
- Persistencia: SwiftData
- Framework testing: Swift Testing

Espeficiaciones arquitectura:
**Pattern MMVM-C
**enum APIRouter

Especificaciones Fase 0
**Bundle ID es com.uzupis.<NOMBRE_PROYECTO>

Especificaciones fases escritura código:
**No usar tipo Any
**NO force unwrap excepto en casos que sea requerido objetos no nil
**NO usar xcodebuild para builds, test, o errores. SOLO mcp de Xcode. PEDIR lanzarlo si no está disponible
**NO caminar archivo .pbxproj

Especificaciones experiencia de usuario:
**Los textos deben ser lo más legibles.
**La navegación debe ser lo más intuitiva.
**Tipografías deben tener archivos .ttf
**Seguir HIG de Apple para crear las UI

### Principios Lean aplicados

| Principio              | Cómo se aplica aquí                                                                |
| ---------------------- | ---------------------------------------------------------------------------------- |
| Build-Measure-Learn    | Cada MVP tiene hipótesis + señal de validación + pivot trigger                     |
| Minimum Viable Product | Solo se construye lo que el usuario de ese nivel puede usar                        |
| Validated Learning     | El gate de cada MVP incluye prueba con usuario real (o contigo mismo como usuario) |
| Eliminar desperdicio   | Nada de scaffolding que no sea necesario para el MVP actual                        |
| Entrega continua       | Cada MVP produce un `.ipa` / Simulator build demostrable                           |

Con base en especificaciones, principios Lean y anexo enunciado, proponer un plan por fases incluyendo subfases. 
NO escribir codigo.
Cumplir el estándar Spec-Kit para dsarrollar mediante TDD con Claude Code.

Dividir fases y ordenarlas para hacer un seguimiento y validación eficiente.
Por tarea dar prerrequisitos, tareas a realizar y elementos que aprueban cada tarea
apoyando la especificación en TDD para garantizar la estabilidad de cada fase
según avanzamos.
Cada subfase debe ser realizada dentro de limpieza de contexto 
salvo que sean tareas anidadas.

Generar distintos artifacts para cada una de las fases en Markdown,
de forma que sean revisadas y entregadas a Code para seguimiento por fases y tareas
hasta conseguir una aplicación de calidad.