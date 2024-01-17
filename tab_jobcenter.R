###############################################.
## JOBCENTER - common objects ----
###############################################.


library(dplyr)
library(shinyjs)
### 交互相应区域

# 初始化
output$display_jc <- renderUI(initial_jc)

## 替换
## renderPlot((
## renderPlotly(ggplotly(

# 重置
observeEvent(input$reset_jc, {
  reset("jc_input")
  output$display_jc <- renderUI(initial_jc)
})

# 报警层


# 运行层
observeEvent(input$jobid_get, {
  # 报警子层
  
  
  output$display_jc <- renderUI({
    
    isolate({
      
      # print("开始判断~")
      
      if(gsub("[^[:alnum:]]","",input$jobid_input) == "" | is.null(input$jobid_input)){
        shinyWidgets::sendSweetAlert(
          session = session,
          title = "Error...",
          text = "Please input vaild jobid",
          type = "error"
        )
      }
      
      
      req(gsub("[^[:alnum:]]","",input$jobid_input) != "")
      req(!is.null(input$jobid_input))
      
      # print("开始获取job_info~")
      print(input$jobid_input)
      job_info =  read_from_db(input$jobid_input)
      # save(job_info,file = "111.rdata")
      # print(paste0("job_info is",job_info))
      
      if(length(job_info) <= 1){
        shinyWidgets::sendSweetAlert(
          session = session,
          title = "Error...",
          text = "Please Check the your jobid, \n or maybe your job submitted is still running background.",
          type = "error"
        )
      }
      
      # print("job_info判断")
      req(length(job_info) >1)
      req(job_info$yourtable)
      req(job_info$yourmodule)
      
      
      if(job_info$yourmodule == "ALL (ES and AUC)"){
        
        tagList(
          shiny::h3("Job info"),
          renderTable(job_info$yourjob, striped = T, hover = T, spacing = "l",
                      bordered = T, rownames = F, colnames = F ),
          shiny::h3("Results of AUC"),
          renderPlotly(ggplotly(draw_dr_auc(job_info$yourtable$`AUC`))),
          DT::renderDataTable(job_info$yourtable$`AUC`,
                              server = FALSE),
          shiny::br(),
          shiny::h3("Results of ES"),
          renderPlotly(ggplotly(draw_dr_es(job_info$yourtable$`ES`))),
          DT::renderDataTable(job_info$yourtable$`ES` ,
                              server = FALSE)
        )
        
      } else if(job_info$yourmodule == "ES" ){
        
        tagList(
          shiny::h3("Job info"),
          renderTable(job_info$yourjob, striped = T, hover = T, spacing = "l",
                      bordered = T, rownames = F, colnames = F ),
          shiny::h3(paste0("Plot summary of"),job_info$yourmodule),
          renderPlotly(ggplotly(draw_dr_es(job_info$yourtable))),
          shiny::br(),
          shiny::h3(paste0("Results of "),job_info$yourmodule),
          DT::renderDataTable(job_info$yourtable,server = FALSE)
        )
        
      } else  if(job_info$yourmodule == "AUC" ){
        tagList(
          shiny::h3("Job info"),
          renderTable(job_info$yourjob, striped = T, hover = T, spacing = "l",
                      bordered = T, rownames = F, colnames = F ),
          shiny::h3(paste0("Plot summary of"),job_info$yourmodule),
          renderPlotly(ggplotly(draw_dr_auc(job_info$yourtable))),
          shiny::br(),
          shiny::h3(paste0("Results of "),job_info$yourmodule),
          DT::renderDataTable(job_info$yourtable,server = FALSE)
        )
      } else  if(job_info$yourmodule == "singlemethod" ){
        
        tagList(
          shiny::h3("Job info"),
          renderTable(job_info$yourjob, striped = T, hover = T, spacing = "l",
                      bordered = T, rownames = F, colnames = F ),
          shiny::h3("Plot summary"),
          renderPlotly(ggplotly(draw_single(job_info$yourtable))),
          shiny::h3("Results"),
          DT::renderDataTable(job_info$yourtable,server = FALSE),
        )
        
      } else  if(job_info$yourmodule  == "SS_cross"){
        tagList(
          shiny::h3("Job info"),
          renderTable(job_info$yourjob, striped = T, hover = T, spacing = "l",
                      bordered = T, rownames = F, colnames = F ),
          shiny::h3("Plot summary"),
          renderPlotly(ggplotly(draw_cross(job_info$yourtable))),
          shiny::br(),
          shiny::h3("Results"),
          DT::renderDataTable(job_info$yourtable,server = FALSE),
        )
      } else  if(job_info$yourmodule  == "SS_all"){
        tagList(
          shiny::h3("Job info"),
          renderTable(job_info$yourjob, striped = T, hover = T, spacing = "l",
                      bordered = T, rownames = F, colnames = F ),
          shiny::h3("Plot summary"),
          renderPlotly(ggplotly(draw_all(job_info$yourtable))),
          shiny::br(),
          shiny::h3("Results"),
          DT::renderDataTable(job_info$yourtable,server = FALSE),
        )
      }
      
    })
  })
})




# 结果读取
read_from_db <- function(Jobid_query){
  
  library(RSQLite)
  # library(stringr)
  # con_red_res <- dbConnect(RSQLite::SQLite(), "App-1//results/resinfo.db")
  con_red_res <- dbConnect(RSQLite::SQLite(), "results/resinfo.db")
  
  # AAAa =  tbl(con_red_res,"res") %>% as_tibble()
  retrieve_job <- tbl(con_red_res,"res") %>% 
    dplyr::filter(Jobid == Jobid_query) %>%  
    as.data.frame() 
  
  if(nrow(retrieve_job) != 1){
    dbDisconnect(con_red_res)
    return(NA)
  } else {
    res_module  <- retrieve_job$sub_module
    
    if(retrieve_job$table_num == 1){
      retrieve_table <- tbl(con_red_res,retrieve_job$Jobid ) %>%  
        as.data.frame() 
      
    }else if(retrieve_job$table_num == 2){
      
      retrieve_table <- list(
        "AUC" =  tbl(con_red_res, paste0(retrieve_job$Jobid,"_AUC")) %>% 
          as.data.frame() ,
        "ES" =  tbl(con_red_res, paste0(retrieve_job$Jobid,"_ES")) %>% 
          as.data.frame()
      )
      
    }
    
    retrieve_job <- retrieve_job %>% t() %>%   cbind(t(name_for_res_col)) %>% 
      na.omit() %>% as.data.frame %>% dplyr::select(c("V2","V1"))
    
    dbDisconnect(con_red_res)
    
    return(list("yourjob" = retrieve_job,
                "yourmodule" = res_module,
                "yourtable" = retrieve_table)
    )
  }
  
  
  
  
  
  
}


# 右侧说明页面
initial_jc <- tagList(
  h3("Welcome to Job Center module!"),
  p("In this module, you can retrieve results from previous modules.",
    "When you submit a job, you may notice the info window tell you a ",
    strong("Jobid"),".",
    br(),
    div(style = "text-align:center",
        img(src ="imgjc1.png",width = "300px")
    ),
    br(),
    "You can just input the ",strong("Jobid")," in the left pannel and get the results",
    br(),
    "It is useful when a job is implemented for a long time. Actually, 15 minutes is average running time for each job.",

    
    ),
)