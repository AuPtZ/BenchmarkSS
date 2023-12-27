###############################################.
## convert - common objects ----
###############################################.


library(clusterProfiler)
library(org.Hs.eg.db)

# 初始化
output$display_ct <- renderUI({initial_ct})

# demo触发
observeEvent(input$runCTdemo, {  # 添加这个observeEvent
  demo_text <- readLines("demo/demo_signature_entrezid.txt")
  updateRadioButtons(session, "format_ct", selected = "ENTREZID")
  updateCheckboxInput(session, "header_check_ct", value = TRUE)
  updateTextAreaInput(session, "text_ct", value = paste(demo_text, collapse = "\n"))
})


# 构建用于跨函数传递的参数
rv_ct <- reactiveValues()

observeEvent(input$runCT, {
  
  req(judge_ct())
  
  if(judge_ct()){

    
    output$display_ct <-  renderUI({
      
      isolate({
        df_ct <- read.table(file = textConnection(input$text_ct), 
                            header = input$header_check_ct, 
                            stringsAsFactors = FALSE)
        
        colnames(df_ct) = c("Gene","Log2FC")
        rv_ct$df_ct2 <- df_ct
        
        rv_ct$df_ct2$Gene <- bitr(
          df_ct$Gene,
          fromType = input$format_ct,
          toType = "SYMBOL",
          OrgDb = org.Hs.eg.db,
          drop = F
        )$SYMBOL
        print(rv_ct$df_ct2)
        rv_ct$df_ct2 <-  na.omit(rv_ct$df_ct2)
        
      })

      tagList(
        shiny::h3("Result"),
        shiny::strong(paste(round(nrow(rv_ct$df_ct2)/nrow(df_ct) *100,digits = 1) ,
                            "% were successfully mapped." )),
        shiny::strong("You may check the input and output and download by click the button."),
        downloadButton(outputId = "download_ct",
                       label = "Download Output",class = "btn-success"),
        column(6, 
               shiny::h4("Input Preview"),
               renderDataTable(df_ct)),
        column(6, 
               shiny::h4("Output Preview"), 
               renderDataTable(rv_ct$df_ct2 ))
      )
    })
    

  }
  

  
})

judge_ct <- function(){
  # 读取文件以后判定
  if(input$text_ct == ""){
    
    sendSweetAlert(
      session = session,
      title = "Error...",
      text = 'Please enter signature !',
      type = "error"
    )
    return(F)
  }
  if(input$text_ct != ""){
    
    tryCatch({
      df_ct <- read.table(file = textConnection(input$text_ct), 
                          row.names = NULL,
                          header = input$header_check_ct, 
                          stringsAsFactors = FALSE)
      
      if (ncol(df_ct) != 2){
        sendSweetAlert(
          session = session,
          title = "Error...",
          text = 'Please make sure your signature is a two-column list!',
          type = "error"
        )
        return(F)
      }
      
      return(T)
      
    }, error = function(e) {
      sendSweetAlert(
        session = session,
        title = "Error...",
        text = 'Please make sure your signature is a list!',
        type = "error"
      )
      return(F)
    })

  }
}

# 初始化
initial_ct <- tagList(
  includeMarkdown("www/converter_tab.md")
)

# 下载转换后的文件
output$download_ct <- downloadHandler(
  filename = function() {
    # Use the selected dataset as the suggested file name
    paste0("signature_",format(Sys.time(), "%Y_%m_%d_%H_%M_%S") ,".txt")
  },
  content = function(file) {
    # Write the dataset to the `file` that will be downloaded
    rio::export(rv_ct$df_ct2, file,format = "tsv",row.names = F)

  }
)

