library(rio)
library(dplyr)
library(webchem)

GSDC_drug_info <- rio::import("data_preload/annotation/Drug_listSat Dec 16 12_33_15 2023.csv")

GSDC_drug_info$PubCHEM <- as.numeric(GSDC_drug_info$PubCHEM)

for (i in 1:nrow(GSDC_drug_info)){
  if(is.na(GSDC_drug_info$PubCHEM[i])){
    GSDC_drug_info$PubCHEM[i] <- get_cid(GSDC_drug_info$Name[i],
                                         from = "name", domain = "compound", 
                                         match = "first")$cid
  }
  if(is.na(GSDC_drug_info$PubCHEM[i])){
    GSDC_drug_info$SMILEs[i] = NA
    GSDC_drug_info$InChIKeys[i] = NA
  }else{
    drug = pc_prop(GSDC_drug_info$PubCHEM[i])
    GSDC_drug_info$SMILEs[i] <- smiles(drug)
    GSDC_drug_info$InChIKeys[i] <- inchikey(drug)
  }
  print(GSDC_drug_info$PubCHEM[i])
}

load("data_preload/annotation/GSDCIC50.Rdata")




