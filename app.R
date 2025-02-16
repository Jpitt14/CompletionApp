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
        width: 120px;
        height: 100px;
        border: none;
        border-radius: 12px; /* More rounded edges */
        display: inline-flex;
        align-items: center;
        justify-content: center;
        margin: 10px;
        font-size: 19px;
        font-weight: bold;
        color: white;
        text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.4);
        cursor: pointer;
        box-shadow: 4px 4px 10px rgba(0, 0, 0, 0.25), 
                    inset -2px -2px 5px rgba(255, 255, 255, 0.4);
        transition: all 0.3s ease-in-out;
    }

    /* 🎨 Improved Box Colors with Soft Gradients */
    .condition-box#team1_cond1, .condition-box#team2_cond1 { 
        background: linear-gradient(145deg, #58C472, #3AA65A);  /* Soft Green */
        color: white;
    }

    .condition-box#team1_cond2, .condition-box#team2_cond2 { 
        background: linear-gradient(145deg, #FFA34D, #E67E22); /* Warm Orange */
        color: white;
    }

    .condition-box#team1_cond3, .condition-box#team2_cond3 { 
        background: linear-gradient(145deg, #E05656, #C0392B); /* Deep Red */
        color: white;
    }

    .condition-box#team1_cond4 { 
        background: linear-gradient(145deg, #F9E07F, #E1C75F); /* Rich Yellow */
        color: White;
    }

    .condition-box#team2_cond4 { 
        background: linear-gradient(145deg, #B0B0B0, #8E8E8E); /* Soft Grey */
        color: white;
    }

    /* 🌟 Hover Effect - Adds Glow */
    .condition-box:hover {
        transform: scale(1.05);
        filter: brightness(1.2);
        box-shadow: 6px 6px 15px rgba(0, 0, 0, 0.4), 
                    inset -3px -3px 8px rgba(255, 255, 255, 0.6);
    }

      .shiny-btn {
        margin-top: 20px;
        background: linear-gradient(145deg, #5cc580, #44a866);
  color: white !important; /* Ensures white text */
  border: none;
  padding: 10px 20px;
  border-radius: 30px;
  cursor: pointer;
  font-size: 16px;
  font-weight: bold;
  text-align: center;
  text-shadow: none; /* Remove dark shadow */
  box-shadow: 4px 4px 8px rgba(0, 0, 0, 0.3), inset -2px -2px 6px rgba(255, 255, 255, 0.5);
  transition: all 0.3s ease-in-out;
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
  let boxId = $(this).attr('id');
  Shiny.setInputValue(boxId, true, {priority: 'event'});
});


    Shiny.addCustomMessageHandler('resetBoxes', function(data) {
      $('[id^=' + data.team + '_cond]').removeClass('selected');
    });
  ")),
  
  fluidRow(
    column(6, 
           div(class = "header", "COWBOYS"),
           div(class = "team-section",
               div(id = "team1_cond1", class = "condition-box", 
                   style = "background-color: rgba(0, 150, 0, 0.8);", "Ins 20"),  # ✅ Green
               div(id = "team1_cond2", class = "condition-box", 
                   style = "background-color: rgba(255, 165, 0, 0.8);", "Out 20"),  # ✅ Orange
               div(id = "team1_cond3", class = "condition-box", 
                   style = "background-color: rgba(200, 0, 0, 0.8);", "Non Comp"),  # ✅ Red
               div(id = "team1_cond4", class = "condition-box", 
                   style = "background-color: rgba(255, 255, 0, 0.8);", "TRY")  # ✅ Yellow
           )
    ),
    column(6, 
           div(class = "header", "OPPONENT"),
           div(class = "team-section",
               div(id = "team2_cond1", class = "condition-box", 
                   style = "background-color: rgba(0, 150, 0, 0.8);", "Ins 20"),  # ✅ Green
               div(id = "team2_cond2", class = "condition-box", 
                   style = "background-color: rgba(255, 165, 0, 0.8);", "Out 20"),  # ✅ Orange
               div(id = "team2_cond3", class = "condition-box", 
                   style = "background-color: rgba(200, 0, 0, 0.8);", "Non Comp"),  # ✅ Red
               div(id = "team2_cond4", class = "condition-box", 
                   style = "background-color: rgba(128, 128, 128, 0.8);", "TRY")
           )
    )
  ),
  fluidRow(
    column(6, 
           div(class = "header", "RESULTS"),
           div(class = "table-container", 
               reactableOutput("results_table"),
               
               # File Input - Keep it slightly lower but closer to buttons
               div(
                 style = "margin-top: 12px;",  # Slightly reduced spacing
                 fileInput("import_data", NULL, 
                           accept = c(".csv"), 
                           buttonLabel = "Browse", 
                           placeholder = "No file", 
                           width = "200px")
               ),
               
               # Buttons placed directly below with a minimal gap
               div(
                 style = "display: flex; justify-content: flex-start; gap: 12px; margin-top: 1px;",  # Reduced margin-top further
                 
                 actionButton("load_data", "Load", 
                              class = "shiny-btn",
                              style = "background: linear-gradient(145deg, #5b8fcc, #4a79b2); 
                                       color: white; 
                                       font-weight: bold; 
                                       padding: 10px 25px;
                                       border-radius: 15px; 
                                       box-shadow: 3px 3px 6px rgba(0, 0, 0, 0.3);"),
                 
                 downloadButton("export_data", "Export", 
                                class = "shiny-btn",
                                style = "background: linear-gradient(145deg, #5cc580, #44a866); 
                                         color: white; 
                                         font-weight: bold; 
                                         padding: 10px 25px;
                                         border-radius: 15px; 
                                         box-shadow: 3px 3px 6px rgba(0, 0, 0, 0.3);")
               
               
               )
               

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
                   h4("OPPONENT", align = "center", style = "font-weight: bold; font-size: 16px;"),
                   plotlyOutput("team2_pie", height = "300px", width = "100%")
               )
           )
           
    )
  )
)


