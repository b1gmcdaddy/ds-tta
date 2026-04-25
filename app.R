library(shiny)
library(shinydashboard)
library(ggplot2)

ui <- dashboardPage(
  dashboardHeader(title = "Iris Explorer"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("chart-bar"))
    ),
    hr(),
    selectInput("x_var", "X Axis Variable",
      choices = c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"),
      selected = "Sepal.Length"
    ),
    selectInput("y_var", "Y Axis Variable",
      choices = c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"),
      selected = "Petal.Length"
    ),
    checkboxGroupInput("species_filter", "Filter Species",
      choices = levels(iris$Species),
      selected = levels(iris$Species)
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
        fluidRow(
          valueBoxOutput("obs_count"),
          valueBoxOutput("avg_sepal"),
          valueBoxOutput("avg_petal")
        ),
        fluidRow(
          box(title = "Scatter Plot", status = "primary", solidHeader = TRUE,
              width = 8, plotOutput("scatter", height = 300)),
          box(title = "Species Distribution", status = "info", solidHeader = TRUE,
              width = 4, plotOutput("pie", height = 300))
        ),
        fluidRow(
          box(title = "Feature Distributions", status = "success", solidHeader = TRUE,
              width = 12, plotOutput("boxplot", height = 280))
        )
      )
    )
  )
)

server <- function(input, output) {
  filtered <- reactive({
    iris[iris$Species %in% input$species_filter, ]
  })

  output$obs_count <- renderValueBox({
    valueBox(nrow(filtered()), "Observations", icon = icon("list"), color = "blue")
  })

  output$avg_sepal <- renderValueBox({
    val <- round(mean(filtered()$Sepal.Length), 2)
    valueBox(val, "Avg Sepal Length", icon = icon("ruler"), color = "green")
  })

  output$avg_petal <- renderValueBox({
    val <- round(mean(filtered()$Petal.Length), 2)
    valueBox(val, "Avg Petal Length", icon = icon("seedling"), color = "yellow")
  })

  output$scatter <- renderPlot({
    df <- filtered()
    req(nrow(df) > 0)
    ggplot(df, aes_string(x = input$x_var, y = input$y_var, color = "Species")) +
      geom_point(size = 3, alpha = 0.7) +
      theme_minimal() +
      labs(title = paste(input$x_var, "vs", input$y_var))
  })

  output$pie <- renderPlot({
    df <- filtered()
    req(nrow(df) > 0)
    counts <- as.data.frame(table(df$Species))
    ggplot(counts, aes(x = "", y = Freq, fill = Var1)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar("y") +
      theme_void() +
      labs(fill = "Species")
  })

  output$boxplot <- renderPlot({
    df <- filtered()
    req(nrow(df) > 0)
    df_long <- reshape(df,
      varying = c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"),
      v.names = "Value",
      timevar = "Feature",
      times = c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"),
      direction = "long"
    )
    ggplot(df_long, aes(x = Feature, y = Value, fill = Species)) +
      geom_boxplot(alpha = 0.7) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 20, hjust = 1)) +
      labs(x = NULL, y = "cm")
  })
}

shinyApp(ui, server)
