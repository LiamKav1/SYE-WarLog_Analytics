# Load necessary libraries
library(shiny)
library(dplyr)
library(DT)

# Load the data
warLog2 <- read.csv("https://raw.githubusercontent.com/LiamKav1/SYE-WarLog_Analytics/refs/heads/main/WarLog.csv")

# Define the UI
ui <- fluidPage(
  titlePanel("War Statistics"),
  sidebarLayout(
    sidebarPanel(
      h4("WarLog Analytics"),
      p("This app displays statistics for Clash of Clans wars based on players' performance and town hall levels."),
      selectInput("viewSelect", "Choose View:", 
                  choices = c("Summary Table", "Player Statistics", "Town Hall Difference Table")),
      conditionalPanel(
        condition = "input.viewSelect == 'Player Statistics' || input.viewSelect == 'Town Hall Difference Table'",
        textInput("playerTag", "Enter Player Tag:", value = ""),
        selectInput("attackOrder", "Select Attack Order:",
                    choices = c("Both" = "both", 
                                "First Attack Only" = "1", 
                                "Second Attack Only" = "2"))
      )
    ),
    mainPanel(
      h3("War Statistics"),
      DTOutput("summaryTable"),
      conditionalPanel(
        condition = "input.viewSelect == 'Player Statistics'",
        DTOutput("filteredDataTable")
      ),
      conditionalPanel(
        condition = "input.viewSelect == 'Town Hall Difference Table'",
        textOutput("averagePositionDiff"),
        DTOutput("townHallDiffTable")
      ),
    )
  )
)

# Define the server
server <- function(input, output, session) {
  # Add the attackOrder column dynamically
  warLog2 <- warLog2 %>%
    arrange(clanTag, warDate, duration) %>%  # Sort by war, date, and attack duration
    group_by(clanTag, attackerTag, warDate) %>%
    mutate(attackOrder = row_number()) %>%
    ungroup()
  
  # Generate the summary table
  summary_table <- warLog2 %>%
    group_by(attackerTag, name.x, townhallLevel.x) %>%
    summarise(
      AvgStars = round(mean(stars, na.rm = TRUE), 3),
      AvgDestruction = round(mean(destructionPercentage, na.rm = TRUE), 3),
      TotalAttacks = n(),
      .groups = "drop"
    ) %>%
    arrange(desc(AvgStars), desc(AvgDestruction))
  
  output$summaryTable <- renderDT({
    if (input$viewSelect == "Summary Table") {
      datatable(
        summary_table,
        options = list(
          pageLength = 10,
          autoWidth = TRUE,
          order = list(list(2, 'desc'), list(3, 'desc'))
        ),
        rownames = FALSE,
        caption = "Summary of War Statistics"
      )
    }
  })
  
  # Calculate and display average position difference
  output$averagePositionDiff <- renderText({
    if (input$viewSelect == "Town Hall Difference Table" && input$playerTag != "") {
      filtered_data <- warLog2 %>%
        filter(attackerTag == input$playerTag)
      
      if (input$attackOrder != "both") {
        filtered_data <- filtered_data %>%
          filter(attackOrder == as.numeric(input$attackOrder))
      }
      
      average_position_difference <- filtered_data %>%
        mutate(position_difference = mapPosition.x - mapPosition.y) %>%
        summarize(average_difference = round(mean(position_difference, na.rm = TRUE), 3)) %>%
        pull(average_difference)
      
      if (!is.na(average_position_difference)) {
        paste("Average attack difference on map location for", input$playerTag, ":", average_position_difference, "(Negative values indicate the player attacks someone with a higher town hall while positive values indicate they attack someone with a lower town hall.)")
      } else {
        paste("No data available for player tag:", input$playerTag)
      }
    }
  })
  
  # Display filtered data table for the player
  output$filteredDataTable <- renderDT({
    if (input$viewSelect == "Player Statistics" && input$playerTag != "") {
      filtered_data <- warLog2 %>%
        filter(attackerTag == input$playerTag)
      
      if (input$attackOrder != "both") {
        filtered_data <- filtered_data %>%
          filter(attackOrder == as.numeric(input$attackOrder))
      }
      
      datatable(
        filtered_data,
        options = list(pageLength = 5, autoWidth = TRUE),
        rownames = FALSE,
        caption = paste("Filtered Data for Player Tag:", input$playerTag)
      )
    }
  })
  
  # Generate Town Hall Difference Table
  output$townHallDiffTable <- renderDT({
    if (input$viewSelect == "Town Hall Difference Table" && input$playerTag != "") {
      attacker_Tag <- input$playerTag
      
      # Calculate the highest and lowest town hall levels in the dataset
      max_townhall_level <- max(warLog2$townhallLevel.y, na.rm = TRUE)
      min_townhall_level <- min(warLog2$townhallLevel.y, na.rm = TRUE)
      
      # Calculate the maximum and minimum possible differences
      max_difference <- max_townhall_level - min(warLog2$townhallLevel.x, na.rm = TRUE)
      min_difference <- min_townhall_level - max(warLog2$townhallLevel.x, na.rm = TRUE)
      
      # Create a tibble with all possible differences based on the calculated range
      all_townhall_differences <- tibble(
        townhall_difference = seq(min_difference, max_difference)
      )
      
      # Filter data for the specified attacker and calculate the town hall difference
      filtered_data <- warLog2 %>%
        filter(attackerTag == attacker_Tag)
      
      if (input$attackOrder != "both") {
        filtered_data <- filtered_data %>%
          filter(attackOrder == as.numeric(input$attackOrder))
      }
      
      filtered_data <- filtered_data %>%
        mutate(
          townhall_difference = townhallLevel.y - townhallLevel.x
        )
      
      # Calculate averages for stars and destruction for each difference
      player_stats <- filtered_data %>%
        group_by(townhall_difference) %>%
        summarize(
          average_stars = round(mean(stars, na.rm = TRUE), 3),
          average_destruction = round(mean(destructionPercentage, na.rm = TRUE), 3),
          .groups = "drop"
        )
      
      # Join with the full range of differences and fill missing values with 0
      final_output <- all_townhall_differences %>%
        left_join(player_stats, by = "townhall_difference") %>%
        filter(!(average_stars == 0 & average_destruction == 0)) %>%
        mutate(
          player_tag = attacker_Tag
        )
      
      datatable(
        final_output,
        options = list(pageLength = 10, autoWidth = TRUE),
        rownames = FALSE,
        caption = paste("Town Hall Difference Table for Player Tag:", input$playerTag)
      )
    }
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)

