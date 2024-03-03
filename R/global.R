# In this script include packages, functions, datasets and anyting that will be 
# used both by UI and server


############################.
##Packages ----
############################.
library(shiny)
library(shinyBS) #modals
library(shinythemes) # layouts for shiny
library(dplyr) # data manipulation
library(ggplot2) #data visualization
library(DT) # for data tables
library(leaflet) # javascript maps
library(plotly) # interactive graphs
library(shinyWidgets) # for extra widgets
library(tibble) # rownames to column in techdoc
library(shinyjs)
library(shinydashboard) # for valuebox on techdoc tab
library(sp)
library(lubridate) #for automated list of dates in welcome modal
library(shinycssloaders) #for loading icons, see line below
# it uses github version devtools::install_github("andrewsali/shinycssloaders")
# This is to avoid issues with loading symbols behind charts and perhaps with bouncing of app
library(rmarkdown)

library(pROC)
library(dplyr)
library(rio)
library(tidyr)
library(tidyverse)

library(memoise)

# 加载可视化的数据，用于UI显示
load("data_preload/others/drug_num_list1.rdata") # 读取数据内容
load("data_preload/annotation/disinfo_vector.Rdata")

#Creating big boxes for main tabs in the landing page (see ui for formatting css)
lp_main_box <- function(title_box, image_name, button_name, description) {
  div(class="landing-page-box",
      div(title_box, class = "landing-page-box-title"),
      div(description, class = "landing-page-box-description"),
      div(class = "landing-page-icon", style= paste0("background-image: url(", image_name, ".png);
          background-size: auto 80%; background-position: center; background-repeat: no-repeat; ")),
      actionButton(button_name, NULL, class="landing-page-button")
      )
}






cellline_list <- c("MCF7",
                   "PC3",
                   "A549",
                   "A375",
                   "HEPG2",
                   "VCAP",
                   "HCC515",
                   "HT29",
                   "HA1E")

dose_list <- c("10 µM",
               "5 µM",
               "1 µM",
               "100 µM",
               "500 nM",
               "100 nM",
               "10 nM",
               "1 nM")

time_list <- c("6 h",
               "12 h",
               "24 h",
               "48 h",
               "96 h",
               "120 h",
               "144 h")

ss_list <- list(
  Xsum = "SS_Xsum",
  CMap = "SS_CMap",
  GSEA = "SS_GSEA",
  ZhangScore = "SS_ZhangScore",
  XCos = "SS_XCos"
)

sm_quadrant <- list(
  Q1 = "Q1",
  Q2="Q2",
  Q3="Q3",
  Q4="Q4",
  all = "all"
)


sm_direct <- list(
  up = "Up",
  down = "Down"
)



name_for_res_col <- data.frame(
  Jobid="Job id",
  Submitted_time="Submission time",
  main_module="Main module",
  table_num="Number of table",
  method_bm="Signature Search method used",
  signature_file1="Signature file name",
  fda_file="DR-ES annotation file name",
  ic50_file="DR-AUC annotation file name",
  drug_profile="Drug profile name",
  sub_module="Sub module",
  method_sm1="Signature Search method used",
  direction_sm="direction (For SS_all)",
  method_sm2="Signature Search method used",
  signature_file2="Signature file name",
  signature_file3="Signature file 1 name",
  signature_file4="Signature file 2 name",
  signature_name1="Signature annotation 1",
  signature_name2="Signature annotation 1",
  sel_num_gene="Number of gene used"
)

# 将多个算法输出的结果进行替换
rename_col_rules <- c("XSum" = "auc_xsum", 
                      "CMap" = "auc_ks",
                      "GSEA" = "auc_gs", 
                      "ZhangScore" = "auc_zh", 
                      "XCos" = "auc_cos",
                      "XSum" = "es_xsum", 
                      "CMap" = "es_ks",
                      "GSEA" = "es_gs", 
                      "ZhangScore" = "es_zh", 
                      "XCos"= "es_cos",
                      "TopN" = "topn",
                      "XSum" = "SS_Xsum", 
                      "CMap" = "SS_CMap",
                      "GSEA" = "SS_GSEA", 
                      "ZhangScore" = "SS_ZhangScore", 
                      "XCos" = "SS_XCos",
                      "XSum" = "xsum", 
                      "CMap" = "cmap",
                      "GSEA" = "gsea", 
                      "ZhangScore" = "zhangscore", 
                      "XCos" = "cos"
                      
                      
                      
)


# 决定使用多少个核心
get_cores <- function(){
  if(Sys.info()[[1]] != "Linux" ){
    return(1L)
  }else{
    cores <-  parallel::detectCores()
    return( ifelse( cores> 15, round(0.25*cores), round(0.5*cores)))
  }
}

print(paste0("WE DECIDED TO USE ",get_cores()," CORES"))

# update sessionInfo when NECESSARY
if(F){
  sI = sessioninfo::session_info()
  save(sI,file = "sessioninfo.rdata" )
}





