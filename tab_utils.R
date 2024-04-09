# benchmark和application的结果保存
# 这个页面提供的是需要在不同页面使用的，超过2次以上的功能
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
        method_bm = paste0(find_original_names(input$sel_ss),collapse = ", "), # 选择的方法？需要替换名字一下吧
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
        method_bm = paste0(find_original_names(input$sel_ss),collapse = ", "), # 选择的方法？需要替换名字一下吧
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
        method_bm = paste0(find_original_names(input$sel_ss),collapse = ", "), # 选择的方法？需要替换名字一下吧
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
        method_sm2 = find_original_names(input$sel_ss_sm), # signaturesearch模块选择(SS_CROSS 以及 singmethod)
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
        method_sm2 = find_original_names(input$sel_ss_sm), # signaturesearch模块选择(SS_CROSS 以及 singmethod)
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
        method_sm1 = paste0(find_original_names(input$sel_all_sm),collapse = ", "), # signaturesearch模块选择(SS_ALL)
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
    # save(table_res,Jobid,file = "X1.rdata")
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
    # print("wrting to dababase Sucess!")
  } else {
    # print("WARING! NO TABLE INPUT!")
  }
  
  dbDisconnect(con_res)
}

observeEvent(input$intro_res_bm_AUC, {
  
  showModal(modalDialog(
    includeMarkdown("www/info_Q9_bm_AUC.md"),
    title = "How to find optimal method and topN in Benchmark? (AUC)",
    size = "l",
    easyClose = T
  ))
  
})

observeEvent(input$intro_res_bm_ES, {
  
  showModal(modalDialog(
    includeMarkdown("www/info_Q9_bm_ES.md"),
    title = "How to find optimal method and topN in Benchmark? (ES)",
    size = "l",
    easyClose = T
  ))
  
})

observeEvent(input$intro_res_rb, {
  
  showModal(modalDialog(
    includeMarkdown("www/info_Q9_rb.md"),
    title = "Quick Tip",
    size = "l",
    easyClose = T
  ))
  
})


observeEvent(input$intro_res_sm_sm, {

  showModal(modalDialog(
    includeMarkdown("www/info_Q9_sm_sm.md"),
    title = "Quick Tip",
    size = "l",
    easyClose = T
  ))
})

observeEvent(input$intro_res_sm_cross, {
  
  showModal(modalDialog(
    includeMarkdown("www/info_Q9_sm_cross.md"),
    title = "Quick Tip",
    size = "l",
    easyClose = T
  ))
})

observeEvent(input$intro_res_sm_all, {
  
  showModal(modalDialog(
    includeMarkdown("www/info_Q9_sm_all.md"),
    title = "Quick Tip",
    size = "l",
    easyClose = T
  ))
})

# FOR EACH PAGE
observeEvent(input$runBENdemo,{
  load("demo/BEN1712624574ZFX.rdata")
  output$display_bm <- renderUI({res_plot(job_info)})
})
observeEvent(input$runAPPdemo1,{
  load("demo/APP1709824554ILK.rdata")
  output$display_sm <- renderUI({res_plot(job_info)})
})
observeEvent(input$runAPPdemo2,{
  load("demo/APP1709818711RFU.rdata")
  output$display_sm <- renderUI({res_plot(job_info)})
})
observeEvent(input$runAPPdemo3,{
  load("demo/APP1709818670ZIA.rdata")
  output$display_sm <- renderUI({res_plot(job_info)})
})
# FOR JOB PAGE
observeEvent(input$runjcBENdemo,{
  load("demo/BEN1712624574ZFX.rdata")
  output$display_jc <- renderUI({res_plot(job_info)})
})
observeEvent(input$runjcAPPdemo1,{
  load("demo/APP1709824554ILK.rdata")
  output$display_jc <- renderUI({res_plot(job_info)})
})
observeEvent(input$runjcAPPdemo2,{
  load("demo/APP1709818711RFU.rdata")
  output$display_jc <- renderUI({res_plot(job_info)})
})
observeEvent(input$runjcAPPdemo3,{
  load("demo/APP1709818670ZIA.rdata")
  output$display_jc <- renderUI({res_plot(job_info)})
})



