# Prueba Técnica ADRES - README

## 1. Librerías Utilizadas
Se han utilizado las siguientes librerías de R para leer la base de datos y realizar análisis de datos:
- `stringr`
- `dplyr`
- `tidyr`
- `DBI`
- `RSQLite`

## 2. Lectura de la Base de Datos y Carga de Tablas en R
Se establece la conexión con la base de datos y se cargan las tablas `Prestadores` y `Municipios` en R.

## 3. Normalización de Campos
Se realizan ajustes en los campos de las tablas `Municipios` y `Prestadores` para normalizar los datos. Se eliminan caracteres especiales, se convierten a mayúsculas o minúsculas según sea necesario, y se ajustan los campos de fecha al formato de fecha adecuado.

## 4. Combinación de Tablas (`Merge`)
Se combinan las tablas `Prestadores` y `Municipios` utilizando la función `merge()`, agregando los campos de superficie, población y región en la tabla `Prestadores`. Se seleccionan únicamente las columnas relevantes para el análisis posterior.

## 5. Resumen de la Información de las Tablas
Se genera un resumen de la tabla resultante del paso anterior utilizando la función `summary()`. Esto proporciona una visión general de la estructura y distribución de los datos.

## 6. Análisis de Datos
Se realiza un análisis exploratorio de los datos, incluyendo conteos por categoría y conteos de radicados por vencer por departamento.

## Ejecución del Código
Es importante ejecutar el código en orden secuencial para garantizar que todas las dependencias estén correctamente cargadas y que las operaciones se realicen en el contexto adecuado.
