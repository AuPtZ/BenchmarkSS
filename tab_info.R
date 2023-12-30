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




# verbatimTextOutput(outputId = "SI")
# Q1: why we built SSP?
output$display_Q1 = renderUI({
  tagList(
    downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
    includeMarkdown("www/info_Q1.md")
  )
})


# Q2: how to benchmark/robustness?
output$display_Q2 = renderUI({
  tagList(
    downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
    includeMarkdown("www/info_Q2.md")
  )
})


# Q3: how to interpret the result?
output$display_Q3 = renderUI({
  tagList(
    downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
    shiny::h3("How to use Robustness and interpret the results?"),
    shiny::p("Robustness provides a pre-computed result of each SS method at different topN. It is useful when there are insufficient annotation for drugs.",
             br(),
             "In Benchmark module, we test signature search methods based on annotation of drugs. Actually, it may be inappropriate when profiles without sufficient annotation..",
             br(),
             "Therefore, we test the performance of SS methonds based on ",strong("profile self-similarity!"),
             br(),
             "We briefly label these drugs from 1 to N, where N is the number of drugs in one set.",
             br(),
             "For each drug profile, we extract the top x up-regulated and top x down-regulated DEGs as its signature, which we then query into one of the SS methods to obtain matching scores for these drugs. ",
             br(),
             "Next, we rank the drugs based on their scores.",
             br(),
             "Three parameters are used to assess the robustness of these methods at different x:",
             br(),
             strong("(1) Correlation (R) of the input and top1 output for all drugs."),
             br(),
             strong("(2) The mean of the difference scores between the top1 and top2 outputs."),
             br(),
             strong("(3) The standard deviation (SD) of the difference between the scores of top1 and top2 outputs."),
             br(),
             "Finally, the drug retrieval performance score can be expressed by the following formula: ",
             # div(style = "text-align:center",
             #     img(src ="imgrb1.svg",width = "350px"),
             # ),
             
             '$$
             performance score =  \\frac{ Mean \\times R }{SD}
             $$',
    
    "A satisfactory performance is achieved if the method ",
    strong("accurately returns the input drug (stronger correlation)"),
    " and ",
    strong("distinguishes well between drugs (more significant difference score) with maintains good stability (lower SD). "),
    br(),
    "In this study, we tested performance scores for the cases of x at 100,110,120......480, respectively.",
    img(src = "imginfo10.PNG",width = "700px"),
    br(),
    "As shown in the figure, a higher Rscore indicates greater robustness, indicating that the method is more accurate.",
    br(),
    strong("The results may differ from the Benchmark because it is an overall performance evaluation.")
    )
    
    
  )
})

# Q4: how to query drug in Application?
output$display_Q4 = renderUI({

  tagList(
    downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
    shiny::h3("How to query drug in Application and interpret the results?"),
    shiny::p(withMathJax(),

             "Once we have established the optimal approach, we can upload a signature and choose the module (Single Method, SS_all, SS_cross) to identify promising drugs.",
             br(),
             "Within the application module, we offer three tools for discovering drugs based on disease signatures.",
             br(),
             strong("The single method is a conventional search technique where users can upload a signature, select a profile set, and one SS method. The outcomes will present drugs with scores. >0 signifies that the drug could exacerbate the disease, while <0 suggests that it may mitigate the disease."),
             br(),
             "The results are depicted in a dotplot.",
             br(),
             img(src = "imginfo4.PNG",width = "700px"),
             br(),
             "Moreover, the SS_all module and SS_cross were devised to incorporate the signature search techniques to investigate active drugs.",
             br(),
             "For the SS_all module, we aggregate drug ranks in the same direction (>0 or <0 for disease signature) using robust rank aggregation and assign an overall score (0~1) to each active ingredient. Hence, lower overall scores indicate greater significance across all methods.",
             br(),
             img(src = "imginfo5.PNG",width = "700px"),
             br(),
             img(src = "imginfo6.PNG",width = "700px"),
             br(),
             "Furthermore, this method is appropriate for identifying drugs with polypharmacological effects based on multiple signatures.",
             br(),
             "For the SS_cross module, we can compute the scores of drugs for two disparate pharmacological signatures \\(Score_{sig1}\\) and \\(Score_{sig2}\\) 
             via a specific signature search method.Then, drugs were divided into 
             four quadrants based on the scores,",
             "(Q1: both scores >0, 
             Q2: \\(Score_{sig1}\\) >0 but \\(Score_{sig2}\\) <0, 
             Q3: both scores <0, 
             Q4: \\(Score_{sig1}\\) <0 but \\(Score_{sig2}\\) >0). 
             Finally, we compute an integrated score by taking the square root of the absolute values:",
             br(),
             '$$ 
             Score_{sum} =  \\sqrt{ abs(Score_{sig1} \\times Score_{sig2}) }
             $$',
             br(),
             img(src = "imginfo7.PNG",width = "700px"),
             br(),
             img(src = "imginfo8.PNG",width = "700px"),

             
             ),

    
  )
})




# Q5: how to download data?
output$display_Q5 = renderUI({
  tagList(
    downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
    shiny::h3("How to download curated data?"),
    shiny::p("To download data, please navigate to the data page for curated data.")
  )
})


# Q6: how to get job result again?
output$display_Q6 = renderUI({
  tagList(
    downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
    shiny::h3("How to get job result again?"),
    shiny::p("To regain job results, please navigate to the job center page and enter your job ID.",
             br(),
             "It is important to note that there may be instances where your job is unsuccessful due to server-related issues.",
             br(),
             "In such cases, you will need to resubmit your application.",
             br(),
             img(src = "imginfo9.PNG",width = "700px"))
  )
})



## get sessioninfo
if(F){
  # export package info
  
  sI <- devtools::session_info()
  save( sI , file = "sessioninfo.rdata")
  # print(sI, RNG = TRUE, locale = FALSE)
}
