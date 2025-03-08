library(shiny)
library(zip)

# Function to generate a randomized packet
generate_packet <- function(categories, n_tossups = 20) {
  
  # don't change this number without changing the rest of the input rules around this program. 
  n_quarters <- 4
  quarter_size <- n_tossups / n_quarters
  
  packet <- rep("", n_tossups)
  used_subcategories <- lapply(categories, function(x) character())
  for (q in seq_len(n_quarters)) {
    deck <- names(categories)
    for (i in seq_len(quarter_size)) {
      if (q > 1 && i == 1) {
        last_category <- strsplit(packet[(q - 1) * quarter_size], ":")[[1]][1]
        deck <- setdiff(deck, last_category)
      }
      if (length(deck) == 0) {
        deck <- names(categories)
        if (q > 1 && i == 1) {
          deck <- setdiff(deck, last_category)
        }
      }
      # Draw a category and subcategory
      cat <- sample(deck, 1)
      # Handle subcategories, resetting if all have been used
      available_subs <- setdiff(categories[[cat]], used_subcategories[[cat]])
      if (length(available_subs) == 0) {
        used_subcategories[[cat]] <- character()
        available_subs <- categories[[cat]]
      }
      subcat <- sample(available_subs, 1)
      used_subcategories[[cat]] <- c(used_subcategories[[cat]], subcat)
    
      deck <- setdiff(deck, cat)
      slot <- (q - 1) * quarter_size + i
      packet[slot] <- paste(cat, subcat, sep=":")
    }
    # Shuffle within the quarter
    quarter_indices <- ((q - 1) * quarter_size + 1):(q*quarter_size)
    packet[quarter_indices] <- sample(packet[quarter_indices])
  }

  # Final check for adjacency issues across ALL slots
  for (i in seq_len(n_tossups-1)) {
    while (strsplit(packet[i], ":")[[1]][1] == strsplit(packet[i + 1], ":")[[1]][1]) {
      # Swap with a random position in the same quarter to resolve adjacency
      quarter_start <- ((i - 1) %/% quarter_size) * quarter_size + 1
      quarter_end <- quarter_start + quarter_size - 1
      packet[quarter_start:quarter_end] <- sample(packet[quarter_start:quarter_end])
    }
  }

  return(packet)
}

# Wrapper function for TU and B lists
generate_packet_TUandB <- function(categories, n_tossups) {
  TU <- generate_packet(categories, n_tossups)
  B <- generate_packet(categories, n_tossups)
  for (i in seq_len(n_tossups)) {
      while (strsplit(TU[i], ":")[[1]][2] == strsplit(B[i], ":")[[1]][2]) {
        B <- sample(B) 
        #  I was going to figure out how to shuffle just the relevant 
        # quarters like the old version does, but I don't know enough R for that 
        # ¯\_(ツ)_/¯ - Mason 
      }
  }
  formatted_packet <- c(
    paste0("TU", seq_len(n_tossups), ". ", TU),
    paste0("B",  seq_len(n_tossups), ". ", B)
  )
  return(formatted_packet)
}


# UI layout
ui <- fluidPage(
  titlePanel("Quizbowl Packet Randomizer"),

  # Custom CSS for fixed height and font size
  tags$style(HTML("
        #packet_output {
            height: 749px; /* Fixed height */
            overflow-y: auto; /* Enable scrolling if content exceeds height */
            white-space: pre-wrap;
            font-size: 12px; /* Smaller font size */
        }
        .left-panel {
            height: 500px; /* Fixed height for left panels */
        }
        .header-with-button {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
    ")),

  # Layout for input and output panels
  fluidRow(
    column(
      width = 5,
      wellPanel(
        h3("Generate Single Packet"),
        numericInput("num_tossups", "Number of Tossups (rounded down to a multiple of four):", value = 20, min = 1),
        p("Enter four or more subcategories per subject. Seperate subcategories by commas."),
        textInput("history", "History", "American,European,Other,World"),
        textInput("science", "Science", "Biology,Chemistry,Physics,Other"),
        textInput("literature", "Literature", "American,British,Euro/Ancient,World"),
        textInput("finearts", "Fine Arts & Other", "Painting/Sculpture,Music,Other,Geo/CE/Other"),
        textInput("rmpss", "RMPSS", "Religion,Mythology,Philosophy,Social Science"),
        actionButton("randomize", "Display Single Packet")
      ),
      wellPanel(
        h3("Generate Tournament"),
        textInput("tournament_name", "Tournament Name", "Sample Tournament"),
        numericInput("num_packets", "Number of Packets", value = 1, min = 1),
        downloadButton("download_packets", "Download Packets")
      )
    ),
    column(
      width = 5,
      wellPanel(
        div(class = "header-with-button",
            h3("Randomized Packet"),
            actionButton("copy", "Copy to Clipboard")
        ),
        verbatimTextOutput("packet_output")
      )
    )
  ),

  # JavaScript for clipboard functionality
  tags$script(HTML("
        function copyToClipboard(text) {
            const el = document.createElement('textarea');
            el.value = text;
            document.body.appendChild(el);
            el.select();
            document.execCommand('copy');
            document.body.removeChild(el);
        }
        Shiny.addCustomMessageHandler('copyText', function(message) {
            copyToClipboard(message);
        });
    "))
)

# Server logic
server <- function(input, output, session) {
  observeEvent(input$num_tossups, {
    adjusted_tossups <- input$num_tossups - (input$num_tossups %% 4)
    
    if (input$num_tossups %% 4 != 0) {
      updateNumericInput(session, "num_tossups", value = adjusted_tossups)
    }
  }, ignoreInit = TRUE)
  
  observeEvent(input$randomize, {
    categories <- list(
      History = strsplit(input$history, ",")[[1]],
      Science = strsplit(input$science, ",")[[1]],
      Literature = strsplit(input$literature, ",")[[1]],
      FineArtsOther = strsplit(input$finearts, ",")[[1]],
      RMPSS = strsplit(input$rmpss, ",")[[1]]
    )
    
    valid_input <- all(sapply(categories, length) >= 4)
    if (!valid_input) {
      output$packet_output <- renderText("Error: Each category must have at least 4 subcategories.")
      return() 
    } 
    
    packet <- generate_packet_TUandB(categories, input$num_tossups)
    output$packet_output <- renderPrint({ cat(packet, sep = "\n") })
    
    observeEvent(input$copy, {
      session$sendCustomMessage("copyText", paste(packet, collapse = "\n"))
    })
  })
}


shinyApp(ui = ui, server = server)
