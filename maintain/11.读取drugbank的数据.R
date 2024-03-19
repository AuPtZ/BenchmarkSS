library(dplyr)

ddd = read.delim2("data_preload/annotation/drugbankitem.csv",header = F)

colnames(ddd) <- c("DrugID","DrugName","DrugType","Indication")

rio::export(ddd %>% dplyr::filter(DrugType == "small molecule"),
            file = "data_preload/annotation/DBfile.xlsx")