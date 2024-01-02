#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)
library(shinythemes)
library(shinyWidgets)
library(shinyBS)
library(shinycssloaders)
library(shinylogs)
library(future)
library(promises)
library(htmltools)
plan(multisession)
plan(future.callr::callr)

shinyOptions(cache = cachem::cache_mem(max_size = 1000e6))
options(shiny.sanitize.errors = TRUE)

ui <- tagList( # needed for shinyjs
  useShinyjs(),  # Include shinyjs
  useSweetAlert(), 

  navbarPage(id = "intabset", #needed for landing page
             # title = "BCSS",
             title = div(tags$a(img(src="LOGO.png", height=50)),
                         style = "position: relative; top: -15px;"), # Navigation bar
             windowTitle = "Signature Search Polestar", #title for browser tab
             theme = shinytheme("cerulean"), #Theme of the app (blue navbar)
             collapsible = TRUE, #tab panels collapse into menu in small screens
             header = tags$head(includeCSS("www/styles.css"), # CSS styles
                                HTML("<html lang='en'>"),
                                tags$link(rel="shortcut icon", href="favicon.ico"), #Icon for browser tab
                                HTML("<base target='_blank'>"),
                                # cookie_box
                                ),
             ###############################################.
             ## Landing page ----
             ###############################################.
             tabPanel(
               title = "Home", icon = icon("home"),
               mainPanel(width = 12, # style="margin-left:4%; margin-right:4%",
                         
                         fluidRow(column(7,(h3("Signature Search Polestar", style="margin-top:1px;"))),
                                  (column(4,actionButton("btn_landing",
                                                         label="Help: Take tour of the tool",
                                                         icon=icon('question-circle'),class="down")))),
                         # 第一行
                         fluidRow(

                           column(6, class="landing-page-column",br(), #spacing
                                  lp_main_box(image_name= "landing_button_time_trend",
                                              button_name = 'jump_to_bm', title_box = "Benchmark",
                                              description = 'Evalutaion of Signature Search methods based on annotation')),
                           
                           column(6, class="landing-page-column",br(), #spacing
                                  lp_main_box(image_name= "landing_button_time_trend",
                                              button_name = 'jump_to_rb', title_box = "Robustness",
                                              description = 'Evalutaion of Signature Search methods without annotation')),

                         ),

                         # 第二行
                         fluidRow(
                           
                           #Table box
                           column(6, class="landing-page-column",
                                  br(), #spacing
                                  
                                  lp_main_box(image_name= "landing_button_data_table",
                                              button_name = 'jump_to_sm', title_box = "Application",
                                              description = 'Query drugs by Signature Search'),
                                  
                           ),
                           
                           #Table box
                           column(6, class="landing-page-column", br(), #spacing
                                  lp_main_box(image_name= "landing_button_other_profile",
                                              button_name = 'jump_to_an', title_box = "Annotation",
                                              description = 'Get annotation of Drugs'),
                                  
                           ),
                         ),

                         # 第三行
                         fluidRow(
                           #Table box
                           column(6, class="landing-page-column", br(), #spacing
                                  lp_main_box(image_name= "landing_button_technical_resources",
                                              button_name = 'jump_to_jc', title_box = "Job Center",
                                              description = 'Retrieve your query result'),
                                  
                           ),
                           # data page
                           column(6, class="landing-page-column",br(), #spacing
                                  lp_main_box(image_name= "landing_button_related_links",
                                              button_name = 'jump_to_ct', title_box = "Converter",
                                              description = 'Easy convert gene identifier')
                           ),
                           
                         ),
                         
               ) #main Panel bracket
             ),# tab panel bracket
             ###############################################.
             ## Benchmark ----
             ###############################################.
             tabPanel("Benchmark", icon = icon("chart-area"), value = "benchmark",
                      sidebarLayout(  
                        sidebarPanel( width = 4,
                          id= "bm_input",
                          popify(
                            shiny::strong(tagList("Step 1. Select a pharmacotranscriptomic dataset",icon("circle-question"))),
                            title = NULL,
                            content = paste(
                              "SSP contains datasets of nine tumor cell lines at ",
                              as.character(strong("diifferent concentration and treat time.")),
                              "<br>In general, we recommend user to select a dataset with more drugs and highly related to disease of interest"
                              ),
                            trigger = "click", placement = "right"
                          ),
                          
                          pickerInput("sel_experiment", label = NULL, 
                                      choices=drug_num_list1 , selected = "LINCS_A375_10 µM_6 h.rdata"
                                      ),
                          downloadButton("dl_drug_ann_bm","Download Blank Annotation", class = "btn-success"),
                          
                          shiny::br(),

                          shiny::br(),
                          popify(
                            shiny::strong(tagList("Step 2. Select Signature Search methods",icon("circle-question"))),
                            title = NULL,
                            content = paste("Please select ",
                                            as.character(strong("at least TWO")),
                                            "methods for benchmark. More methods mean more time.",
                                            as.character(strong("The time for a full-seleted job is 15~30 mins"))
                            ),
                            trigger = "click",
                            placement = "right"
                          ),
                          shiny::p(),
                          shiny::p(),
                          awesomeCheckboxGroup("sel_ss",
                                               label = NULL,
                                               choices=ss_list,
                                               selected = list("SS_Xsum","SS_CMap")
                          ),
                          
                          shiny::br(),
                          popify(
                            shiny::strong(tagList("Step 3. upload disease signature",icon("circle-question"))),
                            title = NULL,
                            content = paste("Disease signature is a gene list (gene symbol) with log2FC, and a", 
                                          a(href = "demo/signature.txt", "demo signature file"),
                                          "is provided. <br>If you have other identifier (e.g. EntrezID), please go to",
                                          as.character(strong(" convertor page"))," to convert your signature."
                            ),
                            trigger = "click",
                            placement = "right"
                          ),

                          fileInput(
                            inputId = "file_sig",
                            label = NULL,
                            buttonLabel = "Browse...",
                            placeholder = "No file selected",
                            accept = c(".csv",".txt")
                          ),
                          


                          shiny::br(),
                          
                          popify(
                            shiny::strong(tagList("Step 4a: upload drug annotations (for AUC)",icon("circle-question"))),
                            title = NULL,
                            content = paste("At least upload one type annotation in 4a or 4b, also you can upload both of them. A", 
                                            a(href = "demo/drug_annotation_AUC.txt", "demo drug annotation for AUC"),
                                            "is provided."
                            ),
                            trigger = "click",
                            placement = "right"
                          ),
                          
                          fileInput(
                            inputId = "file_IC50",
                            label = NULL,
                            buttonLabel = "Browse...",
                            placeholder = "No file selected",
                            accept = c(".csv",".txt")
                          ),
                          
                          shiny::br(),
                          
                          
                          popify(
                            shiny::strong(tagList("Step 4b: upload drug annotations (for ES)",icon("circle-question"))),
                            title = NULL,
                            content = paste("At least upload one drug annotation in 4a or 4b, also you can upload both of them. A", 
                                            a(href = "demo/drug_annotation_ES.txt", "demo drug annotation for ES"),
                                            "is provided."
                            ),
                            trigger = "click",
                            placement = "right"
                          ),
                          
                          fileInput(
                            inputId = "file_FDA",
                            label = NULL,
                            buttonLabel = "Browse...",
                            placeholder = "No file selected",
                            accept = c(".csv",".txt")
                          ),
                          
                          
                          actionButton("runBM", "Run", class = "btn-success"),
                          actionButton("reset","Reset"),

                          
                        ), # end of side pannel
                        
                        mainPanel(id= "bm_out",
                                  uiOutput(outputId = "display_bm") %>% withSpinner(),
                        )
                      ) # slidelayout
             ), #Tab panel bracket
             
             ###############################################.
             ## Robustness ----
             ###############################################.
             tabPanel("Robustness", icon = icon("chart-area"), value = "robustness",
                      sidebarLayout(  
                        sidebarPanel( width = 4,
                                      id= "rb_input",
                                      
                                      popify(
                                        shiny::strong(tagList("Step 1. Select a pharmacotranscriptomic dataset",icon("circle-question"))),
                                        title = NULL,
                                        content = paste(
                                          "SSP contains datasets of nine tumor cell lines at ",
                                          as.character(strong("diifferent concentration and treat time.")),
                                          "<br>In general, we recommend user to select a dataset with more drugs and highly related to disease of interest"
                                        ),
                                        trigger = "click", placement = "right"
                                      ),
                                      
                                      pickerInput("sel_experiment_rb", label = NULL, 
                                                  choices=drug_num_list1 , selected = "LINCS_A375_10 µM_6 h.rdata"
                                      ),

                                      shiny::br(),
                                      
                                      popify(
                                        shiny::strong(tagList("Step 2. Select Signature Search:",icon("circle-question"))),
                                        title = NULL,
                                        content = paste(
                                          "Robustness pre-computes the performance of signature search methods at different datasets.<br>",
                                          as.character(strong("Just select your interested methods.")),
                                          "<br>The methods over average(red) are reconmmended to use in application module."
                                        ),
                                        trigger = "click", placement = "right"
                                      ),
                                      shiny::p(),
                                      shiny::p(),
                                      awesomeCheckboxGroup("sel_ss_rb",
                                                           NULL,
                                                           choices=ss_list,
                                                           selected = list("SS_Xsum","SS_CMap","SS_GESA","SS_ZhangScore","SS_XCos")
                                      ),
                                      shiny::br(),
                                      actionButton("runRB", "Run", class = "btn-success"),
                                      actionButton("reset_rb","Reset"),
                        ), # end of side pannel
                        mainPanel(id= "rb_out",
                                  uiOutput(outputId = "display_rb") %>% withSpinner()
                        ),
                      ) # slidelayout
             ), #Tab panel bracket
             
             ###############################################.
             ## Application ----
             ###############################################.
             tabPanel("Application", icon = icon("list-ul"), value = "singlemethod",
                      sidebarLayout( 
                        sidebarPanel(  width = 4,
                          id= "sm_input",
                          
                          popify(
                            shiny::strong(tagList("Step 1. Select module:",icon("circle-question"))),
                            title = NULL,
                            content = paste(
                              as.character(strong("Single Search")),
                              " is the traditional method to query promising drugs, just like GSEA.<br>",
                              as.character(strong("SS_all")),
                              "query promising drugs integrating the results of all SS methods.<br>",
                              as.character(strong("SS_corss")),
                              " use two disease signatures to query promising drugs with ploypharmacological effects."
                            ),
                            trigger = "click", placement = "right"
                          ),
                          
                          # 设定网页模块
                          pickerInput(inputId = "sel_model_sm", label = NULL, 
                                      choices = list("Single method" = "singlemethod", 
                                                     "SS cross" = "SS_cross", 
                                                     "SS all" = "SS_all"), 
                                      selected = "singlemethod"),
                          shiny::br(),
                          
                          # 设定三个子页面的状态
                          # 单个模块界面，只要确定选择哪个算法就行
                          conditionalPanel(
                            condition = "input.sel_model_sm == 'singlemethod' | input.sel_model_sm == 'SS_cross'" ,
                            
                            popify(
                              shiny::strong(tagList("Step 2. Select Signature Search method:",icon("circle-question"))),
                              title = NULL,
                              content = paste(
                                "Just select one method of your interest."
                              ),
                              trigger = "click", placement = "right"
                            ),
                            shiny::p(),
                            awesomeRadio("sel_ss_sm",
                                         NULL,
                                         choices=ss_list,
                                         selected = list("SS_Xsum")
                            ),
                          ),
                          
                          # 交叉模块，需要确定选择哪个算法
                          # （目前来看和single算法一致，此处预留拓展空间）
                          # conditionalPanel(
                          #   condition = "" ,
                          #   radioButtons("sel_ss_sm",
                          #                "Step 2. Select method",
                          #                choices=ss_list,
                          #                selected = list("SS_Xsum"),
                          #   ),
                          # ),
                          
                          # 全部运算模块
                          # 需要，选择算法，设定汇总排序的区域
                          conditionalPanel(
                            condition = "input.sel_model_sm == 'SS_all'" ,
                            
                            popify(
                              shiny::strong(tagList("Step 2a. Select methods",icon("circle-question"))),
                              title = NULL,
                              content = paste(
                                "Please at least two methods of your interest, More methods mean more time.",
                                as.character(strong("The time for a full-seleted job is 20~40 mins"))
                              ),
                              trigger = "click", placement = "right"
                            ),
                            shiny::p(),
                            
                            awesomeCheckboxGroup("sel_all_sm", 
                                               "",
                                               choices=ss_list,
                                               selected = list("SS_Xsum","SS_CMap"),
                                               
                            ),
                            
                            popify(
                              shiny::strong(tagList("Step 2b: Select direct to show:",icon("circle-question"))),
                              title = NULL,
                              content = paste(
                                "SS_all only compare the drugs in same direction."
                              ),
                              trigger = "click", placement = "right"
                            ),
                            shiny::p(),
                            
                            awesomeRadio("sel_direct_sm", 
                                         NULL,
                                         choices=sm_direct,inline = T,
                                         selected = list("Down")
                            ),
                          ),
                          
                          # 确定选择哪个算法作为比较基准
                          shiny::br(),
                          popify(
                            shiny::strong(tagList("Step 3. Select a pharmacotranscriptomic dataset",icon("circle-question"))),
                            title = NULL,
                            content = paste(
                              "SSP contains datasets of nine tumor cell lines at ",
                              as.character(strong("diifferent concentration and treat time.")),
                              "<br>In general, we recommend user to select a dataset with more drugs and highly related to disease of interest"
                            ),
                            trigger = "click", placement = "right"
                          ),
                          pickerInput("sel_experiment_sm", label = NULL, 
                                      choices=drug_num_list1 , selected = "LINCS_A375_10 µM_6 h.rdata"
                                      ),

                          shiny::br(),
                          
                          conditionalPanel(
                            condition = "input.sel_model_sm == 'SS_all' | input.sel_model_sm == 'singlemethod'" ,
                            
                            popify(
                              shiny::strong(tagList("Step 4. upload signature",icon("circle-question"))),
                              title = NULL,
                              content = paste("Disease signature is a gene list (gene symbol) with log2FC, and a", 
                                              a(href = "demo/signature.txt", "demo signature file"),
                                              "is provided. <br>If you have other identifier (e.g. EntrezID), please go to",
                                              as.character(strong(" convertor page"))," to convert your signature."
                              ),
                              trigger = "click",
                              placement = "right"
                            ),
                            
                            # 上传signature (普通情况)
                            fileInput(
                              inputId = "file_sig_sm",
                              label = NULL,
                              buttonLabel = "Browse...",
                              placeholder = "No file selected",
                              accept = c(".csv",".txt")
                            ),
                          ),
                          
                          conditionalPanel(
                            condition = "input.sel_model_sm == 'SS_cross'" ,
                            
                            # 上传signature (特殊情况)
                            popify(
                              shiny::strong(tagList("Step 4a: upload signature 1",icon("circle-question"))),
                              title = NULL,
                              content = paste("annotation(name) for the below signature"),
                              trigger = "click",
                              placement = "right"
                            ),
                            
                            textInput("file_name1", label = NULL, value = "Signature1"),
                            fileInput(
                              inputId = "file_sig_sm1",
                              label = NULL,
                              buttonLabel = "Browse...",
                              placeholder = "No file selected",
                              accept = c(".csv",".txt")
                            ),
                            
                            popify(
                              shiny::strong(tagList("Step 4b: upload signature 2",icon("circle-question"))),
                              title = NULL,
                              content = paste("annotation(name) for the below signature"),
                              trigger = "click",
                              placement = "right"
                            ),
                            textInput("file_name2",label = NULL , value = "Signature2"),
                            fileInput(
                              inputId = "file_sig_sm2",
                              label = NULL,
                              buttonLabel = "Browse...",
                              placeholder = "No file selected",
                              accept = c(".csv",".txt")
                            ),
                          ),
                          # 设定使用排序多少的内容进行计算？
                          popify(
                            shiny::strong(tagList("Step 5. Set read gene num(topN)",icon("circle-question"))),
                            title = NULL,
                            content = paste("topN is determined by Benchmark or Robustness. <br>",
                                            "If this score is monotonically increasing in Benchmark and Robustness, ",
                                            "we recommend setting topN to 150."),
                            trigger = "click",
                            placement = "right"
                          ),
                          
                          numericInput("sel_topn_sm", label = NULL, 
                                       value = 150, min = 50, max = 489),
                          
                          shiny::br(),
                          actionButton("runSM", "Run", class = "btn-success"),
                          actionButton("reset_sm","Reset"),
                          
                        ),
                        mainPanel( id= "sm_out",
                          uiOutput(outputId = "display_sm") %>% withSpinner()
                        ),

                      )
             ), #Tab panel bracket
             ###############################################.
             ## Annotation ---- 
             ###############################################.
             tabPanel("Annotation", icon = icon("table"), value = "annotation",
                      sidebarLayout( 
                        sidebarPanel(  width = 4,
                                       id = "an_page",
                                       shiny::p(
                                         br(),
                                         "Select a cancer and download annotations.",
                                         br(),
                                         "The drug annotation are display on the right table.",
                                         br(),
                                         "Here are two types of annotation files for different methods.",
                                         br(),
                                       ),
                                       selectInput("an_input","Step 1. Select cancer",
                                                   choices = disinfo_vector,
                                                   selected = "PRAD"),
                                       selectInput("an_input_type","Step 2. Select annotation type",
                                                   choices = c("Area Under Curve(AUC)" = "AUC",
                                                               "Enrichment Score(ES)" = "ES"),
                                                   selected = "AUC"),
                                       shiny::br(),
                                       downloadButton("run_AN","Download annotations", class = "btn-success"),
                        ),
                        mainPanel(id= "an_out",
                                  uiOutput(outputId = "display_an") %>% withSpinner(),
                                  dataTableOutput("display_an_tb")

                        ), # main panel bracket
                      ),
                      
             ), #Tab panel bracket
             
             
             
             ###############################################.
             ## Job Center ---- 
             ###############################################.
             tabPanel("Job Center", icon = icon("signal"), value = "jobcenter",
                      sidebarLayout( 
                        sidebarPanel(  width = 4,
                          id = "job_page",
                          textInput("jobid_input", label = "Input Jobid", value = "demo1"),
                          shiny::br(),
                          actionButton("jobid_get","Retrieve", class = "btn-success"),
                          shiny::p(
                            br(),
                            "Here we provide some jobid for demo result presentation.",
                            br(),
                            strong("BEN1673757786WRK")," for Benchmark(Both AUC and ES)",
                            br(),
                            strong("APP1665835183CJF")," for Application(Single method)",
                            br(),
                            strong("APP1673711282IHW")," for Application(SS_all)",
                            br(),
                            strong("APP1673711120BKD")," for Application(SS_cross)", # APP1673762652RIC
                            br(),
                          )

                        ),
                        mainPanel(id= "jc_out",
                                  tableOutput("display_jc_info"),
                                  uiOutput(outputId = "display_jc") %>% withSpinner()
                        ), # main panel bracket
                      ),

             ), #Tab panel bracket
             ###############################################.
             ## Coverter ----
             ###############################################.
             tabPanel("Coverter", icon = icon("table"), value = "coverter",
                      #Sidepanel for filtering data
                      sidebarLayout(
                        sidebarPanel(
                          textAreaInput("text_ct", "Step 1. Input your signature",height = "200px"),
                          actionButton("runCTdemo", "demo"),
                          shiny::p(),
                          radioButtons("format_ct", "Step 2. Select the \"From\" ID", 
                                       inline = T,
                                       choices = c("ENTREZID", "ENSEMBL","UNIGENE","GENENAME")),
                          checkboxInput("header_check_ct", label = strong("Step 3. Header or non-header?") ,
                                        value = TRUE),
                          actionButton("runCT", "Convert", class = "btn-success")
                        ),
                        
                        mainPanel(id= "ct_out",
                                  uiOutput(outputId = "display_ct") %>% withSpinner()
                        )  # main panel bracket
                      ),
                      
             ), #Tab panel bracket
             
             ###############################################.             
             ##############NavBar Menu----
             ###############################################.
             #Starting navbarMenu to have tab with dropdown list
             navbarMenu("Info", icon = icon("info-circle"),
                        ###############################################.
                        ## About ----
                        ###############################################.

                        tabPanel("Help", value = "help",
                                 fluidRow(
                                   column(1,
                                          # "sidebar1"
                                   ),
                                   column(10,
                                          navlistPanel(
                                            "Help info",
                                            tabPanel("Q1: Why we built SSP?", 
                                                     includeMarkdown("www/info_Q1.md")
                                                     # uiOutput(outputId = "display_Q1") %>% withSpinner()
                                            ),
                                            tabPanel("Q2: How to use Benchmark and interpret the results?",
                                                     includeMarkdown("www/info_Q2.md")
                                                     # uiOutput(outputId = "display_Q2") %>% withSpinner()
                                            ),
                                            tabPanel("Q3: How to use Robustness and interpret the results?",
                                                     includeMarkdown("www/info_Q3.md")
                                                     # uiOutput(outputId = "display_Q3") %>% withSpinner()
                                            ),

                                            tabPanel("Q4: How to query drug in Application and interpret the results?",
                                                     includeMarkdown("www/info_Q4.md")
                                                     # uiOutput(outputId = "display_Q4") %>% withSpinner()
                                            ),
                                            tabPanel("Q5: How to download data?",
                                                     includeMarkdown("www/info_Q5.md")
                                                     # uiOutput(outputId = "display_Q5") %>% withSpinner()
                                            ),
                                            tabPanel("Q6: How to get job result again?",
                                                     includeMarkdown("www/info_Q6.md")
                                                     # uiOutput(outputId = "display_Q6") %>% withSpinner()
                                            ),
                                            tabPanel("Q7: How to annotate drug?",
                                                     includeMarkdown("www/info_Q7.md")
                                                     # uiOutput(outputId = "display_Q7") %>% withSpinner()
                                            ),
                                            tabPanel("Q8: How to query drugs if I have a drug signature?",
                                                     includeMarkdown("www/info_Q8.md")
                                                     # uiOutput(outputId = "display_Q8") %>% withSpinner()
                                            ),
                                            tabPanel("Q9: How to find the best topN and method?",
                                                     includeMarkdown("www/info_Q9.md")
                                                     # uiOutput(outputId = "display_Q9") %>% withSpinner()
                                            ),
                                            tabPanel("Q10: How to deployed SSP in my own computer or server?",
                                                     includeMarkdown("www/info_Q10.md")
                                                     # uiOutput(outputId = "display_Q10") %>% withSpinner()
                                            ),
                                            tabPanel("Q11: How to get job result again?",
                                                     includeMarkdown("www/info_Q11.md")
                                                     # uiOutput(outputId = "display_Q11") %>% withSpinner()
                                            ),
                                            widths = c(4,8)
                                          ),
                                   ),
                                   column(1,
                                          # "sidebar2"
                                   )
                                 ),


                                 ),#Tab panel
                        tabPanel("Data", value = "data",
                                 
                                 fluidRow(
                                   column(3,
                                          # "sidebar1"
                                   ),
                                   column(7,
                                          # shiny::h3("Download manual of SSP"),
                                          # downloadButton("dl_manual_pdf", "Download manual", class = "btn-success"),
                                          shiny::h3("Download demo file for perform jobs"),
                                          downloadButton("dl_demo","Download Demo", class = "btn-success"),
                                          downloadButton("dl_script","Download Script", class = "btn-success"),
                                          shiny::br(),
                                          shiny::h3("Download curated drug expression profile"),
                                          pickerInput("sel_experiment_dl", label = "Select drug profiles", 
                                                      choices=drug_num_list1 , selected = "LINCS_A375_10 µM_6 h.rdata"
                                          ),
                                          downloadButton("dl_drug_exp","Download Drug Profiles", class = "btn-success"),
                                          downloadButton("dl_drug_ann","Download Drug Annotation", class = "btn-success"),
                                   ),
                                   column(2,
                                          # "sidebar2"
                                   )
                                 ),
                                 
                        ),#Tab panel
                        tabPanel("About", value = "about",

                                 fluidRow(
                                   column(3,
                                          # "sidebar1"
                                   ),
                                   column(6,
                                          uiOutput(outputId = "display_about") %>% withSpinner()

                                   ),
                                   column(3,
                                          # "sidebar2"
                                   )
                                 ),

                        ),#Tab panel

                        ###############################################.

             ),# NavbarMenu bracket
  ), #Bracket  navbarPage

  div(style = "margin-bottom: 45px;"), # this adds breathing space between content and footer
  
  ## CODE FOR STATISTICS
  div(
    tags$script(src="//rf.revolvermaps.com/0/0/7.js?i=5jq3pohyu8j&amp;m=0&amp;c=ff0000&amp;cr1=ffffff&amp;sx=0",
                async="async"
    ),style = "width:0%;margin:0 auto;"
  ),
  div(
    tags$script("
    var _hmt = _hmt || [];
    (function() {
      var hm = document.createElement('script');
      hm.src = 'https://hm.baidu.com/hm.js?c80c4665444bb409416f091b83b97f57';
      var s = document.getElementsByTagName('script')[0];
      s.parentNode.insertBefore(hm, s);
    })();
  "),style = "width:0%;margin:0 auto;"
  ),
  ###############################################.             
  ##############Footer----    
  ###############################################.
  # Copyright warning
  tags$footer(column(6, "This website is free and open to all users and there is no login requirement."),
              column(2, tags$a(href="mailto:jbzhangs@foxmail.com", tags$b("Contact us!"),
                               class="externallink", style = "color: white; text-decoration: none")),
              style = "
   position:fixed;
   text-align:center;
   left: 0;
   bottom:0;
   width:100%;
   z-index:1000;
   height:40px; /* Height of the footer */
   color: white;
   padding: 10px;
   font-weight: bold;
   background-color: #1995dc"
  )
  ################################################.
) #bracket tagList
###END




serverLoaded <- FALSE

###############################################.             
##############Server----    
###############################################.
server <- function(input, output, session) {

  ## 在启动时判断sever是否加载完全（主要是按钮能否有反应）
  if (!serverLoaded) {
    sendSweetAlert(
      session = session,
      title = "Welcome to SSP",
      text = "SSP is initializating. Please wait until the window closed." ,
      type = "info",
      btn_labels = NA,
      closeOnClickOutside = FALSE,
      showCloseButton = FALSE,
    )
  }

  session$onFlushed(once = TRUE, function() {
    closeSweetAlert()
    serverLoaded <<- TRUE
  })
  
  ###############################################.
  ## Sourcing tab code  ----
  ###############################################.
  # Sourcing file with server code
  source(file.path("tab_benchmark.R"),  local = TRUE)$value # benchmark tab
  source(file.path("tab_robustness.R"),  local = TRUE)$value # robustness tab
  source(file.path("tab_application.R"),  local = TRUE)$value # application tab
  source(file.path("tab_jobcenter.R"),  local = TRUE)$value # jobcenter tab
  # source(file.path("data_tab.R"),  local = TRUE)$value # data tab
  source(file.path("tab_info.R"),  local = TRUE)$value # info tab
  source(file.path("tab_converter.R"),  local = TRUE)$value # converter tab
  
  ### 2023年10月1日新增部分 ###
  source(file.path("tab_annotation.R"),  local = TRUE)$value # annotation tab
  ### 2023年10月1日新增部分 ###
  
  ### 2023年12月19日新增部分 ###
  addResourcePath(prefix = "demo", directoryPath = "demo") # 添加下载路径，用于提供单独的demofile的下载！
  
    ### 2023年12月19日新增部分 ###
  

  observeEvent(input$jump_to_bm, {
    updateTabsetPanel(session, "intabset", selected = "benchmark")
  })
  
  observeEvent(input$jump_to_rb, {
    updateTabsetPanel(session, "intabset", selected = "robustness")
  })
  
  observeEvent(input$jump_to_sm, {
    updateTabsetPanel(session, "intabset", selected = "singlemethod")
  })
  
  ### 2023年10月1日新增部分 ###
  observeEvent(input$jump_to_an, {
    updateTabsetPanel(session, "intabset", selected = "annotation")
  })
  ### 2023年10月1日新增部分end ###
  
  observeEvent(input$jump_to_jc, {
    updateTabsetPanel(session, "intabset", selected = "jobcenter")
  })
  
  observeEvent(input$jump_to_ct, {
    updateTabsetPanel(session, "intabset", selected = "coverter")
  })
  
  # 重置
  observeEvent(input$btn_landing, {
    updateTabsetPanel(session, "intabset", selected = "help")
  })

}







###############################################.             
##############Running Code----    
###############################################.
# Run the application 
shinyApp(ui = ui, server = server)
