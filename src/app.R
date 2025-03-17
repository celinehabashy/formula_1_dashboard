library(shiny)
library(leaflet)
library(dplyr)
library(readr)
library(shinyWidgets)
library(shinydashboard)
library(ggplot2)

# Load datasets
circuits <- read_csv("../data/circuits.csv", show_col_types = FALSE)
races <- read_csv("../data/races.csv", show_col_types = FALSE) %>% rename(race_name = name)
drivers <- read_csv("../data/drivers.csv", show_col_types = FALSE)
results <- read_csv("../data/results.csv", show_col_types = FALSE)
constructors <- read_csv("../data/constructors.csv", show_col_types = FALSE)

# Ensure column names are correct
print(colnames(circuits))
print(colnames(races))
print(colnames(results))
print(colnames(drivers))

# UI
ui <- fluidPage(
  tags$head(tags$style(".styled-box {
    background-color: #98c1a9;
    border-radius: 5px;
    padding: 15px;
    border: 3px solid #3a4d39;
    margin-bottom: 20px;
    width: 95%;
    margin-left: auto;
    margin-right: auto;
  }
  h1 {
    background-color: #98c1a9;
    color: #3a4d39;
    text-align: center;
    font-weight: bold;
    padding: 15px;
    border-radius: 5px;
    margin-bottom: 20px;
    border: 3px solid #3a4d39;
    width: 95%;
    margin-left: auto;
    margin-right: auto;
  }")),
  
  div(class = "styled-box", h1("🏎️ Formula 1 Dashboard 🏁", style = "text-align: center;")),
  
  fluidRow(class = "styled-box",
           column(4, pickerInput("year", "Select Year:", choices = unique(races$year), selected = max(races$year), multiple = FALSE)),
           column(4, pickerInput("circuit", "Select Circuit:", choices = NULL, multiple = FALSE)),
           column(4, pickerInput("driver", "Select Driver:", choices = NULL, multiple = FALSE))
  ),
  
  fluidRow(class = "styled-box",
           column(4, valueBoxOutput("race_winner", width = NULL)),
           column(4, valueBoxOutput("team_winner", width = NULL)),
           column(4, valueBoxOutput("fastest_lap", width = NULL))
  ),
  
  tags$div(class = "styled-box", style = "width: 95%; margin: auto;",
           h3("Race Map", style = "text-align: center; color: #3a4d39;"),
           leafletOutput("map", height = 500)
  ),
  
  tags$div(class = "styled-box", style = "width: 95%; margin: auto;",
           h3("Driver Performance Over Season", style = "text-align: center; font-size: 24px; font-weight: bold; font-family: Arial; color: #3a4d39;"),
           plotOutput("driver_progress", height = 350)
  )
)

# Server
server <- function(input, output, session) {
  
  # Update circuit choices based on selected year
  observeEvent(input$year, {
    circuit_choices <- races %>% 
      filter(year == input$year) %>%
      inner_join(circuits, by = "circuitId") %>%
      distinct(race_name) %>%
      pull(race_name)
    
    if (length(circuit_choices) == 0) circuit_choices <- "No circuits available"
    updatePickerInput(session, "circuit", choices = circuit_choices)
  })
  
  # Update driver choices based on selected year and circuit
  observeEvent(input$circuit, {
    selected_race <- races %>% filter(year == input$year, race_name == input$circuit)
    
    driver_choices <- results %>% 
      filter(raceId %in% selected_race$raceId) %>%
      inner_join(drivers, by = "driverId") %>%
      mutate(driver_name = paste(forename, surname)) %>%
      distinct(driver_name) %>%
      pull(driver_name)
    
    if (length(driver_choices) == 0) driver_choices <- "No drivers available"
    updatePickerInput(session, "driver", choices = driver_choices)
  })
  
  # **Render Race Map**
  output$map <- renderLeaflet({
    req(input$circuit)  # Ensure circuit is selected
    
    circuit_data <- circuits %>%
      inner_join(races, by = "circuitId") %>%
      filter(year == input$year, race_name == input$circuit)
    
    if (nrow(circuit_data) == 0) return(NULL)
    
    leaflet() %>%
      addTiles() %>%
      addMarkers(lng = circuit_data$lng, lat = circuit_data$lat,
                 popup = paste("<b>", circuit_data$race_name, "</b>"))
  })
  
  # **Render Driver Performance Over Season**
  output$driver_progress <- renderPlot({
    req(input$driver, input$year)  # Ensure driver and year are selected
    
    driver_data <- results %>%
      inner_join(drivers, by = "driverId") %>%
      inner_join(races, by = "raceId") %>%
      filter(year == input$year, paste(forename, surname) == input$driver) %>%
      arrange(round)  # Ensure data is ordered by race round
    
    if (nrow(driver_data) == 0) return(NULL)
    
    ggplot(driver_data, aes(x = round, y = positionOrder, group = 1)) +
      geom_line(color = "blue", size = 1.2) +
      geom_point(color = "red", size = 3) +
      scale_y_reverse() +  # Reverse y-axis so 1st place is at the top
      labs(,
           x = "Race Round",
           y = "Finishing Position") +
      theme_minimal()
  })
  
  # Summary statistics
  output$race_winner <- renderValueBox({
    winner <- results %>% filter(positionOrder == 1, raceId %in% races$raceId[races$year == input$year & races$race_name == input$circuit]) %>%
      inner_join(drivers, by = "driverId") %>%
      mutate(driver_name = paste(forename, surname)) %>%
      pull(driver_name)
    
    winner <- ifelse(length(winner) == 0, "Unknown", winner)
    valueBox(winner, "Race Winner", icon = icon("trophy"), color = "yellow")
  })
  
  output$team_winner <- renderValueBox({
    team <- results %>% filter(positionOrder == 1, raceId %in% races$raceId[races$year == input$year & races$race_name == input$circuit]) %>%
      inner_join(constructors, by = "constructorId") %>%
      pull(name)
    
    team <- ifelse(length(team) == 0, "Unknown", team)
    valueBox(team, "Winning Team", icon = icon("flag-checkered"), color = "blue")
  })
  
  output$fastest_lap <- renderValueBox({
    fast_driver <- results %>% filter(!is.na(fastestLap), fastestLap == rank, raceId %in% races$raceId[races$year == input$year & races$race_name == input$circuit]) %>%
      inner_join(drivers, by = "driverId") %>%
      mutate(driver_name = paste(forename, surname)) %>%
      pull(driver_name)
    
    fast_driver <- ifelse(length(fast_driver) == 0, "Unknown", fast_driver)
    valueBox(fast_driver, "Fastest Lap", icon = icon("bolt"), color = "red")
  })
}

shinyApp(ui = ui, server = server)
