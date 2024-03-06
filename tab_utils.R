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


observeEvent(input$intro_res_sm, {

  if (input$sel_model_sm == "singlemethod"){
    showModal(modalDialog(
      includeMarkdown("www/info_Q9_sm_sm.md"),
      title = "Quick Tip",
      size = "l",
      easyClose = T
    ))
  }
  if (input$sel_model_sm == "SS_cross"){
    showModal(modalDialog(
      includeMarkdown("www/info_Q9_sm_cross.md"),
      title = "Quick Tip",
      size = "l",
      easyClose = T
    ))
  }
  if (input$sel_model_sm == "SS_all"){
    showModal(modalDialog(
      includeMarkdown("www/info_Q9_sm_all.md"),
      title = "Quick Tip",
      size = "l",
      easyClose = T
    ))
  }
  
  
  
  
})