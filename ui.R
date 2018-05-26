


# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(leaflet)
library(shinyjs)


# ==== fonction allowing geolocalisation
jsCode <- '
shinyjs.geoloc = function() {
navigator.geolocation.getCurrentPosition(onSuccess, onError);
function onError (err) {
Shiny.onInputChange("geolocation", false);
}
function onSuccess (position) {
setTimeout(function () {
var coords = position.coords;
console.log(coords.latitude + ", " + coords.longitude);
Shiny.onInputChange("geolocation", true);
Shiny.onInputChange("lat", coords.latitude);
Shiny.onInputChange("long", coords.longitude);
}, 5)
}
};
'
shinyUI(navbarPage(
  "#codeLocal",
  id = "nav",
  tabPanel(
    "Submit outbreak",
    titlePanel("Submit outbreak"),
    
    
    # Tell shiny we will use some Javascript
    useShinyjs(),
    # extendShinyjs(text = jsCode),
    extendShinyjs(text = jsCode, functions = c("geoloc")),
    #Needed for shiny.io website
    # One button and one map
    # Show a plot of the generated distribution
    fluidRow(
      conditionalPanel(
        condition = " input.lat > '0' ",
      column(
      width = 2,
      verbatimTextOutput("lat"),
      verbatimTextOutput("long")
    )
      )
    ),
    br(),
    actionButton("geoloc",
                 "Sumbit",
                 class = "btn btn-primary",
                 onClick = "shinyjs.geoloc()"),
    leafletOutput("submitDataToMap", height = "600px")
  )
  ,
  tabPanel(
    "Reported outbreaks",
    
    leafletOutput("occuranceDatabase", height = "600px")
    
  ),
  tabPanel(
    "Download database",
    
    downloadButton('downloadData', 'Download'),
    DT::dataTableOutput('tbl') 
  )
  
))
