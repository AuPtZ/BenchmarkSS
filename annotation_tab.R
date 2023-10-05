###############################################.
## annotation - common objects ----
###############################################.
library(dplyr)

### 交互相应区域

load("data_preload/annotation/GSDCIC50.Rdata")

output$display_an <- renderUI(initial_an)

output$display_an_tb <- renderDataTable(GSDCIC50 %>% dplyr::filter(TCGA_DESC == input$an_input ))


output$run_AN <- downloadHandler(
  filename = function() {
    return(paste0(input$an_input,"_",input$an_input_type,"_","drug_annotation.txt"))
  },
  content = function(file) {
    
    if(input$an_input_type == "AUC"){
      rio::export(GSDCIC50 %>% ungroup() %>% 
                    dplyr::filter(TCGA_DESC == input$an_input) %>%
                    dplyr::select(c(Compound.name,Group)),
                  file,format = "tsv",row.names = F)
    }
    if(input$an_input_type == "ES"){
      rio::export(GSDCIC50 %>% ungroup() %>% 
                    dplyr::filter(TCGA_DESC == input$an_input) %>%
                    dplyr::select(c(Compound.name)),
                  file,format = "tsv",row.names = F)
    }
    

    
  }
)

initial_an <- tagList(
  h3("Welcome to Annotation module!"),
  p("This module primarily offers an initial drug annotation."),
  p("The annotation is sourced from the efficacy data of anti-cancer drugs within the GSDC database."),
  p("It includes IC50 values for 286 drugs interacting with 30 types of cancer cell lines."),
  p("In instances where multiple drug-cancer pairings are present, we have opted for the smallest IC50 value. "),
  p("We categorize an IC50 value of less than 10μM as 'effective', and conversely, as 'ineffective'. "),
  p("Within the Benchmark module, different methodologies necessitate varying formats of annotation files, hence it is crucial to select the appropriate mode prior to downloading."),
)