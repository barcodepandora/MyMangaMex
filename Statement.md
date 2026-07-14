*My Manga Mex

# MY MANGA MEX

## Enunciado

### Introducción

Deberá crearse una app que consuma una API REST con más de 64.000 mangas publicados, donde el usuario podrá gestionar su colección guardando qué mangas tiene, por qué tomo lleva la colección y por qué tomo de los que tiene lleva la lectura.

### Niveles de desarrollo

La app se plantea como un desafío a varios niveles, donde hay un mínimo a entregar (producto mínimo viable) y a partir de ahí, se puede implementar más funcionalidad en la app sobre las versiones propuestas.

### Información general de los datos

Los mangas pueden tener distintos temas (themes) que definen la temática del mismo, como tipo School, Parody, Mecha (robots gigantes), Vampires, Music y muchos más.

También tienen géneros (genres) como Action, Adventure, Sci-Fi, Romance, Comedy y más.

De igual forma se clasifican por demografías en cuanto al público objetivo: Shounen (chicos jóvenes), Shoujo (chicas jóvenes), Seinen (adultos), Kids (niños) y Josei (mujeres adultas).

También hay autores, donde pueden aparecer asociados a su rol: si solo han escrito, solo han dibujado o han escrito y dibujado. Los mangas pueden tener 1 o n autores cada uno, por lo que siempre vendrán en una colección asociada. También sucede así con los géneros, demografías y temáticas, que pueden ser varias por cada manga.

Cualquier manga consultado vendrá con toda la información en estructuras de datos anidadas, con uno o varios autores, demografías, temáticas y géneros. También incluye URLs de consulta y una URL para una portada.

La estructura podrá ir en una colección o dentro de una subestructura como colección también cuando se devuelvan paginados:

```
{
    "titleJapanese": "ドラゴンボール",
    "authors": [
        {
            "id": "998C1B16-E3DB-47D1-8157-8389B5345D03",
            "firstName": "Akira",
            "lastName": "Toriyama",
            "role": "Story & Art"
        }
    ],
    "themes": [
        {
            "id": "ADC7CBC8-36B9-4E52-924A-4272B7B2CB2C",
            "theme": "Martial Arts"
        },
        {
            "id": "472FB2AE-13C0-4EEE-9A45-A7B75AC5DC29",
            "theme": "Super Power"
        }
    ],
    "title": "Dragon Ball",
    "id": 42,
    "endDate": "1995-05-23T00:00:00Z",
    "score": 8.41,
    "status": "finished",
    "demographics": [
        {
            "demographic": "Shounen",
            "id": "5E05BBF1-A72E-4231-9487-71CFE508F9F9"
        }
    ],
    "genres": [
        {
            "genre": "Action",
            "id": "72C8E862-334F-4F00-B8EC-E1E4125BB7CD"
        },
        {
            "genre": "Adventure",
            "id": "BE70E289-D414-46A9-8F15-928EAFBC5A32"
        },
        {
            "genre": "Comedy",
            "id": "F974BCB6-B002-44A6-A224-90D1E50595A2"
        },
        {
            "genre": "Sci-Fi",
            "id": "2DEDC015-82DA-4EF4-B983-F0F58C8F689E"
        }
    ],
    "startDate": "1984-11-20T00:00:00Z",
    "titleEnglish": "Dragon Ball",
    "chapters": 520,
 "mainPicture": "\"https://cdn.myanimelist.net/images/manga/
1/267793l.jpg\"",
    "sypnosis": "Bulma, a headstrong 16-year-old girl, is on a quest to
find the mythical Dragon Balls—seven scattered magic orbs that grant the
finder a single wish. She has but one desire in mind: a perfect …”,
    "background": "Dragon Ball has become one of the most successful
manga series of all time, with over 230 million copies sold worldwide
with 157 million in Japan alone…”,
    "url": "\"https://myanimelist.net/manga/42/Dragon_Ball\"",
    "volumes": 42
}

```

## Información de la API

Dada la alta cantidad de mangas en la base de datos, los endpoints generales devolverán los datos por paginación:

/list/mangas Devolverá 10 mangas por página, enviando la página 1.

/list/mangas?page=2&per=20 Devolverá la página 2, de 20 en 20.

/list/mangas?page=1&per=50 Devolverá 50 mangas para la página 1.

