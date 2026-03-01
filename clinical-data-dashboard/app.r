library(shiny)
library(tidyverse)
library(DT)

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
  
  titlePanel("Clinical Data Validation Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Upload Primary Dataset (.csv)"),
      fileInput("file2", "Upload Comparison Dataset (optional)"),
      numericInput("threshold", "Missing % Threshold:", 5),
      selectInput("numeric_var", "Select Numeric Variable", choices = NULL),
      downloadButton("download_report", "Download Missing Data Report")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Preview", DTOutput("preview")),
        tabPanel("Missing Data", DTOutput("missing_table")),
        tabPanel("Outliers", DTOutput("outlier_table")),
        tabPanel("Comparison", DTOutput("comparison_table")),
        tabPanel("Visualization", plotOutput("plot"))
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
  
  output$preview <- renderDT({
    req(dataset1())
    datatable(dataset1(), options = list(scrollX = TRUE))
  })
  
  output$missing_table <- renderDT({
    req(dataset1())
    missing_df <- calculate_missing(dataset1())
    
    missing_df %>%
      mutate(Flag = ifelse(Missing_Percent > input$threshold, "⚠ Flagged", "OK"))
  })
  
  output$outlier_table <- renderDT({
    req(dataset1())
    detect_outliers(dataset1())
  })
  
  output$comparison_table <- renderDT({
    req(input$file2)
    compare_datasets(dataset1(), dataset2())
  })
  
  output$plot <- renderPlot({
    req(dataset1(), input$numeric_var)
    
    ggplot(dataset1(), aes_string(x = input$numeric_var)) +
      geom_histogram(bins = 30, fill = "steelblue", color = "white") +
      theme_minimal() +
      labs(title = paste("Distribution of", input$numeric_var))
  })
  
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