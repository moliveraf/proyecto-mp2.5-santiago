# ============================================================
# ACTIVIDAD SEMANAL 9: GROUP BY Y NEST
# Comparación de MP2.5 entre comunas de Santiago
# Datos de estaciones SINCA, marzo-septiembre de 2026
# ============================================================

library(tidyverse)
library(lubridate)

# Comprobar que R encuentre los archivos CSV
list.files("datos/sinca")


# 1. IMPORTAR DATOS DE LAS TRES ESTACIONES SINCA

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


# Verificar la importación de datos
dim(santiago)
dim(cerro_navia)
dim(puente_alto)

names(santiago)


# 2. UNIR LOS REGISTROS DE LAS TRES COMUNAS

datos_mp25 <- bind_rows(
  santiago,
  cerro_navia,
  puente_alto
)

# Verificar los registros por comuna
datos_mp25 |>
  count(comuna)


# 3. Preparar las concentraciones y las fechas

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

# Comprobar las nuevas variables
datos_mp25 |>
  select(comuna, fecha_hora, mp25) |>
  head(10)


# 4. AGRUPAR LOS REGISTROS POR COMUNA CON GROUP_BY Y NEST

datos_agrupados <- datos_mp25 |>
  group_by(comuna) |>
  nest()

# Visualizar las tablas agrupadas
datos_agrupados

# Comprobar la información de la primera tabla interna
datos_agrupados$data[[1]]


# 5. CALCULAR ESTADÍSTICAS POR COMUNA CON MAP

resumir_mp25 <- function(datos) {
  datos |>
    summarise(
      n = sum(!is.na(mp25)),
      promedio = mean(mp25, na.rm = TRUE),
      mediana = median(mp25, na.rm = TRUE),
      desviacion = sd(mp25, na.rm = TRUE)
    )
}

resultados <- datos_agrupados |>
  ungroup() |>
  mutate(resumen = map(data, resumir_mp25))

resultados


# 6. EXTRAER LAS ESTADÍSTICAS CON UNNEST

tabla_resumen <- resultados |>
  select(comuna, resumen) |>
  unnest(resumen)

tabla_resumen


# 7. GRÁFICO COMPARATIVO DEL MP2.5 PROMEDIO

grafico_promedios <- ggplot(
  tabla_resumen,
  aes(x = comuna, y = promedio, fill = comuna)
) +
  geom_col(width = 0.6) +
  scale_fill_manual(values = c(
    "Cerro Navia" = "#287D8E",
    "Puente Alto" = "#E3A44B",
    "Santiago" = "#735B9C"
  )) +
  labs(
    title = "Concentración promedio de MP2.5 por comuna",
    subtitle = "Estaciones SINCA, marzo-septiembre de 2026",
    x = "Comuna",
    y = "MP2.5 promedio (µg/m³)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# Mostrar gráfico de promedios
grafico_promedios


# Guardar gráfico comparativo de estaciones SINCA

ggsave(
  "imagenes/comparacion_mp25_estaciones_SINCA_2026.png",
  plot = grafico_promedios,
  width = 8,
  height = 5,
  dpi = 300
)


# 8. BOXPLOT DE MP2.5 POR COMUNA

grafico_boxplot <- ggplot(
  datos_mp25,
  aes(x = comuna, y = mp25, fill = comuna)
) +
  geom_boxplot(na.rm = TRUE) +
  scale_fill_manual(values = c(
    "Cerro Navia" = "#287D8E",
    "Puente Alto" = "#E3A44B",
    "Santiago" = "#735B9C"
  )) +
  labs(
    title = "Distribución de MP2.5 por comuna",
    subtitle = "Estaciones SINCA, marzo-septiembre de 2026",
    x = "Comuna",
    y = "MP2.5 (µg/m³)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# Mostrar boxplot
grafico_boxplot


# Guardar boxplot de estaciones SINCA

ggsave(
  "imagenes/boxplot_mp25_estaciones_SINCA_2026.png",
  plot = grafico_boxplot,
  width = 8,
  height = 5,
  dpi = 300
)

datos_agrupados
