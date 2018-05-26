
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(shiny)
library(leaflet)
library(shinyjs)
library(XLConnect) 
library(DT)
fileForDatabase                ='dengueLocations.xlsx'
dengueOccurances <- readWorksheet(loadWorkbook(fileForDatabase),sheet=1,header = TRUE) 
           
           
# ==== server
server <- function(input, output) {
  
  ### ------------------------
  ### User position
  ### ------------------------
  
  output$lat <- renderPrint({
    if(!is.null(input$lat)){
    input$lat
    }
  })
  
  output$long <- renderPrint({
    if(!is.null(input$lat)){
    input$long
    }
  })
  
  # output$geolocation <- renderPrint({
  #   input$geolocation
  # })
  
  
  
  ### ------------------------
  ### Mapping a submission
  ### ------------------------
  # Basic map 
  output$submitDataToMap <- renderLeaflet({
    if(!is.null(input$lat)){
      lat <- input$lat
      lng <- input$long
      
      leaflet() %>% 
        setView(lng, lat, zoom=2 ) %>%
        addTiles(
          urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
          attribution = 'Trinidadian mapping initiative' )      %>%
        addMarkers(lng, lat)
    }
    
 
    
  })
  
  # Find geolocalisation coordinates when user clicks
  observeEvent(input$geoloc, {
    js$geoloc()
  })
  
  
  # zoom on the corresponding area
  observe({
    if(!is.null(input$lat)){
      submitDataToMap <- leafletProxy("submitDataToMap")
      dist <- 0.01
      lat <- input$lat
      lng <- input$long
      submitDataToMap %>% fitBounds(lng - dist, lat - dist, lng + dist, lat + dist)
    }
  })
  
  ### ------------------------
  ### Mapping a submitted data
  ### ------------------------
  
  
  output$occuranceDatabase <- renderLeaflet({
    leaflet(data = dengueOccurances) %>% addTiles(attribution = 'Trinidadian mapping initiative' ) %>%
      addMarkers(~long, ~lat, clusterOptions = markerClusterOptions())
    
       
      # lat <- input$lat
      # lng <- input$long
      # 
      # leaflet() %>% 
      #   setView(lng, lat, zoom=2 ) %>%
      #   addTiles(
      #     urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
      #     attribution = 'Trinidadian mapping initiative' )      %>%
      #   addMarkers(lng, lat)
    
  }

  )
  ### ------------------------
  ### Table of data
  ### ------------------------
  
  output$tbl = DT::renderDataTable(
    dengueOccurances, options = list(lengthChange = FALSE)
  )
  
  output$downloadData <- downloadHandler(
    filename <- function() {
      paste("dengueOutbreakDatabase.zip", "zip", sep=".")
    },
    
    content <- function(file) {
      file.copy("dengueOutbreakDatabase.zip", file)
    },
    contentType = "application/zip"
  )
  
}
