
output$dl_drug_exp <- downloadHandler(
  filename = function() {
    stringr::str_split(input$sel_experiment_dl,".rdata")[[1]][1]
    return(paste0(stringr::str_split(input$sel_experiment_dl,".rdata")[[1]][1],"_profiles.txt"))
  },
  content = function(file) {
    load(paste0("data_preload/drugexp/",input$sel_experiment_dl))
    rio::export(exp_GSE92742, file,format = "tsv",row.names = T)
    
  }
)


output$dl_drug_ann <- downloadHandler(
  filename = function() {
    stringr::str_split(input$sel_experiment_dl,".rdata")[[1]][1]
    return(paste0(stringr::str_split(input$sel_experiment_dl,".rdata")[[1]][1],"_annotations.txt"))
  },
  content = function(file) {
    load(paste0("data_preload/drugexp/",input$sel_experiment_dl))
    rio::export(sig_GSE92742, file,format = "tsv",row.names = T)
  }
)


output$dl_demo <- downloadHandler(
  filename = function() {
    return("demo.zip")
  },
  content = function(file) {
    zip::zip(zipfile = file,
             c("demo/drug_annotation_ES.txt",
               "demo/drug_annotation_AUC.txt",
               "demo/signature.txt",
               "demo/signature2.txt"),
             mode = "cherry-pick")
  }
)

output$dl_script <- downloadHandler(
  filename = function() {
    return("demoscript.zip")
  },
  content = function(file) {
    zip::zip(zipfile = file,
             c("R/global.R","R/Utils_BM.R","R/Utils_SM.R","R/SS.R"),
             mode = "cherry-pick")
  }
)