###############################################.
## sigle method - common objects ----
###############################################.

# 读取数据库


library(ggplot2)
library(ggrepel)
library(future)
library(promises)
library(memoise)


### 交互相应区域

# 初始化
output$display_sm <- renderUI({initial_sm})

# 重置
observeEvent(input$reset_sm, {
  
  # runjs("history.go(0)")
  reset("sm_input")
  
})



# 运行层
observeEvent(input$runSM, {
  
  # 正式的运行层
  
  
  isolate({
    
    req(judge_sm())
    # 报警子层，函数在下面
    if(judge_sm()){
      jobid_sm <- paste0("APP",as.integer(Sys.time()),paste0(sample(LETTERS,3),collapse = ""))
      submitted_time =  as.character(Sys.time()) 
      shinyWidgets::sendSweetAlert(
        session = session,
        title = "Success !!",
        text = paste0("Your jobid is ",
                      jobid_sm,
                      ". Please remember it for retrive results in Job Center") ,
        type = "success"
      )
    }else{
      output$display_sm <- renderUI({initial_sm})
    }
    
    drug_profile = input$sel_experiment_sm
    topn = input$sel_topn_sm
    sel_model_sm1 = input$sel_model_sm
    funcname = input$sel_ss_sm
    sub_module = input$sel_model_sm
    funcname_mul = input$sel_all_sm
    direct = input$sel_direct_sm
    bioname1 = input$file_name1
    bioname2 = input$file_name2
    
    
    if(sel_model_sm1 == "singlemethod"){
      req(input$file_sig_sm$datapath)
      req(input$sel_ss_sm)
      
      i.need.logfc <- rio::import(input$file_sig_sm$datapath) %>% dplyr::select(c("Gene","log2FC"))
      
      
    }
    if(sel_model_sm1 == "SS_all"){
      req(input$file_sig_sm$datapath)
      req(length(input$sel_all_sm) > 1 )
      
      i.need.logfc <- rio::import(input$file_sig_sm$datapath) %>% dplyr::select(c("Gene","log2FC"))
    }
    if(sel_model_sm1 == "SS_cross"){
      req(input$file_sig_sm1$datapath)
      req(input$file_sig_sm2$datapath)
      req(input$file_name1 != "")
      req(input$file_name1 != "")
      
      i.need.logfc1 <- rio::import(input$file_sig_sm1$datapath) %>% dplyr::select(c("Gene","log2FC"))
      i.need.logfc2 <- rio::import(input$file_sig_sm2$datapath) %>% dplyr::select(c("Gene","log2FC"))
      
      i.need.logfc <- list(
        "i.need.logfc1" = i.need.logfc1,
        "i.need.logfc2" = i.need.logfc2
      )
      
    }
    
    
    # 运行层
    future_promise({    ## 这里可能需要单独加载包哦
      
      library(dplyr) # 为了future正常运行使用的
      library(tidyr)
      library(tidyverse)
      
      
      
      isolate({
        
        res_sm_f <-  get_single_method(drug_profile = drug_profile,
                                       topn = topn,
                                       sel_model_sm1= sel_model_sm1,
                                       i.need.logfc = i.need.logfc,
                                       funcname = funcname,
                                       funcname_mul = funcname_mul,
                                       direct = direct,
                                       bioname1 = bioname1,
                                       bioname2 = bioname2)
        return(res_sm_f)
        
      })
    }, seed = TRUE) %...>% (
      function(result){
        res_sm <- result[[1]]
        p_sm <- result[[2]]
        write_in_db(Jobid = jobid_sm, 
                    Submitted_time = submitted_time, 
                    module_name = "Application",
                    sub_module = input$sel_model_sm,
                    table_num = 1, 
                    table_res = res_sm)
        output$display_sm <- renderUI({ # renderUI 
          tagList(
            shiny::h3("Plot summary"),
            renderPlotly(ggplotly(p_sm)),
            shiny::br(),
            shiny::h3("Results"),
            DT::renderDataTable(res_sm,server = FALSE),
          )
        }) # renderUI
        # print("job finished!")
      }
    ) %...!% (function(error){
      # rv$output <- NULL
      warning(error)
    })
    
    output$display_sm <- renderUI({ 
      shiny::tagList(
        shiny::h3("Loading... Please wait."),
        shiny::h3("It may take 15~30 mins to get result"),
        shiny::h3(paste0("Your jobid is ",jobid_sm)),
        shiny::h3("Please remember it for retrive results in Job Center.")
      )
      
    }) # renderUI
    
  })
  
  
  
  
  
  
  
})



# 判断函数
judge_sm <- function(){
  # library(shinyWidgets)
  if(input$sel_model_sm == "singlemethod" | input$sel_model_sm == "SS_all"){
    
    if(is.null(input$file_sig_sm$datapath)){
      sendSweetAlert(
        session = session,
        title = "Error...",
        text = "Please Check the uploaded file",
        type = "error"
      )
      return(F)
    }
    
    # 读取文件以后判定
    if(!is.null(input$file_sig_sm$datapath)){
      sig2 <- rio::import(input$file_sig_sm$datapath)
      if(!all(c("Gene","log2FC" ) %in% colnames(sig2))){
        sendSweetAlert(
          session = session,
          title = "Error...",
          text = 'Please make sure your signature table contains column "Gene" and "log2FC" !',
          type = "error"
        )
        return(F)
      }
    }
    
    
    
  } 
  
  if(input$sel_model_sm == "SS_cross"){
    if(is.null(input$file_sig_sm1$datapath) | is.null(input$file_sig_sm2$datapath)){
      sendSweetAlert(
        session = session,
        title = "Error...",
        text = "Please Check the uploaded files",
        type = "error"
      )
      return(F)
    } 
    if(input$file_name1 == "" | input$file_name2 ==""){
      sendSweetAlert(
        session = session,
        title = "Error...",
        text = "Please Check biological names",
        type = "error"
      )
      return(F)
    }
    
    # 读取文件以后判定
    if(!(is.null(input$file_sig_sm1$datapath) | is.null(input$file_sig_sm2$datapath))){
      sig21 <- rio::import(input$file_sig_sm2$datapath)
      sig22 <- rio::import(input$file_sig_sm2$datapath)
      if(!(all(c("Gene","log2FC" ) %in% colnames(sig21)) & all(c("Gene","log2FC" ) %in% colnames(sig21)))){
        sendSweetAlert(
          session = session,
          title = "Error...",
          text = 'Please make sure your signature table contains column "Gene" and "log2FC" !',
          type = "error"
        )
        return(F)
      }
    }
    
    
    
  } 
  
  if(input$sel_model_sm == "SS_all"){
    if(length(input$sel_all_sm) < 2 ){
      sendSweetAlert(
        session = session,
        title = "Error...",
        text = "Please select at least two methods",
        type = "error"
      )
      return(F)
    }
    # 读取文件以后判定
    if(!is.null(input$file_sig_sm$datapath)){
      sig2 <- rio::import(input$file_sig_sm$datapath)
      if(!all(c("Gene","log2FC" ) %in% colnames(sig2))){
        sendSweetAlert(
          session = session,
          title = "Error...",
          text = 'Please make sure your signature table contains column "Gene" and "log2FC" !',
          type = "error"
        )
        return(F)
      }
    }
    
    
  }
  return(T)
}



# 初始化
initial_sm <- tagList(
  includeMarkdown("www/tab_application.md")
)
