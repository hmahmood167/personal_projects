# Clinical Data Validation Dashboard

An RShiny-based dashboard that automates structured dataset validation workflows.

## Features
- Missing data detection with configurable threshold flagging
- IQR-based outlier detection
- Dataset comparison
- Interactive ggplot2 visualizations
- Downloadable validation report

## Tech Stack
- R
- Shiny
- tidyverse
- ggplot2
- DT

## How to Run

```r
shiny::runApp("app.R")