

### 交互相应区域

# 初始化
output$display_rb <- renderUI(initial_rb)

# 重置
observeEvent(input$reset_rb, {
  reset("rb_input")
  output$display_rb <- renderUI(initial_rb)
})

# 输出
observeEvent(input$runRB, {
  isolate({
    output$display_rb <- renderUI({
      isolate({
        dir_rb = paste0("data_preload/robustness/",input$sel_experiment_rb) 
        to_plot_rb <- get_rb_plot(dir_rb, input$sel_ss_rb)
      })
      tagList(
        shiny::h3("Robustness score"),
        renderPlotly(to_plot_rb)
      )
    })
  })
})


initial_rb <- tagList(
  h3("Welcome to Robustness module!"),
  # h4("For demo files, please go to data page."),
  p(withMathJax(),
    "In this module, you can evaluate the performance of signature search (SS) methods.",
    br(),
    "In the Benchmark module, we tested SS methods based on drug annotations. However, it may not be appropriate when there is insufficient annotation for the profiles. ",
    br(),
    "Hence, we test the performance of SS methonds based on ",strong("profile self-similarity!"),
    br(),
    "Briefly, we labeled these drugs from 1 to N (N being the order of drugs in one set).",
    br(),
    "For each drug profile, we extracted the top x up-regulated and top x down-regulated DEGs and defined them as a signature. This signature was then queried into one of the SS methods to obtain the matching scores of these drugs.",
    br(),
    "We then ranked the drugs based on their scores.",
    br(),
    "To evaluate the robustness of these methods at different x values, three parameters were used:",
    br(),
    strong("(1) Correlation (R) of the input and top1 output for all drugs."),
    br(),
    strong("(2) The mean of the difference scores between the top 1 and top 2 outputs."),
    br(),
    strong("(3) The standard deviation (SD) of the difference between the scores of the top 1 and top 2 outputs"),
    br(),
    "Finally, the drug retrieval performance score can be expressed by the following formula:,",
    # div(style = "text-align:center",
    #     img(src ="imgrb1.svg",width = "350px"),
    # ),
    
    '$$ 
    performance score =  \\frac{ Mean \\times R }{SD}
    $$',

    "A satisfactory performance was achieved if the method ",
    strong("accurately return the input drug (stronger correlation)"),
    " and ",
    strong("distinguish well between drugs (more significant difference score) and maintained good stability (lower SD). "),
    br(),
    "In this study, we tested performance scores for the cases of x at 100,110,120......480, respectively."
  ),
  # how to use
  br(),
  p(
    "For more information, please vist ",
    strong("Info-Help"),
    " page"
  )
)
