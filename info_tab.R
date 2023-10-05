


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
    shiny::h3("Why we built SSP?"),
    shiny::p("The growing interest in human genes and accessibility of high-throughput technologies directly lead to exponential increase data size in pharmacotranscriptomic profiles.",br(),
             "Profile-based method has been widely used for screening drugs and identifying molecular actions of drugs, which could remarkably enhance novel drug-disease pair discovery without relying on drug- or disease-specific prior knowledge. ",
             strong("This analysis method was named “signature search (SS)”."),
             "Meanwhile, various SS methods were proposed, but how to find the optimal method and top differentially expressed genes (DEGs) for certain data is still challenging. ",
             "How to find the optimal methods and parameters for different signature input and drug profiles is still challenging. ",
             br(),
             strong("Signature Search Polestar (SSP)"),
             " is a webserver integrating the largest uniform drug profiles in L1000 with five state-of-the-art (XSum, CMap, GESA, ZhangScore, XCos) and provide three modules to facilitate drug repurposing:",
             br(),
             "1.	Benchmark: Two indices (AUC and Enrichment Score) based on drugs annotations are employed to evaluate the performance of SS methods at different top DEGs. The results indicate the best evaluation method and the top DEGs for input disease signature.",
             br(),
             "2.	Robustness: A robust index based on drug profiles itself is developed to evaluate the overall performance of SS methods at different top DEGs. This module is applicable when meets insufficient drug annotations.",
             br(),
             "3.	Application: Three tools (single method, SS_all, and SS_cross) enable user to utilize optimal SS methods with disease signatures. The results present scores of promising drug repurposing for disease signature.",
             br(),
             "Additionally, SSP webserver is deployed at a high performance servers for better user experience and we opensource all codes at ",
             a("https://gitee.com/auptz/benchmark-ss",
               herf = "https://gitee.com/auptz/benchmark-ss"),
             ". Everyone could directly use or DIY own SSP webserver by interest.",
             br(),
             img(src = "imginfo0.PNG",width = "700px"),
             
             )
    
    
  )
})


# Q2: how to benchmark/robustness?
output$display_Q2 = renderUI({
  tagList(
    shiny::h3("How to use Benchmark and interpret the results?"),
    shiny::p("It is very easy to use Benchmark as it only requires at most 3 files, a signature (necessary), and drug annotations for AUC or enrichment score (ES) (at least one of them).",
             br(),
             "The demo file is provided on the data page, and you can simply look at them to prepare your own files.",
             br(),
             "Drug annotations are labels indicating whether the drug is positive and/or negative in your selected drug profile set.",
             br(),
             "For AUC, you should lable durgs with whether ",
             span("Postive and Negative", style = "color:red"),
             " (case sensitive)",
             br(),
             "For ES, you just need provide the name of ",
             span("Postive", style = "color:red"),
             " drug without labels",
             br(),
             strong("Please note that you are not required to provide all drug annotations, but more annotations lead to more accurate results."),
             br(),
             "The detailed procedure is provided in the corresponding operation page.",
             br(),
             shiny::p("Well, it is very easy to understand the results in SSP.",
                      br(),
                      strong("For the Benchmark module, here are two types of results:"),
                      br(),
                      "If you upload a file for the AUC method, then you will get a result like this:",
                      br(),
                      img(src = "imginfo1.PNG",width = "700px"),
                      br(),
                      img(src = "imginfo2.PNG",width = "700px"),
                      br(),
                      "If you upload a file for the ES method, then you will get a result like this:",
                      br(),
                      img(src = "imginfo3.PNG",width = "700px"),
                      br(),
                      strong("So, it is very easy to find the best topN and method based on the signature and drug profiles."),
                      br(),
                      "Notably, when ES and AUC are combined, users have to determine the best topN and method based on performance.",
                      # br(),
                      # strong("For Application module, we use a evaluation index."),
             )
             )
  )
})


# Q3: how to interpret the result?
output$display_Q3 = renderUI({
  tagList(
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
    shiny::h3("How to download curated data?"),
    shiny::p("To download data, please navigate to the data page for curated data.")
  )
})


# Q6: how to get job result again?
output$display_Q6 = renderUI({
  tagList(
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