res_plot <- function(job_info){
  if(job_info$yourmodule == "ALL (ES and AUC)"){
    
    
    # print("开始！")
    
    res_bm1 <- job_info$yourtable$`AUC` %>% as_tibble()
    res_bm2 <- job_info$yourtable$`ES` %>% as_tibble()
    
    # print("获取结果！")
    
    # save(res_bm1,res_bm2,file = "111.rdata")
    
    pic_out1 <- ggplotly(draw_dr_auc(res_bm1))
    pic_out2 <- ggplotly(draw_dr_es(res_bm2))
    
    DT_res_bm1 <- datatable(res_bm1) %>% 
      formatStyle(names(res_bm1)[which.max(res_bm1[1,-1]) + 1],
                  backgroundColor = styleEqual(res_bm1[1, which.max(res_bm1[1,-1]) + 1], c('yellow')))
    DT_res_bm2 <- datatable(res_bm2) %>% 
      formatStyle(names(res_bm2)[which.min(res_bm2[1,-1])+1],
                  backgroundColor = styleEqual(res_bm2[1, which.min(res_bm2[1,-1]) + 1], c('yellow')))
    
    tagList(
      shiny::h3("Job info"),
      renderTable(job_info$yourjob, striped = T, hover = T, spacing = "l",
                  bordered = T, rownames = F, colnames = F ),
      shiny::h3("Results of AUC",actionButton("intro_res_bm_AUC","Quick Tip",class = "btn-success")),
      renderPlotly(pic_out1),
      DT::renderDataTable(DT_res_bm1),
      shiny::br(),
      shiny::h3("Results of ES",actionButton("intro_res_bm_ES","Quick Tip",class = "btn-success")),
      renderPlotly(pic_out2),
      DT::renderDataTable(DT_res_bm2),
    )
    
  } else  if(job_info$yourmodule == "AUC" ){
    
    res_bm = job_info$yourtable  %>% as_tibble()
    res_title = job_info$yourmodule
    
    # print(res_bm[[1]])
    pic_out = ggplotly(draw_dr_auc(res_bm)) 
    
    DT_res_bm <- datatable(res_bm) %>% 
      formatStyle(names(res_bm)[which.max(res_bm[1,-1]) + 1],
                  backgroundColor = styleEqual(res_bm[1, which.max(res_bm[1,-1])+ 1], c('yellow')))
    
    
    tagList(
      shiny::h3("Job info"),
      renderTable(job_info$yourjob, striped = T, hover = T, spacing = "l",
                  bordered = T, rownames = F, colnames = F ),
      shiny::h3(paste0("Plot summary of ",res_title),
                actionButton(paste0("intro_res_bm_",res_title),"Quick Tip",class = "btn-success")
      ),
      renderPlotly(pic_out),
      shiny::br(),
      shiny::h3(paste0("Results of "),res_title),
      DT::renderDataTable(DT_res_bm)
    )
  } else if(job_info$yourmodule == "ES" ){
    
    
    res_bm = job_info$yourtable  %>% as_tibble()
    res_title = job_info$yourmodule
    
    pic_out = ggplotly(draw_dr_es(res_bm))
    DT_res_bm <- datatable(res_bm) %>% 
      formatStyle(names(res_bm)[which.min(res_bm[1,-1]) + 1],
                  backgroundColor = styleEqual(res_bm[1, which.min(res_bm[1,-1])+ 1], c('yellow')))
    
    tagList(
      shiny::h3("Job info"),
      renderTable(job_info$yourjob, striped = T, hover = T, spacing = "l",
                  bordered = T, rownames = F, colnames = F ),
      shiny::h3(paste0("Plot summary of ",res_title),
                actionButton(paste0("intro_res_bm_",res_title),"Quick Tip",class = "btn-success")
      ),
      renderPlotly(pic_out),
      shiny::br(),
      shiny::h3(paste0("Results of "),res_title),
      DT::renderDataTable(DT_res_bm)
    )
    
  } else  if(job_info$yourmodule == "singlemethod" ){
    
    tagList(
      shiny::h3("Job info"),
      renderTable(job_info$yourjob, striped = T, hover = T, spacing = "l",
                  bordered = T, rownames = F, colnames = F ),
      shiny::h3("Plot summary",actionButton("intro_res_sm_sm","Quick Tip",class = "btn-success")),
      renderPlotly(ggplotly(draw_single(job_info$yourtable))),
      shiny::h3("Results"),
      DT::renderDataTable(job_info$yourtable %>%
                            dplyr::rename(any_of(rename_col_rules)),
                          server = FALSE),
    )
    
  } else  if(job_info$yourmodule  == "SS_cross"){
    tagList(
      shiny::h3("Job info"),
      renderTable(job_info$yourjob, striped = T, hover = T, spacing = "l",
                  bordered = T, rownames = F, colnames = F ),
      shiny::h3("Plot summary",actionButton("intro_res_sm_cross","Quick Tip",class = "btn-success")),
      renderPlotly(ggplotly(draw_cross(job_info$yourtable, 
                                       bioname1=job_info$signame1,bioname2=job_info$signame2))),
      shiny::br(),
      shiny::h3("Results"),
      DT::renderDataTable(job_info$yourtable %>%
                            dplyr::rename(any_of(rename_col_rules)),
                          server = FALSE),
    )
  } else  if(job_info$yourmodule  == "SS_all"){
    tagList(
      shiny::h3("Job info"),
      renderTable(job_info$yourjob, striped = T, hover = T, spacing = "l",
                  bordered = T, rownames = F, colnames = F ),
      shiny::h3("Plot summary",actionButton("intro_res_sm_all","Quick Tip",class = "btn-success")),
      renderPlotly(ggplotly(draw_all(job_info$yourtable))),
      shiny::br(),
      shiny::h3("Results"),
      DT::renderDataTable(job_info$yourtable %>%
                            dplyr::rename(any_of(rename_col_rules)),
                          server = FALSE),
    )
  }
}