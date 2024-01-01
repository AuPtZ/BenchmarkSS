# read gctx
library(cmapR)
library(rio)
library(dplyr)
library(tidyr)
library(tidyverse)


# generating L1000 files 
dir = "~/dataportal/LINCS/GSE92742_Broad_LINCS_Level5_COMPZ.MODZ_n473647x12328.gctx"

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

for (i in cellline_list){
  for (j in dose_list){
    for (k in time_list){
      tryCatch({
            save_dir = paste0("~/rprojects/BenchmarkSS/App-1/data_preload/drugexp/LINCS_",i,"_",j,"_",k,".rdata")

            if(!file.exists(save_dir)){
              sig_GSE92742 <- read.delim("~/dataportal/LINCS/GSE92742_Broad_LINCS_sig_info.txt.gz",comment.char = "!")  %>%
                dplyr::filter(cell_id==i & pert_idose == j & pert_itime == k & pert_type == "trt_cp")
              
              
              
              GSE92742 <- parse_gctx(dir, cid=sig_GSE92742$sig_id)
              exp_GSE92742 <- GSE92742@mat
              
              gene_info <- rio::import("~/rprojects/sigsearchmethods/GSE92742_Broad_LINCS_gene_info.txt.gz",format="\t")
              exp_GSE92742 <- exp_GSE92742 %>% as.data.frame() %>%
                rownames_to_column(var="pr_gene_id") %>%
                mutate(pr_gene_id = as.integer(pr_gene_id)) %>%
                inner_join(gene_info) %>%
                column_to_rownames(var="pr_gene_symbol")  %>%
                dplyr::filter(pr_is_lm == 1) %>%
                dplyr::select(contains(i)) %>% as.matrix()
              
              transpose_df <- function(df) {
                t_df <- data.table::transpose(df)
                colnames(t_df) <- rownames(df)
                rownames(t_df) <- colnames(df)
                return(t_df)
              }
              
              exp_GSE92742_1 <- transpose_df(as.data.frame(exp_GSE92742)) %>%
                rownames_to_column(var = "sig_id") %>%
                right_join(sig_GSE92742) %>%
                dplyr::select(c(981,2:979))
              
              exp_GSE92742_2 <- limma::avereps(exp_GSE92742_1[,-1],ID=exp_GSE92742_1$pert_iname)
              exp_GSE92742_3 <- transpose_df(as.data.frame(exp_GSE92742_2))
              
              exp_GSE92742 <- exp_GSE92742_3
              
              if(ncol(exp_GSE92742)>100){
                save(exp_GSE92742,sig_GSE92742, file = save_dir)
                print(paste0(save_dir," success!"))
              }

              rm(save_dir,sig_GSE92742,exp_GSE92742,GSE92742,
                 exp_GSE92742_1,exp_GSE92742_2,exp_GSE92742_3)
            }
        
        
      },  error = function(e){
        print(paste0(save_dir," failed!"))
      })
    }
  }
}