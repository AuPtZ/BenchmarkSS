

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
  includeMarkdown("www/tab_robustness.md")
)
