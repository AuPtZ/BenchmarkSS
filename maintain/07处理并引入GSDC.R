# 为了review，我们新增了从pubchem获取CSDC药物结构的部分：
library(rio)
library(dplyr)

# 从官网上获取的药物信息，全部的
GSDC_drug_info <- rio::import("data_preload/annotation/Drug_listSat Dec 16 12_33_15 2023.csv")

GSDC_drug_info$PubCHEM <- as.numeric(GSDC_drug_info$PubCHEM)

# 基于pubchem进行匹配
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


# 处理GSDC数据库的IC50数据，
GSDC <- rio::import("data_preload/annotation/GDSC2_fitted_dose_response_24Jul22.xlsx") %>% 
  left_join(GSDC_drug_info %>% dplyr::select(c("Drug Id","PubCHEM","SMILEs", "InChIKeys")),
            by=c("DRUG_ID"="Drug Id")) %>% tidyr::drop_na()

GSDC2 <- GSDC %>%
    filter(TCGA_DESC != "UNCLASSIFIED", TCGA_DESC != "OTHER") %>%
    select(c(DRUG_NAME, LN_IC50, CELL_LINE_NAME, TCGA_DESC, PubCHEM, SMILEs,InChIKeys)) %>%
    mutate(IC50 = 2^LN_IC50) %>%
    select(-LN_IC50)

GSDC3 <- GSDC2 %>%
    group_by(DRUG_NAME,  TCGA_DESC,PubCHEM, SMILEs,InChIKeys) %>%
    summarize(IC50 = min(IC50)) %>%
    rename(Compound.name = DRUG_NAME, `IC50 value` = IC50, PubChem_Cid = PubCHEM) %>%
    mutate(Group = if_else(`IC50 value` > 10, "Ineffective", "Effevtive")) %>% 
    select(Compound.name, `IC50 value`, Group,  TCGA_DESC,  everything())

GSDCIC50 = GSDC3
save(GSDCIC50,file="data_preload/annotation/GSDCIC50.Rdata")

# 计算癌种的出现频次
load("data_preload/annotation/GSDCIC50.Rdata")
disinfo = rio::import("data_preload/annotation/disinfo.txt")
unique_ids <- unique(GSDCIC50$TCGA_DESC)

freq = as.data.frame(table(GSDCIC50$TCGA_DESC)) 
disinfo = left_join(disinfo, freq,by = c("ID"="Var1"))
filtered_disinfo <- disinfo %>% filter(ID %in% unique_ids)
disinfo_vector <- setNames(filtered_disinfo$ID, filtered_disinfo$NAME)

save(disinfo_vector, file = "data_preload/annotation/disinfo_vector.Rdata")
rio::export(filtered_disinfo,file="S1.xlsx")
# load("data_preload/drugexp/LINCS_A375_5 µM_24 h.rdata")
