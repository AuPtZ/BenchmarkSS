library(dplyr)
library(tidyr)

ddd = read.delim2("data_preload/annotation/drugbankitem.csv",header = F)

colnames(ddd) <- c("DrugID","DrugName","DrugType","Status","Indication")

rio::export(ddd %>%
              separate_rows(Status, sep = ",") %>%
              filter(DrugType == "small molecule",Status == "approved" ) ,
            file = "data_preload/annotation/DBfile.xlsx")