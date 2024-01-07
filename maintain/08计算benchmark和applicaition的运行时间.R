library(bench)

if(F){
  benchmarkTest <- function(profile){
    library(dplyr)
    library(tidyr)
    library(ggplot2)
    library(tibble)
    library(pROC)
    library(rio)
    library(tidyverse)
    
    setwd("~/rprojects/SSP/")
    
    source("R/global.R")
    source("R/SS.R")
    source("R/Utils_BM.R")
    source("R/Utils_RB.R")
    source("R/Utils_SM.R")
    
    IC50_drug <- rio::import("demo/drug_annotation_AUC.txt")
    FDA_drug <- rio::import("demo/drug_annotation_ES.txt")
    i.need.logfc <- rio::import("demo/signature.txt") %>% dplyr::select(c("Gene","log2FC"))
    sel_exp = profile
    sel_ss = c("SS_Xsum","SS_CMap","SS_GSEA","SS_ZhangScore","SS_XCos")
    
    res_bm <- get_benchmark(
      IC50_drug = IC50_drug,
      FDA_drug = FDA_drug, 
      i.need.logfc = i.need.logfc, 
      sel_exp = sel_exp,
      sel_ss = sel_ss
    )
    
    source("~/rprojects/SSP/maintain/06数据结果初始化.R")
    print(paste0("work down! ",Sys.time()))
  }
  
  # 使用microbenchmark()函数来评估函数
  res_benchmark_dataset_major = bench::mark(benchmarkTest("LINCS_VCAP_5 µM_24 h.rdata"), 
                                            iterations = 100, check = FALSE )
  res_benchmark_dataset_minor = bench::mark(benchmarkTest("LINCS_MCF7_1 nM_24 h.rdata"), 
                                            iterations = 100, check = FALSE)
  
  save(res_benchmark_dataset_major,res_benchmark_dataset_minor,file = "res_benchmark.Rdata")
}





if(T){
  applicationTest <- function(profile,sel_model_input){
    
    library(dplyr) # 为了future正常运行使用的
    library(tidyr)
    library(tidyverse)
    setwd("~/rprojects/SSP/")
    
    source("R/global.R")
    source("R/SS.R")
    source("R/Utils_BM.R")
    source("R/Utils_RB.R")
    source("R/Utils_SM.R")
    
    i.need.logfc <- rio::import("demo/signature.txt") %>% 
      dplyr::select(c("Gene","log2FC")) %>% 
      dplyr::mutate(log2FC = runif(n(), min = -1, max = 1))
    
    funcname_mul = c("SS_Xsum","SS_CMap","SS_GSEA","SS_ZhangScore","SS_XCos")
    funcname = "SS_GSEA"
    topn = 150
    direct = "down"
    bioname1 = "bioname1"
    bioname2 = "bioname2"
    
    res_sm_f <-  get_single_method(drug_profile = profile, # 需要额外设定
                                   topn = topn,
                                   sel_model_sm1= sel_model_input, # 需要额外设定
                                   i.need.logfc = i.need.logfc,
                                   funcname = funcname,
                                   funcname_mul = funcname_mul,
                                   direct = direct,
                                   bioname1 = bioname1,
                                   bioname2 = bioname2)
  }

  res_application_SM_major = bench::mark(applicationTest(profile = "LINCS_VCAP_5 µM_24 h.rdata",
                                                         sel_model_input = "singlemethod"), 
                                            iterations = 100, check = FALSE )
  res_application_SM_minor = bench::mark(applicationTest(profile = "LINCS_MCF7_1 nM_24 h.rdata",
                                                         sel_model_input = "singlemethod"), 
                                            iterations = 100, check = FALSE)
  res_application_ALL_major = bench::mark(applicationTest(profile = "LINCS_VCAP_5 µM_24 h.rdata",
                                                         sel_model_input = "SS_ALL"), 
                                         iterations = 100, check = FALSE )
  res_application_ALL_minor = bench::mark(applicationTest(profile = "LINCS_MCF7_1 nM_24 h.rdata",
                                                         sel_model_input = "SS_ALL"), 
                                         iterations = 100, check = FALSE)
  res_application_SM_major = bench::mark(applicationTest(profile = "LINCS_VCAP_5 µM_24 h.rdata",
                                                         sel_model_input = "SS_all"), 
                                         iterations = 100, check = FALSE )
  res_application_SM_minor = bench::mark(applicationTest(profile = "LINCS_MCF7_1 nM_24 h.rdata",
                                                         sel_model_input = "SS_cross"), 
                                         iterations = 100, check = FALSE)
  
}

