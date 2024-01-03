output$dl_manual_pdf <- downloadHandler(
  # filename = "manual of SSP V2.pdf",
  # content = function(file) {
  #   file.copy("manual of SSP V2.pdf", file)
  # }
  
  filename = function() {
    return("manual of SSP.pdf")
  },
  content = function(file) {
    file.copy("demo/manual of SSP V2.pdf", file)
    # zip::zip(zipfile = file,
    #          c("demo/manual of SSP V2.pdf"),
    #          mode = "cherry-pick")
  }
)



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
               "demo/signature2.txt",
               "demo/manual of SSP V2.pdf"),
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







output$display_about =  renderUI({
  
  tagList(
    shiny::h3("Session info"),
    shiny::p("We provide session info for users who want to perform our job in self computer"),
    renderPrint(sessionInfo()),
    shiny::h3("Browsing Map"),
    div(
      tags$script(src="//rf.revolvermaps.com/0/0/7.js?i=5jq3pohyu8j&amp;m=0&amp;c=ff0000&amp;cr1=ffffff&amp;sx=0",
                  async="async"
      ),style = "width:80%;margin:0 auto;"
    ),
    # runjs('<script type="text/javascript" src="//rf.revolvermaps.com/0/0/7.js?i=5jq3pohyu8j&amp;m=0&amp;c=ff0000&amp;cr1=ffffff&amp;sx=0" async="async"></script>'),
  )

  
})




# # verbatimTextOutput(outputId = "SI")
# # Q1: why we built SSP?
# output$display_Q1 = renderUI({
#   tagList(
#     downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
#     includeMarkdown("www/info_Q1.md")
#   )
# })
# 
# 
# # Q2: how to benchmark/robustness?
# output$display_Q2 = renderUI({
#   tagList(
#     downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
#     includeMarkdown("www/info_Q2.md")
#   )
# })
# 
# 
# # Q3: how to interpret the result?
# output$display_Q3 = renderUI({
#   tagList(
#     
#     downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
#     withMathJax(),
#     includeMarkdown("www/info_Q3.md")
#     
#   )
# })
# 
# # Q4: how to query drug in Application?
# output$display_Q4 = renderUI({
#   tagList(
#     downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
#     withMathJax(),
#     includeMarkdown("www/info_Q4.md")
#   )
# })
# 
# 
# 
# 
# # Q5: how to download data?
# output$display_Q5 = renderUI({
#   tagList(
#     downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
#     includeMarkdown("www/info_Q5.md")
#   )
# })
# 
# 
# # Q6: how to get job result again?
# output$display_Q6 = renderUI({
#   tagList(
#     downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
#     includeMarkdown("www/info_Q6.md")
#   )
# })
# 
# # Q7: how to annotate drugs?
# output$display_Q7 = renderUI({
#   tagList(
#     downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
#     includeMarkdown("www/info_Q7.md")
#   )
# })
# 
# # Q8: How to query drugs if I have a drug signature?
# output$display_Q8 = renderUI({
#   tagList(
#     downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
#     includeMarkdown("www/info_Q8.md")
#   )
# })
# 
# # Q9: How to find the best topN and method?
# output$display_Q9 = renderUI({
#   tagList(
#     downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
#     includeMarkdown("www/info_Q9.md")
#   )
# })
# 
# # Q10: How to deployed SSP in my own computer or server?
# output$display_Q10 = renderUI({
#   tagList(
#     downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
#     includeMarkdown("www/info_Q10.md")
#   )
# })
