library(shiny)
library(DT)
library(plotly)
library(reactable)
library(rsconnect)


ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {
        background-color: #f7f7f7; /* Light background for better contrast */
        font-family: Arial, sans-serif;
        padding-top: 35px; /* Add spacing at the top */
      }
      .header {
        background: linear-gradient(135deg, #5b8fcc, #4a79b2); /* Light blue gradient */
        color: white; /* Text color */
        font-size: 12px; /* Slightly smaller font size */
        font-weight: bold;
        text-align: left; /* Align text to the left */
        padding: 6px 10px; /* Reduce padding for a slimmer header */
        border-radius: 5px 5px 0 0; /* Slightly rounded top corners */
        margin-bottom: 15px; /* Add space below the header */
        box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.1); /* Subtle shadow for depth */
      }
      .team-section {
        background-color: white;
        border-radius: 10px;
        padding: 20px;
        margin: 10px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        display: flex;
        justify-content: space-evenly; /* Evenly space the condition boxes */
        align-items: center;
      }
      .results-container {
        display: flex;
        justify-content: space-between;
        margin-top: 10px; /* Add more spacing between rows */
      }
      .table-container, .graph-container {
        width: 48%; /* Adjust width for better alignment */
      }
      .condition-box {
        width: 100px;
        height: 100px;
        background: linear-gradient(145deg, #6ea8e8, #3f78c8); /* Shiny blue gradient */
        border: none; /* Remove black border */
        border-radius: 10px; /* Rounded corners */
        display: inline-flex;
        align-items: center;
        justify-content: center;
        margin: 10px;
        font-size: 19px;
        font-weight: bold;
        color: white;
        text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.5); /* Slight text shadow */
        cursor: pointer;
        box-shadow: 3px 3px 8px rgba(0, 0, 0, 0.3), inset -2px -2px 5px rgba(255, 255, 255, 0.5); /* Outer and inner shadows for shine */
        transition: all 0.3s ease-in-out;
      }
      .condition-box:hover {
        transform: scale(1.1);
        background: linear-gradient(145deg, #7bb5f0, #4f87d5); /* Slightly lighter blue on hover */
        box-shadow: 4px 4px 10px rgba(0, 0, 0, 0.4), inset -3px -3px 8px rgba(255, 255, 255, 0.7); /* Enhanced shine on hover */
      }
      .condition-box.selected {
        background: linear-gradient(145deg, #b0b0b0, #9e9e9e); /* Shiny silver gradient */
        box-shadow: 4px 4px 10px rgba(0, 0, 0, 0.3), inset -3px -3px 6px rgba(255, 255, 255, 0.4); /* Subtle shine for selected */
        color: black;
      }
      .shiny-btn {
        margin-top: 20px;
        background: linear-gradient(145deg, #5cc580, #44a866); /* Shiny green gradient */
        color: white;
        border: none;
        padding: 10px 20px;
        border-radius: 30px; /* Fully rounded edges */
        cursor: pointer;
        font-size: 16px;
        font-weight: bold;
        text-align: center;
        text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.5); /* Subtle text shadow */
        box-shadow: 4px 4px 8px rgba(0, 0, 0, 0.3), inset -2px -2px 6px rgba(255, 255, 255, 0.5); /* Outer and inner shadows */
        transition: all 0.3s ease-in-out; /* Smooth transition for hover effect */
      }
      .shiny-btn:hover {
        transform: scale(1.1); /* Magnify the button */
        background: linear-gradient(145deg, #69d18d, #50b072); /* Slightly lighter gradient on hover */
        box-shadow: 6px 6px 12px rgba(0, 0, 0, 0.4), inset -3px -3px 8px rgba(255, 255, 255, 0.7); /* Enhanced shine */
      }
      .results-container {
        display: flex;
        justify-content: space-between;
      }
      .table-container {
        background-color: white; /* White background */
        border-radius: 10px; /* Rounded corners */
        padding: 10px; /* Padding inside the container */
        margin: 10px; /* Margin around the container */
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); /* Subtle shadow for depth */
        width: 100%; /* Match the container width to the parent */
        max-width: calc(100% - 20px); /* Adjust for margins */
        display: block; /* Ensure full alignment */
      }
    "))
  ),
  
  
  tags$script(HTML("
    $(document).on('click', '.condition-box', function() {
      $(this).toggleClass('selected');
      let boxId = $(this).attr('id');
      Shiny.setInputValue(boxId, $(this).hasClass('selected'), {priority: 'event'});
    });

    Shiny.addCustomMessageHandler('resetBoxes', function(data) {
      $('[id^=' + data.team + '_cond]').removeClass('selected');
    });
  ")),
  
  fluidRow(
    column(6, 
           div(class = "header", "COWBOYS"),
           div(class = "team-section",
               div(id = "team1_cond1", class = "condition-box", "1"),
               div(id = "team1_cond2", class = "condition-box", "2"),
               div(id = "team1_cond3", class = "condition-box", "3"),
               actionButton("submit_team1", "Submit", class = "shiny-btn")
           )
    ),
    column(6, 
           div(class = "header", "OPPOSITION"),
           div(class = "team-section",
               div(id = "team2_cond1", class = "condition-box", "1"),
               div(id = "team2_cond2", class = "condition-box", "2"),
               div(id = "team2_cond3", class = "condition-box", "3"),
               actionButton("submit_team2", "Submit", class = "shiny-btn")
           )
    )
  ),
  fluidRow(
    column(6, 
           div(class = "header", "RESULTS"),
           div(class = "table-container", 
               reactableOutput("results_table")
               
           )
    ),
    column(6, 
           div(class = "header", "DATA"),
           div(style = "display: flex; justify-content: space-around; align-items: center; padding: 10px;",
               div(style = "text-align: center; width: 45%; background-color: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);",
                   h4("COWBOYS", align = "center", style = "font-weight: bold; font-size: 16px;"),
                   plotlyOutput("team1_pie", height = "300px", width = "100%")
               ),
               div(style = "text-align: center; width: 45%; background-color: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);",
                   h4("OPPOSITION", align = "center", style = "font-weight: bold; font-size: 16px;"),
                   plotlyOutput("team2_pie", height = "300px", width = "100%")
               )
           )
           
    )
  )
)


server <- function(input, output, session) {
  
  selected_conditions <- reactiveValues(
    team1 = c(FALSE, FALSE, FALSE),
    team2 = c(FALSE, FALSE, FALSE)
  )
  
  results <- reactiveVal(data.frame(
    Order = integer(),
    Team = character(),
    `Condition 1` = character(),
    `Condition 2` = character(),
    `Condition 3` = character(),
    Result = character(),
    ColorName = character(),
    stringsAsFactors = FALSE
  ))
  
  
  
  observeEvent(input$team1_cond1, { selected_conditions$team1[1] <- !selected_conditions$team1[1] })
  observeEvent(input$team1_cond2, { selected_conditions$team1[2] <- !selected_conditions$team1[2] })
  observeEvent(input$team1_cond3, { selected_conditions$team1[3] <- !selected_conditions$team1[3] })
  
  
  observeEvent(input$team2_cond1, { selected_conditions$team2[1] <- !selected_conditions$team2[1] })
  observeEvent(input$team2_cond2, { selected_conditions$team2[2] <- !selected_conditions$team2[2] })
  observeEvent(input$team2_cond3, { selected_conditions$team2[3] <- !selected_conditions$team2[3] })
  
  
  observeEvent(input$submit_team1, {
    new_data <- data.frame(
      Order = nrow(results()) + 1,
      Team = "COWBOYS",
      `Condition 1` = ifelse(selected_conditions$team1[1], "✔", "✖"),
      `Condition 2` = ifelse(selected_conditions$team1[2], "✔", "✖"),
      `Condition 3` = ifelse(selected_conditions$team1[3], "✔", "✖"),
      Result = as.character(sum(selected_conditions$team1)),
      ColorName = c("Black", "Red", "Yellow", "Green")[sum(selected_conditions$team1) + 1],
      stringsAsFactors = FALSE
    )
    results(rbind(results(), new_data))
    selected_conditions$team1 <- c(FALSE, FALSE, FALSE)
    session$sendCustomMessage("resetBoxes", list(team = "team1"))
  })
  
  
  observeEvent(input$submit_team2, {
    new_data <- data.frame(
      Order = nrow(results()) + 1,
      Team = "OPPOSITION",
      `Condition 1` = ifelse(selected_conditions$team2[1], "✔", "✖"),
      `Condition 2` = ifelse(selected_conditions$team2[2], "✔", "✖"),
      `Condition 3` = ifelse(selected_conditions$team2[3], "✔", "✖"),
      Result = as.character(sum(selected_conditions$team2)),
      ColorName = c("Black", "Red", "Yellow", "Green")[sum(selected_conditions$team2) + 1],
      stringsAsFactors = FALSE
    )
    results(rbind(results(), new_data))
    selected_conditions$team2 <- c(FALSE, FALSE, FALSE)
    session$sendCustomMessage("resetBoxes", list(team = "team2"))
  })
  
  
  
  
  
  output$results_table <- renderReactable({
    req(nrow(results()) > 0) 
    
    
    print("Table Data:")
    print(results())
    
    
    data <- results()[nrow(results()):1, ]
    
    
    required_columns <- c("Order", "Team", "Condition 1", "Condition 2", "Condition 3", "Result", "ColorName")
    
    
    for (col in required_columns) {
      if (!col %in% colnames(data)) {
        data[[col]] <- NA
      }
    }
    
    
    reactable(
      data,
      columns = list(
        Order = colDef(name = "Order", align = "center"),
        Team = colDef(
          name = "Team",
          align = "center",
          style = list(whiteSpace = "normal", wordWrap = "break-word"),
          minWidth = 110 # Adjust the width as necessary
        ),
        `Condition 1` = colDef(
          name = "Condition 1",
          align = "center",
          cell = function(value) ifelse(value == "✔", "Selected", "Not Selected")
        ),
        `Condition 2` = colDef(
          name = "Condition 2",
          align = "center",
          cell = function(value) ifelse(value == "✔", "Selected", "Not Selected")
        ),
        `Condition 3` = colDef(
          name = "Condition 3",
          align = "center",
          cell = function(value) ifelse(value == "✔", "Selected", "Not Selected")
        ),
        Result = colDef(name = "Result", align = "center"),
        ColorName = colDef(
          name = "Colour",
          align = "center",
          cell = function(value) {
            color <- switch(
              value,
              "Black" = "rgba(0, 0, 0, 0.2)",       
              "Red" = "rgba(200, 0, 0, 0.3)",      
              "Yellow" = "rgba(200, 200, 0, 0.3)", 
              "Green" = "rgba(0, 150, 0, 0.3)",    
              "rgba(255, 255, 255, 0.1)"           
            )
            div(
              style = list(
                backgroundColor = color,
                height = "25px",          
                width = "100%",           
                borderRadius = "5px",     
                margin = "4px 0"          
              ),
              "" # Empty string to remove text
            )
          },
          html = TRUE
        )
      ),
      striped = TRUE,
      highlight = TRUE,
      bordered = TRUE,
      defaultPageSize = 10,
      style = list(fontFamily = "Arial, sans-serif", fontSize = "14px"),
      theme = reactableTheme(
        borderColor = "#cccccc",
        highlightColor = "#f0f8ff"
      )
    )
  })
  
  
  
  
  output$team1_pie <- renderPlotly({
    team_data <- results()[results()$Team == "COWBOYS", ]
    if (nrow(team_data) == 0) return(NULL)
    
    counts <- table(team_data$ColorName)
    total <- sum(counts)  # Get total trials
    
    colors <- c(
      "Black" = "rgba(0, 0, 0, 0.8)", 
      "Red" = "rgba(200, 0, 0, 0.8)",       
      "Yellow" = "rgba(200, 200, 0, 0.8)",  
      "Green" = "rgba(0, 150, 0, 0.8)"      
    )
    
    plot_ly(
      labels = names(counts),
      values = as.numeric(counts),
      type = "pie",
      marker = list(
        colors = colors[names(counts)],
        line = list(color = "#ffffff", width = 1) 
      ),
      hoverinfo = "text",
      textinfo = "percent",
      textposition = "inside",
      insidetextfont = list(color = "white", size = 16, weight = "bold"),
      text = paste0(names(counts), ": ", counts, "/", total, " (", round((counts / total) * 100, 1), "%)")
    ) %>%
      layout(
        title = NULL,
        plot_bgcolor = "#ffffff",
        paper_bgcolor = "#ffffff",
        margin = list(l = 0, r = 0, t = 0, b = 0),
        showlegend = FALSE
      ) %>%
      config(displayModeBar = FALSE)
  })
  
  
  output$team2_pie <- renderPlotly({
    team_data <- results()[results()$Team == "OPPOSITION", ]
    if (nrow(team_data) == 0) return(NULL)
    
    counts <- table(team_data$ColorName)
    total <- sum(counts) 
    
    colors <- c(
      "Black" = "rgba(0, 0, 0, 0.8)", 
      "Red" = "rgba(200, 0, 0, 0.8)",       
      "Yellow" = "rgba(200, 200, 0, 0.8)",  
      "Green" = "rgba(0, 150, 0, 0.8)"      
    )
    
    plot_ly(
      labels = names(counts),
      values = as.numeric(counts),
      type = "pie",
      marker = list(
        colors = colors[names(counts)],
        line = list(color = "#ffffff", width = 1) 
      ),
      hoverinfo = "text",
      textinfo = "percent",
      textposition = "inside",
      insidetextfont = list(color = "white", size = 16, weight = "bold"),
      text = paste0(names(counts), ": ", counts, "/", total, " (", round((counts / total) * 100, 1), "%)")
    ) %>%
      layout(
        title = NULL,
        plot_bgcolor = "#ffffff",
        paper_bgcolor = "#ffffff",
        margin = list(l = 0, r = 0, t = 0, b = 0),
        showlegend = FALSE
      ) %>%
      config(displayModeBar = FALSE)
  })
  
  
}

shinyApp(ui, server)









