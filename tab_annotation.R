###############################################.
## annotation - common objects ----
###############################################.
library(dplyr)

### 交互相应区域

load("data_preload/annotation/GSDCIC50.Rdata")

output$display_an <- renderUI(initial_an)

output$display_an_tb <- renderDataTable(GSDCIC50 %>% 
                                          mutate(`IC50 value` = round(`IC50 value`, 5)) %>%
                                          dplyr::filter(TCGA_DESC == input$an_input) %>%
                                          dplyr::arrange(PubChem_Cid),
                                        server = FALSE,
                                        options = list(scrollX = TRUE,
                                                       fixedColumns = TRUE))


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
  includeMarkdown("www/tab_annotation.md")
)