# Clinical Data Validation Dashboard

An RShiny-based dashboard that automates structured dataset validation workflows.
## 🚀 Live Demo

🔗 https://hmahmood.shinyapps.io/clinical-data-dashboard/

This interactive RShiny dashboard demonstrates automated clinical data validation including:
- Missing data detection with threshold flagging
- IQR-based outlier detection
- Dataset comparison
- Treatment-group visualization of clinical metrics

## Tech Stack
- R
- Shiny
- tidyverse
- ggplot2
- DT

## How to Run

```r
shiny::runApp("app.R")