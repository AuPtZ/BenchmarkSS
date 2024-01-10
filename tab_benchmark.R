###############################################.
## Bechmark - common objects ----
###############################################.

#####################.
# Generate data
# read gctx
# library(cmapR)
library(future)
library(promises)
# plan(multisession)

library(memoise)

# cores <- get_cores()
# dir = "~/dataportal/LINCS/GSE92742_Broad_LINCS_Level5_COMPZ.MODZ_n473647x12328.gctx"

# 读取sig数据，用于提取数据


### 交互相应区域

# 初始化
output$display_bm <- renderUI(initial_bm)


# 重置
observeEvent(input$reset, {
  reset("bm_input")
  
  # system(paste0("rm ",input$file_sig$datapath))
  # system(paste0("rm ",input$file_IC50$datapath))
  # system(paste0("rm ",input$file_FDA$datapath))
  # 
  # print(input$file_sig)
  output$display_bm <- renderUI(initial_bm)
  
  
})



# 运行层
observeEvent(input$runBM, {
  
  
  
  
  isolate({ # isolate
    
    req(judge_bm()) 
    
    # 报警子层，函数在下面
    if(judge_bm()){
      jobid_bm <- paste0("BEN",as.integer(Sys.time()),paste0(sample(LETTERS,3),collapse = ""))
      submitted_time =  as.character(Sys.time()) 
      shinyWidgets::sendSweetAlert(
        session = session,
        title = "Success !!",
        text = paste0("Your jobid is ",
                      jobid_bm,
                      ".\n Process may take 15~30mins. \n Please remember it for retrive results in Job Center.") ,
        type = "success"
      )
    }else{
      output$display_bm <- renderUI(initial_bm)
    }
    
    #### Create a Progress object
    progress_bm <- shiny::Progress$new()
    
    # Make sure it closes when we exit this reactive, even if there's an error
    # on.exit(progress$close())
    
    progress_bm$set(message = paste0("Performing ", jobid_bm), value = 0)
    #### 
    
    
    req(length(input$sel_ss)>1)
    req(!(is.null(input$file_IC50) & is.null(input$file_FDA)))
    req(!is.null(input$file_sig))
    
    IC50_drug = input$file_IC50$datapath
    FDA_drug = input$file_FDA$datapath
    i.need.logfc = input$file_sig$datapath
    
    # 使用一个trick读取IC50,FDA和logfc，如果没有的话，那就认为为NULL，如果有的话，那就读取
    if(!is.null(IC50_drug)){
      IC50_drug <- rio::import(input$file_IC50$datapath)
    }
    if(!is.null(FDA_drug)){
      FDA_drug <- rio::import(input$file_FDA$datapath)
    }
    if(!is.null(i.need.logfc)){
      i.need.logfc <- rio::import(input$file_sig$datapath) %>% dplyr::select(c("Gene","log2FC"))
    }
    
    
    sel_exp = input$sel_experiment
    sel_ss = input$sel_ss
    
    ###
    progress_bm$inc(0.2, detail = paste("file loaded, computing"))
    ###
    
    # 正式的运行层
    future_promise({ ## future 需要单独加载包，global的不行
      library(dplyr)
      library(tidyr)
      library(ggplot2)
      library(tibble)
      library(pROC)
      library(rio)
      library(tidyverse)
      
      
      isolate({
        
        # print("we are going to res_bm!")
        res_bm <- get_benchmark(
          IC50_drug = IC50_drug,
          FDA_drug = FDA_drug, 
          i.need.logfc = i.need.logfc, 
          sel_exp = sel_exp,
          sel_ss = sel_ss
        )
        
        return(res_bm)
      })
    }, seed = TRUE) %...>% (
      function(res_bm){
        # print("we get result!")
        # res_bm <- result
        
        ###
        progress_bm$inc(0.6, detail = paste("get result, ploting"))
        ###
        
        if(length(res_bm) ==3){
          
          # print(res_bm)
          write_in_db(Jobid = jobid_bm, 
                      Submitted_time = submitted_time, 
                      module_name = "Benchmark",
                      sub_module = "ALL (ES and AUC)",
                      table_num = 2, 
                      table_res = list(
                        "AUC" = res_bm[[1]],
                        "ES" = res_bm[[2]]
                      ) )
          output$display_bm <- renderUI({ ## renderUI 
            tagList(
              shiny::h3("Results of AUC"),
              renderPlotly(ggplotly(draw_dr_auc(res_bm[[1]]))),
              DT::renderDataTable(res_bm[[1]] , 
                                  server = FALSE),
              shiny::br(),
              shiny::h3("Results of ES"),
              renderPlotly(ggplotly(draw_dr_es(res_bm[[2]]))),
              DT::renderDataTable(res_bm[[2]] ,
                                  server = FALSE)
            )
          }) ## renderUI
        } else if (length(res_bm) ==2){
          
          write_in_db(Jobid = jobid_bm, 
                      Submitted_time = submitted_time, 
                      module_name = "Benchmark",
                      sub_module = res_bm[[2]],
                      table_num = 1, 
                      table_res = res_bm[[1]])
          
          
          if(res_bm[[2]] == "AUC"){
            # print(res_bm[[1]])
            pic_out = draw_dr_auc(res_bm[[1]])
          }
          if(res_bm[[2]] == "ES"){
            # print(res_bm[[1]])
            pic_out = draw_dr_es(res_bm[[1]])
          }
          
          output$display_bm <- renderUI({ ## renderUI
            tagList(
              shiny::h3(paste0("Plot summary of"),res_bm[[2]]),
              renderPlotly(ggplotly(pic_out)),
              shiny::br(),
              shiny::h3(paste0("Results of "),res_bm[[2]]),
              DT::renderDataTable(res_bm[[1]],server = FALSE)
            )
          }) ## renderUI
        } else{
          output$display_bm <- renderUI({ ## renderUI 
            shiny::h3("Please Check Iput Files!")
          }) ## renderUI
        }
        
        ###
        progress_bm$inc(0.2, detail = paste("job finished!"))
        ###  
      }
    ) %...!% stop(.)
    output$display_bm <- renderUI({ ## renderUI 
      shiny::tagList(
        shiny::h3("Loading... Please wait."),
        shiny::h3("It may take 15~30 mins to get result."),
        shiny::h3(paste0("Your jobid is ",jobid_bm)),
        shiny::h3("Please remember it for retrive results in Job Center.")
      )
    }) ## renderUI

  }) # isolate
  
  
  
})

