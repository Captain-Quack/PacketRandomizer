library(shiny)
library(zip)

# Function to generate a randomized packet
function(categories) {
  packet <- rep("", 20)
  used_subcategories <- list(
    History = c(),
    Science = c(),
    Literature = c(),
    FineArtsOther = c(),
    RMPSS = c()
  )
  for (q in 1:4) {
    deck <- names(categories)
    for (i in 1:5) {
      if (q > 1 && i == 1) {
        # Enforce cross-quarter adjacency rule
        last_category <- strsplit(packet[(q - 1) * 5], ":")[[1]][1]
        deck <- setdiff(deck, last_category)
      }
      # Draw a category and subcategory
      cat <- sample(deck, 1)
      available_subs <- setdiff(categories[[cat]], used_subcategories[[cat]])
      subcat <- sample(available_subs, 1)
      used_subcategories[[cat]] <- c(used_subcategories[[cat]], subcat)
      deck <- setdiff(deck, cat)
      slot <- (q - 1) * 5 + i
      packet[slot] <- paste(cat, ":", subcat)
    }
    # Shuffle within the quarter
    quarter_indices <- ((q - 1) * 5 + 1):((q - 1) * 5 + 5)
    packet[quarter_indices] <- sample(packet[quarter_indices])
  }
  
  # Final check for adjacency issues across ALL slots
  for (i in 1:(length(packet) - 1)) {
    while (strsplit(packet[i], ":")[[1]][1] == strsplit(packet[i + 1], ":")[[1]][1]) {
      # Swap with a random position in the same quarter to resolve adjacency
      quarter_start <- ((i - 1) %/% 5) * 5 + 1
      quarter_end <- quarter_start + 4
      packet[quarter_start:quarter_end] <- sample(packet[quarter_start:quarter_end])
    }
  }
  
  return(packet)
}

# Wrapper function for TU and B lists
generate_packet_TUandB <- function(categories) {
  TU <- generate_packet(categories)
  B <- generate_packet(categories)
  for (q in 1:4) {
    quarter_indices <- ((q - 1) * 5 + 1):((q - 1) * 5 + 5)
    for (i in quarter_indices) {
      while (strsplit(TU[i], ":")[[1]][2] == strsplit(B[i], ":")[[1]][2]) {
        B[quarter_indices] <- sample(B[quarter_indices])
      }
    }
  }
  formatted_packet <- c(
    paste0("TU", 1:20, ". ", TU),
    paste0("B", 1:20, ". ", B)
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
        p("Each category must have exactly four subcategories, separated by commas (e.g., 'American, European, Other, World')."),
        textInput("history", "History (comma-separated)", "American,European,Other,World"),
        textInput("science", "Science (comma-separated)", "Biology,Chemistry,Physics,Other"),
        textInput("literature", "Literature (comma-separated)", "American,British,Euro/Ancient,World"),
        textInput("finearts", "Fine Arts & Other (comma-separated)", "Painting/Sculpture,Music,Other,Geo/CE/Other"),
        textInput("rmpss", "RMPSS (comma-separated)", "Religion,Mythology,Philosophy,Social Science"),
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
  observeEvent(input$randomize, {
    categories <- list(
      History = strsplit(input$history, ",")[[1]],
      Science = strsplit(input$science, ",")[[1]],
      Literature = strsplit(input$literature, ",")[[1]],
      FineArtsOther = strsplit(input$finearts, ",")[[1]],
      RMPSS = strsplit(input$rmpss, ",")[[1]]
    )
    valid_input <- all(sapply(categories, length) == 4)
    if (!valid_input) {
      output$packet_output <- renderText("Error: Each category must have exactly 4 subcategories.")
    } else {
      packet <- generate_packet_TUandB(categories)
      output$packet_output <- renderPrint({ cat(packet, sep = "\n") })
      observeEvent(input$copy, {
        session$sendCustomMessage("copyText", paste(packet, collapse = "\n"))
      })
    }
  })
  
  output$download_packets <- downloadHandler(
    filename = function() { paste0(input$tournament_name, "_Packets.zip") },
    content = function(file) {
      temp_dir <- file.path(tempdir(), "quizbowl_packets")
      unlink(temp_dir, recursive = TRUE)
      dir.create(temp_dir, showWarnings = FALSE)
      categories <- list(
        History = strsplit(input$history, ",")[[1]],
        Science = strsplit(input$science, ",")[[1]],
        Literature = strsplit(input$literature, ",")[[1]],
        FineArtsOther = strsplit(input$finearts, ",")[[1]],
        RMPSS = strsplit(input$rmpss, ",")[[1]]
      )
      for (i in 1:input$num_packets) {
        packet <- generate_packet_TUandB(categories)
        writeLines(packet, file.path(temp_dir, paste0(input$tournament_name, " - Packet ", i, ".txt")))
      }
      zip::zipr(file, files = list.files(temp_dir, full.names = TRUE))
    },
    contentType = "application/zip"
  )
}

shinyApp(ui = ui, server = server)
