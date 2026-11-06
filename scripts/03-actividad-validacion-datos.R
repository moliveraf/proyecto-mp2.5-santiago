# ============================================================
# ACTIVIDAD SEMANAL: DICCIONARIO Y VALIDACIÓN DE DATOS
# Proyecto: Análisis de MP2.5 en Santiago de Chile
# Datos: Estaciones SINCA, marzo-septiembre de 2026
# ============================================================

# 1. CARGAR LIBRERÍAS

library(tidyverse)
library(lubridate)

# 2. COMPROBAR LOS ARCHIVOS DISPONIBLES

list.files("datos/sinca")

# 3. IMPORTAR DATOS DE LAS ESTACIONES SINCA

santiago <- read_delim(
  "datos/sinca/SINCA_Parque_OHiggins_MP25_2026.csv",
  delim = ";"
) |>
  mutate(comuna = "Santiago")

cerro_navia <- read_delim(
  "datos/sinca/SINCA_Cerro_Navia_MP25_2026.csv",
  delim = ";"
) |>
  mutate(comuna = "Cerro Navia")

puente_alto <- read_delim(
  "datos/sinca/SINCA_Puente_Alto_MP25_2026.csv",
  delim = ";"
) |>
  mutate(comuna = "Puente Alto")

# Comprobar las dimensiones
dim(santiago)
dim(cerro_navia)
dim(puente_alto)

# 4. UNIR LOS DATOS DE LAS TRES ESTACIONES SINCA

datos_mp25 <- bind_rows(
  santiago,
  cerro_navia,
  puente_alto
)

# Verificar el número de registros por comuna
datos_mp25 |>
  count(comuna)

# Visualizar la nueva base de datos llamada datos_mp25
View(datos_mp25)

# 5. PREPARAR LAS VARIABLES PARA LA VALIDACIÓN

datos_mp25 <- datos_mp25 |>
  mutate(
    mp25 = coalesce(
      `Registros validados`,
      `Registros preliminares`,
      `Registros no validados`
    ),
    fecha_hora = ymd_hm(
      paste(`FECHA (YYMMDD)`, `HORA (HHMM)`)
    )
  )

# Comprobar las tres variables seleccionadas
datos_mp25 |>
  select(comuna, mp25, fecha_hora) |>
  head(10)

# 6. CREAR EL MINI DICCIONARIO DE DATOS

diccionario <- tribble(
  ~variable, ~tipo, ~valores_esperados, ~NA_permitido,
  "comuna", "Categórica",
  "Santiago, Cerro Navia, Puente Alto", "No",
  "mp25", "Numérica",
  "2-200 µg/m3; revisar <2 o >200", "Sí",
  "fecha_hora", "Fecha-hora",
  "01/03/2026 al 30/09/2026", "No"
)

# Mostrar el diccionario
diccionario

# 7. CREAR FUNCIÓN DE VALIDACIÓN DE DATOS

validar_mp25 <- function(datos) {

  # Estructural: comunas permitidas (sin NA)
  comuna_ok <- all(
    !is.na(datos$comuna) &
      datos$comuna %in% c(
        "Santiago", "Cerro Navia", "Puente Alto"
      )
  )

  # Contenido: concentraciones entre 2 y 200 µg/m3
  # Se permiten valores NA
  mp25_ok <- all(
    datos$mp25 >= 2 & datos$mp25 <= 200,
    na.rm = TRUE
  )

  # Contenido: fechas dentro del periodo estudiado
  # No se permiten valores NA
  fecha_ok <- all(
    !is.na(datos$fecha_hora) &
      as.Date(datos$fecha_hora) >= as.Date("2026-03-01") &
      as.Date(datos$fecha_hora) <= as.Date("2026-09-30")
  )

  # Mostrar resultados
  marca <- function(x) ifelse(isTRUE(x), "OK", "FALLA")

  cat("Comuna valida (estructural): ",
      marca(comuna_ok), "\n")

  cat("MP2.5 entre 2 y 200 (contenido): ",
      marca(mp25_ok), "\n")

  cat("Fecha valida (contenido): ",
      marca(fecha_ok), "\n")
}

# 8. APLICAR LA FUNCIÓN DE VALIDACIÓN

validar_mp25(datos_mp25)

# 9. IDENTIFICAR REGISTROS FUERA DEL RANGO

datos_flags <- datos_mp25 |>
  mutate(
    alerta_mp25 = !is.na(mp25) &
      (mp25 < 2 | mp25 > 200)
  )

# Contar alertas por comuna
datos_flags |>
  group_by(comuna) |>
  summarise(
    menores_2 = sum(mp25 < 2, na.rm = TRUE),
    mayores_200 = sum(mp25 > 200, na.rm = TRUE),
    total_alertas = sum(alerta_mp25),
    .groups = "drop"
  )

# 10. IDENTIFICAR CONCENTRACIONES SUPERIORES A 200

datos_flags |>
  filter(mp25 > 200) |>
  select(comuna, fecha_hora, mp25)