## 判断
judge_bm <- function(){
  
  if(is.null(input$file_sig)){
    sendSweetAlert(
      session = session,
      title = "Error...",
      text = "Please upload signature!",
      type = "error"
    )
    return(F)
  }
  
  if(is.null(input$file_IC50) & is.null(input$file_FDA)){
    sendSweetAlert(
      session = session,
      title = "Error...",
      text = "Please upload at least 1 annotation file!",
      type = "error"
    )
    return(F)
  }
  
  if(length(input$sel_ss)<2){
    sendSweetAlert(
      session = session,
      title = "Error...",
      text = "Please select at least 2 methods",
      type = "error"
    )
    return(F)
  }
  
  # 对于有上传文件的情况进行判断
  
  
  if(!is.null(input$file_sig)){
    sig1 <-  rio::import(input$file_sig$datapath)
    if(!all(c("Gene","log2FC" ) %in% colnames(sig1))){
      sendSweetAlert(
        session = session,
        title = "Error...",
        text = 'Please make sure your signature table contains column "Gene" and "log2FC" !',
        type = "error"
      )
      return(F)
    }
  }
  
  # 读取文件以后判定
  if(!is.null(input$file_FDA)){
    fda1 <-  rio::import(input$file_FDA$datapath)
    if(!all(c("Compound.name" ) %in% colnames(fda1))){
      sendSweetAlert(
        session = session,
        title = "Error...",
        text = 'Please make sure your FDA table contains column "Compound.name" !',
        type = "error"
      )
      return(F)
    }
  }
  
  if(!is.null(input$file_IC50)){
    ic501 <-  rio::import(input$file_IC50$datapath)
    if(!all(c("Compound.name","Group" ) %in% colnames(ic501))){
      sendSweetAlert(
        session = session,
        title = "Error...",
        text = 'Please make sure your IC50 table contains column "Compound.name" and "Group" !',
        type = "error"
      )
      return(F)
    }
    
    if( !all(unique(ic501$Group) == c("Effevtive","Ineffective")) ){
      sendSweetAlert(
        session = session,
        title = "Error...",
        text = 'Please make sure your IC50 table column "Group" only contain "Effevtive" and "Ineffective" !',
        type = "error"
      )
      return(F)
    }
  }
  
  
  
  return(T)
}

output$dl_drug_ann_bm <- downloadHandler(
  filename = function() {
    stringr::str_split(input$sel_experiment,".rdata")[[1]][1]
    return(paste0(stringr::str_split(input$sel_experiment,".rdata")[[1]][1],"_blank_annotations.txt"))
  },
  content = function(file) {
    load(paste0("data_preload/drugexp/",input$sel_experiment))
    # df_ann_export1 <- data.frame(
    #   "Compound.name" =   unique(sig_GSE92742$pert_iname),
    #   "Group" = rep(c("Effevtive","Ineffective"), times=c(50,length(unique(sig_GSE92742$pert_iname)) - 50))
    # )
    df_ann_export1 <- data.frame(
      "Compound.name" =   unique(sig_GSE92742$pert_iname),
      "Group" = c("Effevtive","Ineffective",rep(NA,times=length(unique(sig_GSE92742$pert_iname)) - 2))
    )
    
    rio::export(df_ann_export1, file,format = "tsv",row.names = F)
  }
)


# output$dl_solo_sig1 <- downloadHandler(
#   filename = function() {
#     return("signature.txt")
#   },
#   content = function(file) {
#     file.copy("demo/signature.txt", file)
#   }
# )




initial_bm <- tagList(
  includeMarkdown("www/tab_benchmark.md")
)