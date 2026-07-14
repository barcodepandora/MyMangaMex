# Constitución del proyecto — My Manga Mex

Este documento es la fuente para `/speckit.constitution`. Define los principios no negociables de todas las fases. Cualquier tarea que los contradiga se rechaza en su Gate, sin excepción, salvo que una excepción esté explícitamente prevista aquí.

## 1. Identidad del proyecto

- Nombre: My Manga Mex (nombre de paquete asumido: `MyMangaMex`).
- Bundle ID: `com.uzupis.MyMangaMex`.
- API remota: `https://mymanga-acacademy-5607149ebe3d.herokuapp.com/`, documentada en OpenAPI 3.0 en `/docs`.

## 2. Lenguaje y concurrencia

- Swift 6.2, modo de lenguaje Swift 6.2.
- `SWIFT_STRICT_CONCURRENCY = complete` en todos los targets (app y tests).
- `Approachable Concurrency = YES`.
- Aislamiento por defecto: `nonisolated`. Todo lo que toque UI se marca explícitamente `@MainActor` (Views, ViewModels que publican estado de UI, Coordinators de navegación).
- Cualquier tarea que introduzca una advertencia o error de concurrencia estricta no pasa el Gate.

## 3. Persistencia

- SwiftData como única capa de persistencia local. No se usan otras soluciones (Core Data directo, ficheros propios, UserDefaults para datos de colección).

## 4. Testing

- Framework: Swift Testing (no XCTest para tests nuevos).
- Todo comportamiento observable descrito en una "Especificación funcional" debe tener al menos un test que falle antes de implementarse (ciclo Red → Green → Refactor).

## 5. Arquitectura

- Patrón MVVM-C: Model / View / ViewModel / Coordinator. Los Coordinators son responsables de toda la navegación; las Views no navegan directamente.
- Toda comunicación con la API pasa por un único `enum APIRouter` que centraliza rutas, método HTTP, parámetros y construcción del `URLRequest`. No se construyen URLs manualmente fuera de esa capa.

## 6. Reglas de código (aplican desde la Fase 0 hasta el cierre del MVP)

- Prohibido el tipo `Any`. Si algo parece requerir `Any`, se modela con un tipo, protocolo o enum concreto.
- Prohibido el force unwrap (`!`), salvo en los casos estrictamente donde el objeto no puede ser nil por invariante del sistema (y aun así, documentado en el propio Gate de la tarea que lo introduce).
- No se usa `xcodebuild` por línea de comandos para compilar, testear o diagnosticar errores. Toda compilación, ejecución de tests y lectura de errores se hace exclusivamente a través del MCP de Xcode. Si el MCP de Xcode no está disponible en la sesión, se debe pedir explícitamente que se active antes de continuar con cualquier tarea de implementación.
- No se edita ni se navega directamente el archivo `.pbxproj`. Cualquier cambio de configuración de proyecto se hace a través de las herramientas del MCP de Xcode.

## 7. Experiencia de usuario

- Legibilidad de texto como prioridad: contraste, tamaño dinámico (Dynamic Type) y jerarquía tipográfica claros en cada pantalla.
- Navegación intuitiva: cada pantalla tiene una única acción primaria evidente y un camino de vuelta claro.
- Tipografía: fuentes propias en archivos `.ttf` embebidos en el proyecto, no fuentes del sistema salvo fallback.
- Cumplimiento del Human Interface Guidelines (HIG) de Apple en layout, controles y patrones de navegación, para iPhone y iPad.

## 8. Principios Lean aplicados a todas las fases

| Principio | Aplicación en este proyecto |
|---|---|
| Build-Measure-Learn | Cada fase declara una hipótesis y una señal de validación medible antes de construirse. |
| Minimum Viable Product | Cada fase construye solo lo que el nivel de entrega actual (MVP obligatorio) necesita. |
| Validated Learning | El Gate de cada fase incluye una prueba de uso real (o autoevaluación del propio desarrollador como usuario). |
| Eliminar desperdicio | No se añade scaffolding, pantalla o dato que no sirva a la fase en curso. Todo lo demás va a la Fase 9 (backlog). |
| Entrega continua | Cada fase deja un build ejecutable en Simulator (o `.ipa`) demostrable, no solo código fusionado. |

## 9. Definición de "fase cerrada"

Una fase se considera cerrada únicamente cuando:

1. Todos los tests definidos en su desglose de tareas están en verde.
2. El build compila y corre en Simulator (o dispositivo) vía MCP de Xcode, sin warnings de concurrencia.
3. Todos los elementos del Gate de cierre de la fase están marcados como cumplidos.
4. La señal de validación Lean de la fase se ha registrado (aunque sea informalmente, como nota del propio desarrollador-usuario).

Solo entonces se puede limpiar el contexto y abrir la siguiente fase.
