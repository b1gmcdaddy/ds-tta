library(shiny)
library(ggplot2)
library(dplyr)

# Load housing csv
housing <- read.csv("housing.csv")

ui <- fluidPage(
  titlePanel("Housing Dashboard"),

  sidebarLayout(
    sidebarPanel(
      h3("Dashboard"),
      p("Housing dataset."),
    ),

    mainPanel(
      tabsetPanel(
        # tab 1
        tabPanel("Ocean Proximity",
                 h3("Distribution of Homes by Ocean Proximity"),
                 plotOutput("oceanProximityPlot"),
                 verbatimTextOutput("oceanProximitySummary")
        ),

        # tab2
        tabPanel("Population vs Households",
                 h3("Relationship Between Population and Households"),
                 plotOutput("populationHouseholdsPlot")
        ),

        # tab3
        tabPanel("Rooms vs Bedrooms",
                 h3("Relationship Between Total Rooms and Total Bedrooms"),
                 plotOutput("roomsBedroomsPlot")
        )
      )
    )
  )
)

server <- function(input, output, session) {

  #tab1 content
  output$oceanProximityPlot <- renderPlot({
    ocean_counts <- housing %>%
      group_by(ocean_proximity) %>%
      summarise(count = n(), .groups = 'drop') %>%
      arrange(desc(count))

    ggplot(ocean_counts, aes(x = reorder(ocean_proximity, -count), y = count, fill = ocean_proximity)) +
      geom_bar(stat = "identity", color = "black", linewidth = 0.5) +
      geom_text(aes(label = count), vjust = -0.5, size = 5, fontface = "bold") +
      labs(title = "Number of Homes by Ocean Proximity",
           x = "Ocean Proximity Category",
           y = "Number of Homes",
           fill = "Category") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
            legend.position = "bottom")
  })

  output$oceanProximitySummary <- renderPrint({
    ocean_summary <- housing %>%
      group_by(ocean_proximity) %>%
      summarise(
        count = n(),
        percentage = round(n() / nrow(housing) * 100, 2),
        .groups = 'drop'
      ) %>%
      arrange(desc(count))

    print(ocean_summary)
  })

  # tab2 content
  output$populationHouseholdsPlot <- renderPlot({
    ggplot(housing, aes(x = households, y = population)) +
      geom_point(alpha = 0.4, size = 2, color = "steelblue") +
      geom_smooth(method = "lm", se = TRUE, color = "red", linewidth = 1) +
      labs(title = "Population vs Number of Households",
           x = "Number of Households",
           y = "Total Population",
           subtitle = paste("Correlation:", round(cor(housing$households, housing$population), 3))) +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
            plot.subtitle = element_text(hjust = 0.5, size = 11))
  })

  # tab3 content
  output$roomsBedroomsPlot <- renderPlot({
    ggplot(housing, aes(x = total_bedrooms, y = total_rooms)) +
      geom_point(alpha = 0.4, size = 2, color = "darkgreen") +
      geom_smooth(method = "lm", se = TRUE, color = "orange", linewidth = 1) +
      labs(title = "Total Rooms vs Total Bedrooms",
           x = "Total Bedrooms",
           y = "Total Rooms",
           subtitle = paste("Correlation:", round(cor(housing$total_rooms, housing$total_bedrooms, use = "complete.obs"), 3))) +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
            plot.subtitle = element_text(hjust = 0.5, size = 11))
  })
}

shinyApp(ui, server)
