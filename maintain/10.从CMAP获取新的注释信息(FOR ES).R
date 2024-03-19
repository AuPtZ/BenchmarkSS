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
df <- df %>% 
  filter(!str_detect(indication, "hypoglycemia|Cushing|anemia|effusion|menopause|mastocytosis|duodenal|GERD|peptic|hypercalcemia|parathy|osteoporosis|atrophy|complex|endometriosis|asthma|colitis|dermatitis|enteritis|nausea|vomiting|cystitis|keratosis|warts|failure|mycosis|polycythemia|hydatidiform|psoriasis|sclerosis|acromegaly|diarrhea|Paget|myelofibrosis|arthritis|dysphoria|hypoestrogenism|puberty|Waldenstrom"))


