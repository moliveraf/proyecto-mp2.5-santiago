# Análisis exploratorio de datos de MP2.5
# Estación Parque O'Higgins - SINCA
# Año 2026

library(tidyverse)


getwd()

# Importar datos
datos_mp25 <- read_delim(
  "datos/sinca/SINCA_Parque_OHiggins_MP25_2026.csv",
  delim = ";"
)

# Explorar la estructura de los datos
glimpse(datos_mp25)

# Resumen estadístico inicial
summary(datos_mp25)

# Preparar los datos para el análisis

datos_mp25 <- datos_mp25 %>%
  select(-...6) %>%
  mutate(
    mp25 = coalesce(
      `Registros validados`,
      `Registros preliminares`,
      `Registros no validados`
    )
  )

# Resumen de la concentración de MP2.5
summary(datos_mp25$mp25)

# Cantidad de datos ausentes de MP2.5
sum(is.na(datos_mp25$mp25))

# Crear variable de fecha y hora

datos_mp25 <- datos_mp25 %>%
  mutate(
    fecha_hora = ymd_hm(
      paste(
        `FECHA (YYMMDD)`,
        `HORA (HHMM)`
      )
    )
  )

glimpse(datos_mp25$fecha_hora)

# Visualización de la serie temporal de MP2.5

ggplot(datos_mp25, aes(x = fecha_hora, y = mp25)) +
  geom_line(na.rm = TRUE) +
  labs(
    title = "Variación temporal de MP2.5",
    subtitle = "Estación Parque O'Higgins, Santiago - 2026",
    x = "Fecha",
    y = expression("MP"[2.5]~(mu*g/m^3))
  ) +
  theme_minimal()
# Calcular promedios mensuales de MP2.5

mp25_mensual <- datos_mp25 %>%
  mutate(mes = floor_date(fecha_hora, "month")) %>%
  group_by(mes) %>%
  summarise(
    promedio_mp25 = mean(mp25, na.rm = TRUE)
  )

mp25_mensual

# Visualizar el promedio mensual de MP2.5

ggplot(mp25_mensual, aes(x = mes, y = promedio_mp25)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(
    title = "Concentración promedio mensual de MP2.5",
    subtitle = "Estación Parque O'Higgins, Santiago - 2026",
    x = "Mes",
    y = expression("MP"[2.5]~(mu*g/m^3))
  ) +
  scale_x_datetime(date_breaks = "1 month", date_labels = "%b") +
  theme_minimal()
View(datos_mp25)

ggplot(mp25_mensual, aes(x = mes, y = promedio_mp25)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(
    title = "Concentración promedio mensual de MP2.5",
    subtitle = "Estación Parque O'Higgins, Santiago - 2026",
    x = "Mes",
    y = expression("MP"[2.5]~(mu*g/m^3))
  ) +
  scale_x_datetime(date_breaks = "1 month", date_labels = "%b") +
  theme_minimal()