server <- function(input, output, session) {
  
  cowboys_Set <- reactiveVal(1)  # ✅ Tracks Set for COWBOYS
  opponent_Set <- reactiveVal(1)  # ✅ Tracks Set for OPPONENT
  
  # Reactive values to store selected conditions
  selected_conditions <- reactiveValues(
    team1 = c(FALSE, FALSE, FALSE),
    team2 = c(FALSE, FALSE, FALSE)
  )
  
  addNewEntry <- function(team, condition) {
    color <- getColor(condition, team)
    
    # ✅ Assign the correct set number
    if (team == "COWBOYS") {
      set_number <- cowboys_Set()
      cowboys_Set(cowboys_Set() + 1)  # ✅ Increment COWBOYS counter
    } else {
      set_number <- opponent_Set()
      opponent_Set(opponent_Set() + 1)  # ✅ Increment OPPONENT counter
    }
    
    new_data <- data.frame(
      Order = nrow(results()) + 1,
      Set = set_number,  # ✅ Uses the correct counter
      Team = team,
      Result = condition,
      ColorName = color,
      stringsAsFactors = FALSE
    )
    
    results(rbind(new_data, results()))  # Add the new row at the top
  }
  
  
  
  
  results <- reactiveVal(data.frame(
    Order = integer(),
    Set = integer(),  # ✅ New "Set" column
    Team = character(),
    Result = character(),
    ColorName = character(),
    stringsAsFactors = FALSE
  ))
  
  
  
  set_counter <- reactiveVal(1)  # ✅ Tracks the "Set" count
  
  
  
  
  observeEvent(input$team1_cond1, { selected_conditions$team1[1] <- !selected_conditions$team1[1] })
  observeEvent(input$team1_cond2, { selected_conditions$team1[2] <- !selected_conditions$team1[2] })
  observeEvent(input$team1_cond3, { selected_conditions$team1[3] <- !selected_conditions$team1[3] })
  
  
  observeEvent(input$team2_cond1, { selected_conditions$team2[1] <- !selected_conditions$team2[1] })
  observeEvent(input$team2_cond2, { selected_conditions$team2[2] <- !selected_conditions$team2[2] })
  observeEvent(input$team2_cond3, { selected_conditions$team2[3] <- !selected_conditions$team2[3] })
  
  # ✅ Load previous session from CSV file
observeEvent(input$load_data, {
  req(input$import_data)  # Ensure a file is selected
  file_path <- input$import_data$datapath
  
  # Read the CSV file
  imported_data <- read.csv(file_path, stringsAsFactors = FALSE)
  
  # Ensure the imported data matches expected structure
  required_columns <- c("Order", "Set", "Team", "Result", "ColorName")
  if (all(required_columns %in% colnames(imported_data))) {
    results(imported_data)  # ✅ Update the table with imported data
  } else {
    showNotification("Invalid file format. Please upload a valid CSV.", type = "error")
  }
})

  # Corrected function to get color based on condition and team
  getColor <- function(condition, team) {
    if (condition == "Ins 20") {
      return("Green")  # ✅ Green for Ins 20
    } else if (condition == "Out 20") {
      return("Orange") # ✅ Orange for Out 20
    } else if (condition == "Non Comp") {
      return("Red")    # ✅ Red for Non Comp
    } else if (condition == "TRY") {
      return(ifelse(team == "COWBOYS", "Yellow", "Grey"))  # ✅ Yellow for Cowboys, Grey for Opponent
    } else {
      return("Black")  # ✅ Default (Failsafe)
    }
  }
  
  # ✅ Event Listeners for Cowboys (No Submit Button Needed)
  observeEvent(input$team1_cond1, { addNewEntry("COWBOYS", "Ins 20") })
  observeEvent(input$team1_cond2, { addNewEntry("COWBOYS", "Out 20") })
  observeEvent(input$team1_cond3, { addNewEntry("COWBOYS", "Non Comp") })
  observeEvent(input$team1_cond4, { addNewEntry("COWBOYS", "TRY") })
  
  # ✅ Event Listeners for Opponent (No Submit Button Needed)
  observeEvent(input$team2_cond1, { addNewEntry("OPPONENT", "Ins 20") })
  observeEvent(input$team2_cond2, { addNewEntry("OPPONENT", "Out 20") })
  observeEvent(input$team2_cond3, { addNewEntry("OPPONENT", "Non Comp") })
  observeEvent(input$team2_cond4, { addNewEntry("OPPONENT", "TRY") })
  
  
  
  output$results_table <- renderReactable({
    req(nrow(results()) > 0)  
    
    reactable(
      results(),
      columns = list(
        Order = colDef(name = "Order", align = "center"),
        Set = colDef(name = "Set", align = "center"),  # ✅ New column
        Team = colDef(name = "Team", align = "center"),
        Result = colDef(name = "Result", align = "center"),
        ColorName = colDef(
          name = "Colour",
          width = 110, 
          align = "center",
          cell = function(value) {
            color <- switch(
              value,
              "Green" = "rgba(0, 150, 0, 0.3)",    
              "Orange" = "rgba(255, 140, 0, 0.4)",  
              "Red" = "rgba(200, 0, 0, 0.3)",      
              "Yellow" = "rgba(230, 200, 0, 0.4)",  # ✅ Darker Yellow
              "Grey" = "rgba(100, 100, 100, 0.3)",
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
      defaultPageSize = 10
    )
  })
  
  
  
  
  
  
  
  
  output$export_data <- downloadHandler(
    filename = function() {
      paste("results_table_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(results(), file, row.names = FALSE)
    }
  )
  
  
  
  
  
  output$team1_pie <- renderPlotly({
    team_data <- results()[results()$Team == "COWBOYS", ]
    if (nrow(team_data) == 0) return(NULL)
    
    counts <- table(team_data$ColorName)
    total <- sum(counts)  # Get total trials
    
    colors <- c(
      "Black" = "rgba(0, 0, 0, 0.8)", 
      "Red" = "rgba(200, 0, 0, 0.8)", 
      "Orange" = "rgba(255, 140, 0, 0.85)",  # Slightly deeper Orange
      "Yellow" = "rgba(255, 220, 0, 0.85)",  # Slightly richer Yellow
      "Green" = "rgba(0, 130, 0, 0.85)",     # Slightly darker Green
      "Grey" = "rgba(100, 100, 100, 0.85)"   # ✅ Darker Grey
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
    team_data <- results()[results()$Team == "OPPONENT", ]
    if (nrow(team_data) == 0) return(NULL)
    
    counts <- table(team_data$ColorName)
    total <- sum(counts)  # Get total trials
    
    colors <- c(
      "Black" = "rgba(0, 0, 0, 0.8)", 
      "Red" = "rgba(200, 0, 0, 0.8)", 
      "Orange" = "rgba(255, 140, 0, 0.85)",  # Slightly deeper Orange
      "Yellow" = "rgba(255, 220, 0, 0.85)",  # Slightly richer Yellow
      "Green" = "rgba(0, 130, 0, 0.85)",     # Slightly darker Green
      "Grey" = "rgba(100, 100, 100, 0.85)"   # ✅ Darker Grey
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










