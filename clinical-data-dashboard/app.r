library(shiny)
library(tidyverse)
library(DT)
library(scales)

# -------------------------
# VALIDATION FUNCTIONS
# -------------------------

calculate_missing <- function(df) {
  tibble(
    Variable = names(df),
    Missing_Count = colSums(is.na(df)),
    Missing_Percent = round(colMeans(is.na(df)) * 100, 2)
  )
}

detect_outliers <- function(df) {
  numeric_df <- df %>% select(where(is.numeric))
  
  outlier_counts <- sapply(numeric_df, function(x) {
    Q1 <- quantile(x, 0.25, na.rm = TRUE)
    Q3 <- quantile(x, 0.75, na.rm = TRUE)
    IQR_val <- IQR(x, na.rm = TRUE)
    sum(x < (Q1 - 1.5 * IQR_val) | x > (Q3 + 1.5 * IQR_val), na.rm = TRUE)
  })
  
  tibble(
    Variable = names(outlier_counts),
    Outlier_Count = as.numeric(outlier_counts)
  )
}

compare_datasets <- function(df1, df2) {
  tibble(
    Metric = c("Rows", "Columns"),
    Dataset_1 = c(nrow(df1), ncol(df1)),
    Dataset_2 = c(nrow(df2), ncol(df2))
  )
}

# -------------------------
# UI
# -------------------------

ui <- fluidPage(
  
  fluidRow(
    column(12,
      h2("Clinical Data Validation Dashboard", align = "center"),
      hr()
    )
  ),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Upload Primary Dataset (.csv)"),
      fileInput("file2", "Upload Comparison Dataset (optional)"),
      numericInput("threshold", "Missing % Threshold:", 5, min = 0, max = 100),
      selectInput("numeric_var", "Select Numeric Variable", choices = NULL),
      br(),
      downloadButton("download_report", "Download Missing Data Report")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Preview", br(), DTOutput("preview")),
        tabPanel("Missing Data", br(), DTOutput("missing_table")),
        tabPanel("Outliers", br(), DTOutput("outlier_table")),
        tabPanel("Comparison", br(), DTOutput("comparison_table")),
        tabPanel("Visualization", br(), plotOutput("plot", height = "500px"))
      )
    )
  )
)

# -------------------------
# SERVER
# -------------------------

server <- function(input, output, session) {
  
  dataset1 <- reactive({
    req(input$file1)
    read_csv(input$file1$datapath, show_col_types = FALSE)
  })
  
  dataset2 <- reactive({
    req(input$file2)
    read_csv(input$file2$datapath, show_col_types = FALSE)
  })
  
  observe({
    req(dataset1())
    numeric_cols <- names(dataset1())[sapply(dataset1(), is.numeric)]
    updateSelectInput(session, "numeric_var", choices = numeric_cols)
  })
  
  # -------------------------
  # PREVIEW TABLE
  # -------------------------
  
  output$preview <- renderDT({
    req(dataset1())
    datatable(
      dataset1(),
      options = list(scrollX = TRUE, pageLength = 10),
      class = "stripe hover compact"
    )
  })
  
  # -------------------------
  # MISSING DATA TABLE
  # -------------------------
  
  output$missing_table <- renderDT({
    req(dataset1())
    missing_df <- calculate_missing(dataset1()) %>%
      mutate(
        Flag = ifelse(Missing_Percent > input$threshold, "⚠ Flagged", "OK")
      )
    
    datatable(
      missing_df,
      options = list(pageLength = 10),
      class = "stripe hover"
    )
  })
  
  # -------------------------
  # OUTLIER TABLE
  # -------------------------
  
  output$outlier_table <- renderDT({
    req(dataset1())
    
    datatable(
      detect_outliers(dataset1()),
      options = list(pageLength = 10),
      class = "stripe hover"
    )
  })
  
  # -------------------------
  # COMPARISON TABLE
  # -------------------------
  
  output$comparison_table <- renderDT({
    req(input$file2)
    
    datatable(
      compare_datasets(dataset1(), dataset2()),
      options = list(dom = 't'),
      class = "stripe"
    )
  })
  
  # -------------------------
  # VISUALIZATION
  # -------------------------
  
  output$plot <- renderPlot({
    req(dataset1(), input$numeric_var)
    
    data_clean <- dataset1() %>%
      filter(!is.na(.data[[input$numeric_var]]))
    
    ggplot(data_clean, aes(x = .data[[input$numeric_var]])) +
      geom_histogram(
        bins = 30,
        fill = "#2C7FB8",
        color = "white",
        alpha = 0.85
      ) +
      scale_x_continuous(labels = comma) +
      labs(
        title = paste("Distribution of", input$numeric_var),
        x = input$numeric_var,
        y = "Count"
      ) +
      theme_minimal(base_size = 15) +
      theme(
        plot.title = element_text(face = "bold", hjust = 0.5),
        panel.grid.minor = element_blank()
      )
  })
  
  # -------------------------
  # DOWNLOAD REPORT
  # -------------------------
  
  output$download_report <- downloadHandler(
    filename = function() {
      paste("missing_report_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write_csv(calculate_missing(dataset1()), file)
    }
  )
}

shinyApp(ui = ui, server = server)