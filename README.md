

# Análisis exploratorio del MP2.5 en Santiago de Chile

**Autora:** María Cristina Olivera Ferrer

## Resumen del proyecto

La contaminación por material particulado fino (MP2.5) constituye un problema ambiental relevante en Santiago de Chile, donde las condiciones geográficas, meteorológicas y las fuentes de emisión influyen en su distribución espacial y temporal.

Este proyecto utiliza registros horarios de MP2.5 correspondientes a 2026, provenientes de tres estaciones oficiales de la red SINCA (Puente Alto, Cerro Navia y Parque O'Higgins) y cuatro sensores de bajo costo calibrados ubicados en sectores cercanos.

Mediante herramientas de análisis exploratorio y visualización de datos en R, se busca caracterizar la variabilidad de las concentraciones de MP2.5 entre diferentes localidades y períodos, así como examinar las semejanzas y diferencias entre ambas redes de monitoreo.

## Preguntas exploratorias

1. ¿Cómo varían temporalmente las concentraciones de MP2.5 en Puente Alto, Cerro Navia y Parque O'Higgins durante los períodos de estudio?
2. ¿Qué diferencias se observan en la distribución de las concentraciones de MP2.5 entre los tres sectores seleccionados?
3. ¿Qué semejanzas y diferencias presentan los registros horarios de las estaciones SINCA y los sensores de bajo costo calibrados ubicados en sus proximidades, considerando únicamente los períodos de medición coincidentes?

## Fuentes de datos

**Red oficial SINCA:** registros horarios de MP2.5 de las estaciones Puente Alto, Cerro Navia y Parque O'Higgins, correspondientes al período comprendido entre el 1 de marzo y el 30 de septiembre de 2026.

**Sensores de bajo costo calibrados:** registros de cuatro sensores identificados como CH2 y CH3 (Puente Alto), CH4 (Cerro Navia) y CH56 (Parque O'Higgins). Sus períodos de medición serán verificados durante el análisis.

Fuentes de consulta:

- SINCA: https://sinca.mma.gob.cl/
- Aire Ciudadano: https://sensor.aireciudadano.com/d/xTdfdbchs/sensores-chs?orgId=1

## Organización del proyecto

```text
proyecto-mp2.5-santiago/
├── datos/
│   ├── sinca/
│   └── sensores_bajo_costo/
├── scripts/
│   └── 01-eda.R
├── graficos/
│   ├── serie_temporal_MP25_Parque_OHiggins.png
│   └── promedio_mensual_MP25_Parque_OHiggins.png
├── imagenes/
│   ├── santiago1.jpg
│   ├── santiago2.jpg
│   ├── sinca.jpg
│   ├── sensores.jpg
│   └── fsensor.jpg
├── informe/
│   ├── storytelling_proyecto_MP25.Rmd
│   └── storytelling_proyecto_MP25.html
├── proyecto-mp2.5-santiago.Rproj
└── README.md
```

## Diccionario preliminar de datos

Las siguientes variables corresponden a la primera exploración de los registros de la estación SINCA Parque O'Higgins.

| Variable | Descripción |
|---|---|
| `FECHA (YYMMDD)` | Fecha de la medición en el formato original de SINCA. |
| `HORA (HHMM)` | Hora de la medición. |
| `Registros validados` | Concentraciones registradas como validadas. |
| `Registros preliminares` | Concentraciones registradas como preliminares. |
| `Registros no validados` | Concentraciones registradas como no validadas. |
| `mp25` | Variable construida mediante `coalesce()`, priorizando los registros validados, seguidos de los preliminares y no validados. |
| `fecha_hora` | Variable temporal construida a partir de las columnas originales de fecha y hora. |

Las concentraciones de MP2.5 se expresan en µg/m³.

## Tratamiento preliminar de datos ausentes

Durante la exploración inicial se identifican los valores faltantes (`NA`) presentes en los registros horarios de MP2.5.

Para construir la variable de concentración se utiliza la función `coalesce()`, priorizando los registros validados y utilizando los preliminares o no validados cuando los anteriores no están disponibles.

Los valores faltantes restantes se conservan en la base de datos. Para calcular los promedios mensuales se utiliza `na.rm = TRUE`, excluyendo los valores ausentes del cálculo.

En esta etapa no se realizan imputaciones ni se atribuye un mecanismo específico a los datos ausentes.

## Herramientas utilizadas

- R y RStudio.
- `tidyverse` para manipulación de datos y visualización.
- `lubridate` para procesamiento de fechas y horas.
- R Markdown para la elaboración del storytelling.
- Git y GitHub para control de versiones.

## Cómo reproducir el análisis preliminar

1. Descargar o clonar este repositorio.
2. Abrir `proyecto-mp2.5-santiago.Rproj` en RStudio.
3. Instalar los paquetes `tidyverse` y `lubridate`, si aún no están disponibles.
4. Ejecutar el script `scripts/01-eda.R` desde la carpeta principal del proyecto.
5. Abrir `informe/storytelling_proyecto_MP25.Rmd`.
6. Utilizar **Knit** para generar el documento HTML.

## Estado actual del proyecto

El proyecto se encuentra en una etapa preliminar de análisis exploratorio.

Hasta el momento se ha realizado una primera exploración de las concentraciones horarias de MP2.5 registradas en la estación SINCA Parque O'Higgins durante 2026.

Se han elaborado dos visualizaciones preliminares:

- Serie temporal de las concentraciones horarias de MP2.5.
- Evolución de las concentraciones promedio mensuales de MP2.5.

Las siguientes etapas contemplan ampliar el análisis a las estaciones Puente Alto y Cerro Navia y comparar los registros de SINCA con los sensores de bajo costo calibrados, considerando únicamente los períodos de medición coincidentes.

Los resultados actuales son descriptivos y exploratorios; no permiten atribuir las concentraciones observadas a fuentes específicas de emisión.
