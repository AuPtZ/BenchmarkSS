## 初始化一个存储结果列表的数据库

# demo写入
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

load(file = "APP1665125453MTV.rdata")

Jobid = "demo1"

df1 <- data.frame(
  # 通用参数
  Jobid = "demo1", # JOB ID
  Submitted_time = "2022-10-07 22:39:51",# as.character(format(Sys.time(),'%Y %m %d %X')), # 提交时间
  main_module = "Application", # benchmark or application
  table_num = 1, # 结果一共由几个表？使用于benchmark的两个表格都上传的情况
  
  # bencamark canshu
  # drug_profile = as.character(NA) , # benchmark的药物集
  method_bm = as.character(NA), # 选择的方法？需要替换名字一下吧
  signature_file1 = as.character(NA), # benchmark上传的签名的名字
  fda_file = as.character(NA), # benchmark上传的FDA文件的名字
  ic50_file = as.character(NA), # benchmark上传的IC50文件的名字
  
  # application canshu
  drug_profile = "LINCS_A549_1 nM_6 h.rdata", # signaturesearch的药物集
  sub_module = "singlemethod", # signaturesearch模块选择
  method_sm1 = as.character(NA), # signaturesearch模块选择(SS_ALL)
  direction_sm = as.character(NA), # signaturesearch 的模块SS_ALL的方向选择
  method_sm2 = "SS_Xsum", # signaturesearch模块选择(SS_CROSS 以及 singmethod)
  signature_file2 = "signature.txt", # signaturesearch上传的签名的名字
  signature_file3 = as.character(NA), # signaturesearch上传的SS_CROSS 签名的名字
  signature_file4 = as.character(NA), # signaturesearch上传的SS_CROSS 签名的名字
  signature_name1 = as.character(NA), # signaturesearch上传的SS_CROSS 签名的参数名字
  signature_name2 = as.character(NA), # signaturesearch上传的SS_CROSS 签名的参数名字
  sel_num_gene = 150 # 设定读取的基因数量的名字
)


library(RSQLite)
library(dplyr)
library(tibble)
con <- dbConnect(RSQLite::SQLite(), "results/resinfo.db")

# List all the tables available in the database
dbListTables(con)


dbCreateTable(con, "res", df1)
dbAppendTable(con, "res", df1) # 仅仅是为了记住命令行而已
dbWriteTable(con, Jobid, res_sm)

dbDisconnect(con)



## 不用了
if(F){
  library(dplyr)
  library(tidyverse)
  library(tidyselect)
  dplyr::across(table_res,all_of(colnames(table_res)), unlist)
  # table_res %>% transmute( across(all_of(colnames(.)),unlist )) %>% as_tibble()
  table_res %>% transmute( across(where(is.list),unlist )) %>% as_tibble()
  # dbAppendTable(con, Jobid, res_sm)
  # dbAppendTable(con, "iris", iris[,1:3])
  # dbReadTable(con, "iris")
  
  ## 获取数据库的表格名字
  dbListTables(con)
  
  dbReadTable(con, "res")
  dbReadTable(con, Jobid)
  
  
  
  
  
  # df111 =  data.frame(
  #   a = "a",
  #   b = "b"
  # )
  
  # dbWriteTable(conn, i, as_tibble(t(nulldistribution)))
  
  # 
  # for (i in list.files("App-1/data_preload/nulldistribution")){
  #   if (str_detect(i,"rdata")){
  #     load(paste0("App-1/data_preload/nulldistribution/",i))
  #     colnames(nulldistribution) <- 1:ncol(nulldistribution)
  #     dbWriteTable(conn, i, as_tibble(t(nulldistribution))  )
  #   }
  # }
  
  ## table的demo展示素材
  # if (interactive()) {
  #   # table example
  #   shinyApp(
  #     ui = fluidPage(
  #       fluidRow(
  #         column(12,
  #                tableOutput('table')
  #         )
  #       )
  #     ),
  #     server = function(input, output) {
  #       output$table <- renderTable(iris[,c(1,2)],
  #                                   striped = T,
  #                                   hover = T,
  #                                   spacing = "l",
  #                                   bordered = T,
  #                                   rownames = T,
  #                                   colnames = F,)
  #     }
  #   )
  # }
  
  
  
  
  
  
  
  
  
  
  ## 写入函数
  
  
  
  
  ## 原始总表
  
  if(F){
    df1 <- data.frame(
      # 通用参数
      Jobid = jobid_bm, # JOB ID
      Submitted_time = Sys.time(), # 提交时间
      main_module = "Benchmark", # benchmark or application
      table_num = 2, # 结果一共由几个表？使用于benchmark的两个表格都上传的情况
      
      # bencamark canshu
      drug_profile = input$sel_experiment, # benchmark的药物集
      method_bm = paste0(input$sel_ss,collapse = " "), # 选择的方法？需要替换名字一下吧
      signature_file1 = input$file_sig$name, # benchmark上传的签名的名字
      fda_file = input$file_sig$name, # benchmark上传的FDA文件的名字
      ic50_file = input$file_IC50$name, # benchmark上传的IC50文件的名字
      
      # application canshu
      drug_profile = input$sel_experiment_sm, # signaturesearch的药物集
      sub_module = input$sel_model_sm, # signaturesearch模块选择
      method_sm1 = paste0(input$sel_all_sm,collapse = " "), # signaturesearch模块选择(SS_ALL)
      direction_sm = input$sel_direct_sm, # signaturesearch 的模块SS_ALL的方向选择
      method_sm2 = input$sel_ss_sm, # signaturesearch模块选择(SS_CROSS 以及 singmethod)
      signature_file2 = input$file_sig_sm$name, # signaturesearch上传的签名的名字
      signature_file3 = input$file_sig_sm1$name, # signaturesearch上传的SS_CROSS 签名的名字
      signature_file4 = input$file_sig_sm2$name, # signaturesearch上传的SS_CROSS 签名的名字
      signature_name1 = input$file_name1, # signaturesearch上传的SS_CROSS 签名的参数名字
      signature_name2 = input$file_name2, # signaturesearch上传的SS_CROSS 签名的参数名字
      sel_num_gene = input$sel_topn_sm # 设定读取的基因数量的名字
    )
  }
}

