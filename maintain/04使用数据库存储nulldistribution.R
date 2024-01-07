## 修改文件名字
if(F){
  library(stringr) 
  for (i in list.files("data_preload/nulldistribution")){
    if (str_detect(i,"rdata")){
      
      ii = paste0("data_preload/nulldistribution/",i)
      
      try(
        file.rename(from = ii, to = str_replace_all(ii,c("ss_xsum"="SS_Xsum",
                                                         "ss_cos"="SS_XCos",
                                                         "ss_zh"="SS_ZhangScore",
                                                         "SS_GESA" = "SS_GSEA",
                                                         "ss_gs"="SS_GESA",
                                                         "ss_ks"="SS_CMap")))
      )
    }
  }
  
}


# 读入并保存数据

library(RSQLite)
library(tibble)
library(dplyr)
library(tidyverse)
library(tidyr)

conn <- dbConnect(RSQLite::SQLite(), "data_preload/nulldistribution/Nulldistribution.db")


tables <- dbListTables(conn)

dbListTables(conn) %>% purrr::walk(~dbRemoveTable(conn, .))
# dbExecute(conn, "VACUUM")
tables <- dbListTables(conn)

dir2 = "NULLprocessing/NULLscore/"

## "LINCS_A375_10 µM_24 h.rdata_SS_Xsum.rdata"

nn = 0
for (i in list.files(dir2)[!(list.files(dir2) %in% tables)]){
      load(paste0(dir2,i))
      colnames(nulldistribution) <- 1:ncol(nulldistribution)
      
      ddd <- nulldistribution[,1:(ncol(nulldistribution) - 1)] %>% 
        rownames_to_column(var = "drugname")
      
      dbWriteTable(conn, i, ddd)
      nn = nn + 1
      print(paste0("writed ",i,"  ",nn))
}
# List all the tables available in the database
dbListTables(conn)
dbExecute(conn, "VACUUM")
# END
dbDisconnect(conn)

# 用于筛选前1999的signature
# ddd %>%  dplyr::filter(drugname == "fluspirilene") %>% dplyr::select(-drugname) %>% unlist(use.names = FALSE)
