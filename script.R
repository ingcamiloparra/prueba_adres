#1. Librerías para leer DB y analizar
library(writexl)
library(stringr)
library(dplyr)
library(tidyr)
library(DBI)
library(ggplot2)
library(RSQLite)

#2. Lectura DB y cargue de tablas a R
db_prueba_tecnica <- dbConnect(RSQLite::SQLite(), "prueba_tecnica.db")
tablas <- dbListTables(db_prueba_tecnica)
print(tablas)
prestadores <- dbReadTable(db_prueba_tecnica,"Prestadores")
municipios <- dbReadTable(db_prueba_tecnica, "Municipios")

#3. Normalización campos 
# Tabla municipios - Ajuste Departamento
municipios$depa_nombre <- gsub("[^A-Za-zÁÉÍÓÚáéíóúÜü ]", "", municipios$Departamento) #eliminar caracteres especiales
municipios$depa_nombre <- gsub("  ", "", municipios$depa_nombre) #eliminar dobles espacios
municipios$depa_nombre <- str_to_title(municipios$depa_nombre)

# Tabla municipios - Ajuste Municipio
municipios$muni_nombre <- gsub("[^A-Za-zÁÉÍÓÚáéíóúÜü ]", "", municipios$Municipio)
municipios$muni_nombre <- toupper(municipios$muni_nombre)


# Tabla prestadores - Ajuste Nombre Prestador
prestadores$nombre_prestador <- gsub("[^A-Za-zÁÉÍÓÚáéíóúÜü ]", "", prestadores$nombre_prestador)
prestadores$nombre_prestador <- toupper(prestadores$nombre_prestador)

# Tabla prestadores - Ajuste Razón Social
prestadores$razon_social <- gsub("[^A-Za-zÁÉÍÓÚáéíóúÜü ]", "", prestadores$razon_social)
prestadores$razon_social <- toupper(prestadores$razon_social)

# Tabla prestadores - Ajuste email
prestadores$email <- tolower(prestadores$email)

# Tabla prestadores - Ajuste representante legal
prestadores$rep_legal <- gsub("[^A-Za-zÁÉÍÓÚáéíóúÜü ]", "", prestadores$rep_legal)
prestadores$rep_legal <- str_to_title(prestadores$rep_legal)

#Ajuste de campos de fecha
prestadores$fecha_vencimiento <- as.Date(as.character(prestadores$fecha_vencimiento), format = "%Y%m%d")
prestadores$fecha_radicacion <- as.Date(as.character(prestadores$fecha_radicacion), format = "%Y%m%d")


#4. Merge tabla Prestadores y Municipios, para agregar los campos de superficie, población y región en la tabla Prestadores
merged <- merge(prestadores, municipios, by = c("depa_nombre", "muni_nombre"))
tabla_depurada <- select(merged, 
                         "depa_nombre", 
                         "muni_nombre", 
                         "Superficie",
                         "Poblacion",
                         "Irural",
                         "Region",
                         "codigo_habilitacion",
                         "nombre_prestador",
                         "nits_nit",
                         "razon_social",
                         "clpr_nombre",
                         "direccion",
                         "telefono",
                         "email",
                         "fecha_radicacion",
                         "fecha_vencimiento",
                         "fecha_cierre",
                         "dv",
                         "clase_persona",
                         "naju_codigo",
                         "naju_nombre",
                         "numero_sede_principal",
                         "fecha_corte_REPS",
                         "telefono_adicional",
                         "email_adicional"
                         )

# Ajuste municipios
tabla_depurada$muni_nombre <- gsub("  ", "",tabla_depurada$muni_nombre)
tabla_depurada$muni_nombre <- str_to_title(tabla_depurada$muni_nombre)

#5. Resumen información tablas
resumen_tabla_depurada <- summary(tabla_depurada)
resumen_tabla_depurada


#6. Análisis
conteo_naju_nombre_por_departamento <- tabla_depurada %>%
  group_by(depa_nombre, naju_nombre) %>%
  count()

conteo_casos_por_departamento <- tabla_depurada %>%
  group_by(depa_nombre, Region) %>%
  count()

#Radicados por vencer
fecha_actual <- Sys.Date()
radicados_por_departamento <- aggregate(tabla_depurada$fecha_vencimiento <= fecha_actual & is.na(tabla_depurada$fecha_cierre), 
                                        by = list(tabla_depurada$depa_nombre), 
                                        FUN = sum)
colnames(radicados_por_departamento) <- c("depa_nombre", "radicados_a_vencer")

#Radicados por vencer top 10 departamentos + gráfico
radicados_por_departamento_ordenados <- radicados_por_departamento[order(-radicados_por_departamento$radicados_a_vencer), ]
top_10_departamentos <- radicados_por_departamento_ordenados[1:10, ]
grafico <- ggplot(top_10_departamentos, aes(x = reorder(depa_nombre, -radicados_a_vencer), y = radicados_a_vencer)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Top 10 Departamentos con Mayor Cantidad de Radicados a Vencer",
       x = "Departamento",
       y = "Cantidad de Radicados a Vencer") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#Exportar tablas a Excel
write_xlsx(radicados_por_departamento, "outputs/cantidad_radicados_por_departamento_a_vencer.xlsx")
write_xlsx(conteo_naju_nombre_por_departamento, "outputs/cantidad_naju_nombre_por_departamento.xlsx")
write_xlsx(tabla_depurada, "outputs/cantidad_naju_nombre_por_departamento.xlsx")
ggsave("outputs/top10_departamentos_radicados_a_vencer.png", plot = grafico, width = 6, height = 4, units = "in", dpi = 300)



