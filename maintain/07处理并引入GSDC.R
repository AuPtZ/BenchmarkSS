# 为了review，我们新增了从pubchem获取CSDC药物结构的部分：
library(rio)
library(dplyr)
library(webchem)

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

save(GSDC_drug_info,file = "data_preload/annotation/GSDC_drug_info_full.Rdata")


load("data_preload/annotation/GSDC_drug_info_full.Rdata")
# 处理GSDC数据库的IC50数据，
GSDC_drug_info2 = GSDC_drug_info %>% dplyr::select(c("Name","PubCHEM","SMILEs", "InChIKeys")) %>% distinct()
# 筛选名字重复但是pubchemcid不重复的
GSDC_drug_info2$Name[duplicated(GSDC_drug_info2$Name)]
# 人工查阅，保留唯一值
# MIM1 CID 135691163 API搜索获得的，非原始 删除
# BMS-345541 CID 9926054 多了一个盐酸 删除
# Cisplatin CID 5702198 API搜索获得的，非原始 删除
# Oxaliplatin CID 9887053 API搜索获得的，非原始 删除
GSDC_drug_info3 <- GSDC_drug_info2[!GSDC_drug_info2$PubCHEM %in% c("135691163","9926054","5702198","9887053"),]

GSDC <- rio::import("data_preload/annotation/GDSC2_fitted_dose_response_24Jul22.xlsx") %>% 
  dplyr::select(c("TCGA_DESC","DRUG_NAME", "LN_IC50")) %>% distinct() %>% 
  left_join(GSDC_drug_info3, by=c("DRUG_NAME"="Name")) %>% distinct()

GSDC2 <- GSDC %>%
  dplyr::filter(TCGA_DESC != "UNCLASSIFIED", TCGA_DESC != "OTHER") %>%
  dplyr::select(c(DRUG_NAME, LN_IC50, TCGA_DESC, PubCHEM, SMILEs,InChIKeys)) %>%
  mutate(IC50 = 2^LN_IC50) %>%
  dplyr::select(-LN_IC50)

GSDC3 <- GSDC2 %>%
  group_by(DRUG_NAME,  TCGA_DESC,PubCHEM, SMILEs,InChIKeys) %>%
  summarize(IC50 = min(IC50)) %>% 
  dplyr::rename(Compound.name = DRUG_NAME, `IC50 value` = IC50, PubChem_Cid = PubCHEM) %>%
  dplyr::mutate(Group = if_else(`IC50 value` > 10, "Ineffective", "Effective")) %>% 
  dplyr::select(Compound.name, `IC50 value`, Group,  TCGA_DESC,  everything())


# 取一下交集,确保药品都在CMAP当中，不然没有意义
load("data_preload/drugconvertor/GSE92742_LINCS_drug_info.Rdata")

# 先汇总GSDC3中PubChem_Cid，SMILEs，InChIKeys与CMAP_druginfo对应的pubchem_cid，canonical_smiles，inchi_key相同的行
GSDC3_combined <- bind_rows(
  GSDC3[GSDC3$PubChem_Cid %in% na.omit(unique(CMAP_druginfo$pubchem_cid)),],
  GSDC3[GSDC3$SMILEs %in% na.omit(unique(CMAP_druginfo$canonical_smiles)),],
  GSDC3[GSDC3$InChIKeys %in% na.omit(unique(CMAP_druginfo$inchi_key)),]
) %>% distinct()

# 然后替换名字即可
GSDC3_combined2 <- bind_rows(
  GSDC3_combined %>%
    inner_join(CMAP_druginfo, by = c("PubChem_Cid" = "pubchem_cid")) %>% 
    mutate(Compound.name = pert_iname) %>% dplyr::select(colnames(GSDC3)) %>% distinct(),
  GSDC3_combined %>%
    inner_join(CMAP_druginfo, by = c("SMILEs" = "canonical_smiles")) %>% 
    mutate(Compound.name = pert_iname) %>% dplyr::select(colnames(GSDC3)) %>% distinct(),
  GSDC3_combined %>%
    inner_join(CMAP_druginfo, by = c("InChIKeys" = "inchi_key")) %>% 
    mutate(Compound.name = pert_iname) %>% dplyr::select(colnames(GSDC3)) %>% distinct()
) %>% distinct()

GSDCIC50 = bind_rows(GSDC3_combined2, GSDC3 %>% dplyr::filter(!(PubChem_Cid %in% unique(GSDC3_combined2$PubChem_Cid))) )
save(GSDCIC50,file="data_preload/annotation/GSDCIC50_update.Rdata")

# 计算癌种的出现频次
load("data_preload/annotation/GSDCIC50_update.Rdata")
disinfo = rio::import("data_preload/annotation/disinfo.txt")
unique_ids <- unique(GSDCIC50$TCGA_DESC)

freq = as.data.frame(table(GSDCIC50$TCGA_DESC))
disinfo = left_join(disinfo, freq,by = c("ID"="Var1"))
filtered_disinfo <- disinfo %>% filter(ID %in% unique_ids)
disinfo_vector <- setNames(filtered_disinfo$ID, filtered_disinfo$NAME)
# 
save(disinfo_vector, file = "data_preload/annotation/disinfo_vector.Rdata")
rio::export(filtered_disinfo,file="S1.xlsx")

