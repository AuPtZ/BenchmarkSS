library(data.table)
repurposing_drugs <- read.delim("data_preload/annotation/repurposing_drugs_20200324.txt", 
                                comment.char = "!")
repurposing_samples <- read.delim("data_preload/annotation/repurposing_samples_20200324.txt",
                                  comment.char = "!")

# 从repurposing_drugs筛选disease_area含有onco的列
library(dplyr)
library(stringr)
library(tibble)

repurposing_drugs <- repurposing_drugs %>% tibble() %>%
  filter(str_detect(disease_area, "onco|mali")) %>%
  separate_rows(indication, sep = "\\|")

df = repurposing_drugs %>% 
  dplyr::left_join(repurposing_samples %>%
                     dplyr::select(-broad_id) %>% distinct(),
                   by = "pert_iname") %>% 
  dplyr::select(c(pert_iname,clinical_phase,disease_area,indication,smiles,InChIKey,pubchem_cid)) %>% 
  distinct()

# 相同诊断的情况下，保留第一行
df <- df %>%
  group_by(pert_iname, clinical_phase, disease_area, indication) %>%
  slice(1) %>%
  ungroup()

# 去除非肿瘤的部分
df <- df %>% filter(clinical_phase == "Launched") %>%
  filter(!str_detect(indication, "hypoglycemia|Cushing|anemia|effusion|menopause|mastocytosis|duodenal|GERD|peptic|hypercalcemia|parathy|osteoporosis|atrophy|complex|endometriosis|asthma|colitis|dermatitis|enteritis|nausea|vomiting|cystitis|keratosis|warts|failure|mycosis|polycythemia|hydatidiform|psoriasis|sclerosis|acromegaly|diarrhea|Paget|myelofibrosis|arthritis|dysphoria|hypoestrogenism|puberty|Waldenstrom"))

# 筛选出现次数超过5次的药物
DrugReHub <- df %>%
  group_by(indication) %>%
  filter(n() > 5) %>%
  ungroup()


# 替换名字与GDSC保持一致
name_mapping <- rio::import("data_preload/annotation/name_mapping.txt")


DrugReHub <- DrugReHub %>% left_join(name_mapping,by="indication") %>% 
  dplyr::select(pert_iname,ID,newname, pubchem_cid,smiles,InChIKey) %>% 
  rename( "Compound.name"= "pert_iname",
          "Indication" = "newname",
          "PubChem_Cid" = "pubchem_cid",
          "SMILEs"= "smiles" ,
          "InChIKeys" = "InChIKey"
         )



disinfo_vector2 <- setNames(unique(DrugReHub$ID), unique(DrugReHub$Indication))



freq = as.data.frame(table(DrugReHub$Indication)) %>% left_join(DrugReHub[,c("ID","Indication")] %>% distinct(), by = c("Var1"="Indication"))


rio::export(freq,file = "S2.xlsx")

DrugReHub <- DrugReHub %>% dplyr::select(-Indication)

save(DrugReHub, file = "data_preload/annotation/DrugReHub.Rdata")
save(disinfo_vector2,file = "data_preload/annotation/disinfo_vector2.Rdata")
