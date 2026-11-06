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
  "> 0; alerta si = 0 o supera umbral por estación", "Sí",
  "fecha_hora", "Fecha-hora",
  "01/03/2026 al 30/09/2026", "No"
)

diccionario

# 7. DEFINIR UMBRALES DE ALERTA POR ESTACIÓN SINCA

umbrales_mp25 <- tribble(
  ~comuna,       ~umbral,
  "Cerro Navia", 114.1,
  "Santiago",     85.3,
  "Puente Alto",  75.4
)

# Mostrar los umbrales
umbrales_mp25

# 8. CREAR FUNCIÓN DE VALIDACIÓN DE DATOS

validar_mp25 <- function(datos) {

  datos |>
    left_join(umbrales_mp25, by = "comuna") |>
    mutate(
      # Comprobar que la comuna sea válida
      comuna_ok = !is.na(comuna) &
        comuna %in% c("Santiago", "Cerro Navia", "Puente Alto"),

      # Comprobar que la fecha esté en el período estudiado
      fecha_ok = !is.na(fecha_hora) &
        as.Date(fecha_hora) >= as.Date("2026-03-01") &
        as.Date(fecha_hora) <= as.Date("2026-09-30"),

      # Comprobar concentraciones negativas
      mp25_ok = is.na(mp25) | mp25 >= 0,

      # Identificar concentraciones iguales a cero
      alerta_cero = !is.na(mp25) & mp25 == 0,

      # Identificar concentraciones elevadas
      alerta_alta = !is.na(mp25) &
        !is.na(umbral) & mp25 > umbral
    )
}

# 9. APLICAR LA FUNCIÓN DE VALIDACIÓN

datos_validados <- validar_mp25(datos_mp25)

# Mostrar las primeras 10 observaciones y sus resultados
datos_validados |>
  select(
    comuna, fecha_hora, mp25, umbral,
    comuna_ok, fecha_ok, mp25_ok,
    alerta_cero, alerta_alta
  ) |>
  head(10)

# 10. RESUMEN DE VALIDACIÓN POR COMUNA

resumen_validacion <- datos_validados |>
  group_by(comuna) |>
  summarise(
    total_registros = n(),
    fechas_invalidas = sum(!fecha_ok),
    mp25_negativos = sum(!mp25_ok),
    mp25_faltantes = sum(is.na(mp25)),
    alertas_cero = sum(alerta_cero),
    alertas_altas = sum(alerta_alta),
    .groups = "drop"
  )

# Mostrar el resumen
resumen_validacion

# Mostrar las alertas por estación SINCA

resumen_validacion |>
  select(comuna, alertas_cero, alertas_altas)

# 11. COMPROBAR LA VALIDACIÓN DE LAS COMUNAS

datos_validados |>
  summarise(
    total_registros = n(),
    comunas_validas = sum(comuna_ok, na.rm = TRUE),
    comunas_invalidas = sum(!comuna_ok, na.rm = TRUE)
  )