Hay que ser coherentes con la consulta para solicitar los datos que necesitamos y que tengan coherencia a lo que hemos solicitado, de forma que si pedimos la página 2 o 3, el parámetro per sea el mismo para todas las solicitudes para no devolver datos duplicados.

El JSON vendrá acompañado siempre, en estas consultas, de un árbol extra llamado metadata cuya estructura nos informará del total de datos de la consulta, la página devuelta y cuántos datos ha devuelto para esta.

```
"metadata": {
   "total": 64833,
   "page": 1,
   "per": 10
}

```

Por defecto, todas las consultas paginadas devuelven los datos con un parámetro per que es igual a 10.

Al navegar en la lista de mangas, cuando he mostrado en la app las tres cuartas partes del número mangas de la página, en ese momento la app carga los elementos de la página siguiente.

### Listados en endpoint (`/list`)

- `/mangas` — Devuelve todos los mangas de la base de datos
- `/bestMangas` — Mangas ordenados inversamente por puntuación
- `/authors` — Todos los autores de mangas en la base de datos (no paginada)
- `/demographics` — Array de cadenas con todas las demografías
- `/genres` — Array de cadenas con todos los géneros
- `/themes` — Array de cadenas con todas las temáticas

- `/mangaByGenre` — Devuelve todos los mangas de un género (solo uno).
  - Ejemplo: `/mangaByGenre/romance`
- `/mangaByDemographic` — Devuelve todos los mangas de una demografía
  - Ejemplo: `/mangaByDemographic/shoujo`
- `/mangaByTheme` — Devuelve todos los mangas de una temática
  - Ejemplo: `/mangaByDemographic/school`
- `/mangaByAuthor` — Devuelve los mangas de un autor (por su ID)
  - Ejemplo: `/mangaByAuthor/998C1B16-E3DB-47D1-8157-8389B5345D03`

### Búsquedas en endpoint (`/search`)

- `/mangasBeginsWith` — Devuelve los mangas cuyo título empieza por…
  - Ejemplo: `/mangasBeginsWith/dragon`
- `/mangasContains` — Devuelve los mangas que contienen en el título…
  - Ejemplo: `/mangasContains/ball`
- `/author` — Devuelve los autores que su primer nombre o último nombre…
  - Ejemplo: `/author/toriya`

- `/manga` — Devuelve el manga que corresponde con un ID exacto
  - Ejemplo: `/manga/42`

`/manga` — Método `POST` al que hay que enviar el siguiente JSON:

```
struct CustomSearch: Codable {
    var searchTitle: String?
    var searchAuthorFirstName: String?
    var searchAuthorLastName: String?
    var searchGenres: [String]?
    var searchThemes: [String]?
    var searchDemographics: [String]?
    var searchContains: Bool
}

```

Se le puede pasar título, primer nombre de autor, último nombre de autor, colección de géneros (como cadenas), de temáticas y de demográficos. El valor Bool establece cuando es false la búsqueda de valores que empiezan por título y autor, y con true que incluyan la cadena.

Es una búsqueda multipropósito por todos los datos posibles y que devuelve por paginación los resultados.


## Versión básica

En la versión de entrega obligada, el alumno deberá usar los endpoints que corresponden a los listados y búsquedas en la forma que considere oportuno, así como la persistencia en local de los datos de las colecciones de los usuarios, para ofrecer la siguiente funcionalidad:

- Consulta de cualquier referencia bibliografía de manga.

- Inclusión de al menos una categorización en los listados o filtros.

La app deberá tener un layout funcional para iPhone y iPad y deberá incluir siempre la imagen de la portada del manga que está en una URL.

Los datos que deberán guardarse sobre la colección del usuario son:

- Número de tomos comprados.
- Tomo por el que va leyendo.
- Si tiene o no la colección completa.

La aplicación debe mostrar al iniciars una pantalla splash, después una pantalla loading, y después la pantalla de lista de mangas. Puede usarse la misma imagen para splash y loading.

## Apuntes finales

El proyecto es totalmente libre a nivel de diseño, construcción, etc… El alumno puede hacer lo que quiera siempre y cuando cumpla con las directrices establecidas y se ciña a qué versión de la app va a entregar. No pasa nada si se intenta llegar a un nivel más avanzado y no se puede, se valorará con el nivel anterior que sí esté completado.

## Adicional

URL: https://mymanga-acacademy-5607149ebe3d.herokuapp.com/

En la URL `/docs` del raíz del servidor está disponible la especificación en Swagger, conforme a OpenAPI 3.0.
