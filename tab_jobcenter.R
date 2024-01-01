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





# 结果保存
write_in_db <- function(Jobid, Submitted_time, module_name,
                        sub_module, table_num = 1, table_res){
  # 表格里面的Jobid和Jobid不一样啊，别搞错了哦
  if(module_name == "Benchmark"){
    if(sub_module == "AUC"){
      df1 <- data.frame(
        # 通用参数
        Jobid = Jobid, # JOB ID
        Submitted_time = Submitted_time, # 提交时间
        main_module = module_name, # benchmark or application
        table_num = table_num, # 结果一共由几个表？使用于benchmark的两个表格都上传的情况
        
        # bencamark canshu
        drug_profile = input$sel_experiment, # benchmark的药物集
        method_bm = paste0(input$sel_ss,collapse = ", "), # 选择的方法？需要替换名字一下吧
        signature_file1 = input$file_sig$name, # benchmark上传的签名的名字
        # fda_file = input$file_FDA$name, # benchmark上传的FDA文件的名字
        ic50_file = input$file_IC50$name, # benchmark上传的IC50文件的名字
        sub_module = sub_module # 这里是特殊处理的哦
        
        # # application canshu
        # drug_profile = input$sel_experiment_sm, # signaturesearch的药物集
        # sub_module = input$sel_model_sm, # signaturesearch模块选择
        # method_sm1 = paste0(input$sel_all_sm,collapse = " "), # signaturesearch模块选择(SS_ALL)
        # direction_sm = input$sel_direct_sm, # signaturesearch 的模块SS_ALL的方向选择
        # method_sm2 = input$sel_ss_sm, # signaturesearch模块选择(SS_CROSS 以及 singmethod)
        # signature_file2 = input$file_sig_sm$name, # signaturesearch上传的签名的名字
        # signature_file3 = input$file_sig_sm1$name, # signaturesearch上传的SS_CROSS 签名的名字
        # signature_file4 = input$file_sig_sm2$name, # signaturesearch上传的SS_CROSS 签名的名字
        # signature_name1 = input$file_name1, # signaturesearch上传的SS_CROSS 签名的参数名字
        # signature_name2 = input$file_name2, # signaturesearch上传的SS_CROSS 签名的参数名字
        # sel_num_gene = input$sel_topn_sm # 设定读取的基因数量的名字
      )
    }
    if(sub_module == "ES"){
      df1 <- data.frame(
        # 通用参数
        Jobid = Jobid, # JOB ID
        Submitted_time = Submitted_time, # 提交时间
        main_module = module_name, # benchmark or application
        table_num = table_num, # 结果一共由几个表？使用于benchmark的两个表格都上传的情况
        
        # bencamark canshu
        drug_profile = input$sel_experiment, # benchmark的药物集
        method_bm = paste0(input$sel_ss,collapse = ", "), # 选择的方法？需要替换名字一下吧
        signature_file1 = input$file_sig$name, # benchmark上传的签名的名字
        fda_file = input$file_FDA$name, # benchmark上传的FDA文件的名字
        # ic50_file = input$file_IC50$name, # benchmark上传的IC50文件的名字
        sub_module = sub_module # 这里是特殊处理的哦
        
        # # application canshu
        # drug_profile = input$sel_experiment_sm, # signaturesearch的药物集
        # sub_module = input$sel_model_sm, # signaturesearch模块选择
        # method_sm1 = paste0(input$sel_all_sm,collapse = " "), # signaturesearch模块选择(SS_ALL)
        # direction_sm = input$sel_direct_sm, # signaturesearch 的模块SS_ALL的方向选择
        # method_sm2 = input$sel_ss_sm, # signaturesearch模块选择(SS_CROSS 以及 singmethod)
        # signature_file2 = input$file_sig_sm$name, # signaturesearch上传的签名的名字
        # signature_file3 = input$file_sig_sm1$name, # signaturesearch上传的SS_CROSS 签名的名字
        # signature_file4 = input$file_sig_sm2$name, # signaturesearch上传的SS_CROSS 签名的名字
        # signature_name1 = input$file_name1, # signaturesearch上传的SS_CROSS 签名的参数名字
        # signature_name2 = input$file_name2, # signaturesearch上传的SS_CROSS 签名的参数名字
        # sel_num_gene = input$sel_topn_sm # 设定读取的基因数量的名字
      )
    }
    if(sub_module == "ALL (ES and AUC)"){
      df1 <- data.frame(
        # 通用参数
        Jobid = Jobid, # JOB ID
        Submitted_time = Submitted_time, # 提交时间
        main_module = module_name, # benchmark or application
        table_num = table_num, # 结果一共由几个表？使用于benchmark的两个表格都上传的情况
        
        # bencamark canshu
        drug_profile = input$sel_experiment, # benchmark的药物集
        method_bm = paste0(input$sel_ss,collapse = ", "), # 选择的方法？需要替换名字一下吧
        signature_file1 = input$file_sig$name, # benchmark上传的签名的名字
        fda_file = input$file_FDA$name, # benchmark上传的FDA文件的名字
        ic50_file = input$file_IC50$name, # benchmark上传的IC50文件的名字
        sub_module = sub_module # 这里是特殊处理的哦
        
        # # application canshu
        # drug_profile = input$sel_experiment_sm, # signaturesearch的药物集
        # sub_module = input$sel_model_sm, # signaturesearch模块选择
        # method_sm1 = paste0(input$sel_all_sm,collapse = " "), # signaturesearch模块选择(SS_ALL)
        # direction_sm = input$sel_direct_sm, # signaturesearch 的模块SS_ALL的方向选择
        # method_sm2 = input$sel_ss_sm, # signaturesearch模块选择(SS_CROSS 以及 singmethod)
        # signature_file2 = input$file_sig_sm$name, # signaturesearch上传的签名的名字
        # signature_file3 = input$file_sig_sm1$name, # signaturesearch上传的SS_CROSS 签名的名字
        # signature_file4 = input$file_sig_sm2$name, # signaturesearch上传的SS_CROSS 签名的名字
        # signature_name1 = input$file_name1, # signaturesearch上传的SS_CROSS 签名的参数名字
        # signature_name2 = input$file_name2, # signaturesearch上传的SS_CROSS 签名的参数名字
        # sel_num_gene = input$sel_topn_sm # 设定读取的基因数量的名字
      )
    }
    
    
    
  }
  if(module_name == "Application"){
    if(sub_module == "singlemethod"){
      df1 <- data.frame(
        # 通用参数
        Jobid = Jobid, # JOB ID
        Submitted_time = Submitted_time, # 提交时间
        main_module = module_name, # benchmark or application
        table_num = table_num, # 结果一共由几个表？使用于benchmark的两个表格都上传的情况
        
        # bencamark canshu
        # drug_profile = input$sel_experiment, # benchmark的药物集
        # method_bm = paste0(input$sel_ss,collapse = " "), # 选择的方法？需要替换名字一下吧
        # signature_file1 = input$file_sig$name, # benchmark上传的签名的名字
        # fda_file = input$file_FDA$name, # benchmark上传的FDA文件的名字
        # ic50_file = input$file_IC50$name, # benchmark上传的IC50文件的名字
        
        # application canshu
        drug_profile = input$sel_experiment_sm, # signaturesearch的药物集
        sub_module = input$sel_model_sm, # signaturesearch模块选择
        # method_sm1 = paste0(input$sel_all_sm,collapse = " "), # signaturesearch模块选择(SS_ALL)
        # direction_sm = input$sel_direct_sm, # signaturesearch 的模块SS_ALL的方向选择
        method_sm2 = input$sel_ss_sm, # signaturesearch模块选择(SS_CROSS 以及 singmethod)
        signature_file2 = input$file_sig_sm$name, # signaturesearch上传的签名的名字
        # signature_file3 = input$file_sig_sm1$name, # signaturesearch上传的SS_CROSS 签名的名字
        # signature_file4 = input$file_sig_sm2$name, # signaturesearch上传的SS_CROSS 签名的名字
        # signature_name1 = input$file_name1, # signaturesearch上传的SS_CROSS 签名的参数名字
        # signature_name2 = input$file_name2, # signaturesearch上传的SS_CROSS 签名的参数名字
        sel_num_gene = input$sel_topn_sm # 设定读取的基因数量的名字
      )
    }
    if(sub_module == "SS_cross"){
      df1 <- data.frame(
        # 通用参数
        Jobid = Jobid, # JOB ID
        Submitted_time = Submitted_time, # 提交时间
        main_module = module_name, # benchmark or application
        table_num = table_num, # 结果一共由几个表？使用于benchmark的两个表格都上传的情况
        
        # bencamark canshu
        # drug_profile = input$sel_experiment, # benchmark的药物集
        # method_bm = paste0(input$sel_ss,collapse = " "), # 选择的方法？需要替换名字一下吧
        # signature_file1 = input$file_sig$name, # benchmark上传的签名的名字
        # fda_file = input$file_FDA$name, # benchmark上传的FDA文件的名字
        # ic50_file = input$file_IC50$name, # benchmark上传的IC50文件的名字
        
        # application canshu
        drug_profile = input$sel_experiment_sm, # signaturesearch的药物集
        sub_module = input$sel_model_sm, # signaturesearch模块选择
        # method_sm1 = paste0(input$sel_all_sm,collapse = " "), # signaturesearch模块选择(SS_ALL)
        # direction_sm = input$sel_direct_sm, # signaturesearch 的模块SS_ALL的方向选择
        method_sm2 = input$sel_ss_sm, # signaturesearch模块选择(SS_CROSS 以及 singmethod)
        # signature_file2 = input$file_sig_sm$name, # signaturesearch上传的签名的名字
        signature_file3 = input$file_sig_sm1$name, # signaturesearch上传的SS_CROSS 签名的名字
        signature_file4 = input$file_sig_sm2$name, # signaturesearch上传的SS_CROSS 签名的名字
        signature_name1 = input$file_name1, # signaturesearch上传的SS_CROSS 签名的参数名字
        signature_name2 = input$file_name2, # signaturesearch上传的SS_CROSS 签名的参数名字
        sel_num_gene = input$sel_topn_sm # 设定读取的基因数量的名字
      )
    }
    if(sub_module == "SS_all"){
      df1 <- data.frame(
        # 通用参数
        Jobid = Jobid, # JOB ID
        Submitted_time = Submitted_time, # 提交时间
        main_module = module_name, # benchmark or application
        table_num = table_num, # 结果一共由几个表？使用于benchmark的两个表格都上传的情况
        
        # bencamark canshu
        # drug_profile = input$sel_experiment, # benchmark的药物集
        # method_bm = paste0(input$sel_ss,collapse = " "), # 选择的方法？需要替换名字一下吧
        # signature_file1 = input$file_sig$name, # benchmark上传的签名的名字
        # fda_file = input$file_FDA$name, # benchmark上传的FDA文件的名字
        # ic50_file = input$file_IC50$name, # benchmark上传的IC50文件的名字
        
        # application canshu
        drug_profile = input$sel_experiment_sm, # signaturesearch的药物集
        sub_module = input$sel_model_sm, # signaturesearch模块选择
        method_sm1 = paste0(input$sel_all_sm,collapse = ", "), # signaturesearch模块选择(SS_ALL)
        direction_sm = input$sel_direct_sm, # signaturesearch 的模块SS_ALL的方向选择
        # method_sm2 = input$sel_ss_sm, # signaturesearch模块选择(SS_CROSS 以及 singmethod)
        signature_file2 = input$file_sig_sm$name, # signaturesearch上传的签名的名字
        # signature_file3 = input$file_sig_sm1$name, # signaturesearch上传的SS_CROSS 签名的名字
        # signature_file4 = input$file_sig_sm2$name, # signaturesearch上传的SS_CROSS 签名的名字
        # signature_name1 = input$file_name1, # signaturesearch上传的SS_CROSS 签名的参数名字
        # signature_name2 = input$file_name2, # signaturesearch上传的SS_CROSS 签名的参数名字
        sel_num_gene = input$sel_topn_sm # 设定读取的基因数量的名字
      )
    }
    
  }
  
  library(RSQLite)
  con_res <- dbConnect(RSQLite::SQLite(), "results/resinfo.db")
  # print(df1)
  
  if(table_num == 1){
    # print("写入一个表1")
    # print(Jobid)
    # print(table_res)
    # save(table_res,file = "X1.rdata")
    dbWriteTable(con_res, Jobid, table_res)
    # print("增加一个表1")
    dbAppendTable(con_res, "res", df1)
    # print("Sucess!")
  } else if(table_num == 2) {
    # print("写入一个表2")
    dbWriteTable(con_res, paste0(Jobid,"_AUC"), table_res[["AUC"]])
    # print("写入一个表2")
    dbWriteTable(con_res, paste0(Jobid,"_ES"), table_res[["ES"]])
    # print("增加一个表2")
    dbAppendTable(con_res, "res", df1)
    print("wrting to dababase Sucess!")
  } else {
    print("WARING! NO TABLE INPUT!")
  }
  
  dbDisconnect(con_res)
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