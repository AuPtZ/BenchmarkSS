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





dir2 = "NULLprocessing/NULLscore/"

for (i in list.files(dir2)){

    load(paste0(dir2,i))
    colnames(nulldistribution) <- 1:ncol(nulldistribution)
    
    ddd <- nulldistribution[,1:1999] %>% 
      rownames_to_column(var = "drugname")
    
    dbWriteTable(conn, i, ddd)

    print(paste0("writed ",i))

}

# 用于筛选前1999的signature
# ddd %>%  dplyr::filter(drugname == "fluspirilene") %>% dplyr::select(-drugname) %>% unlist(use.names = FALSE)



# 





# List all the tables available in the database
dbListTables(conn)
# END
dbDisconnect(conn)

