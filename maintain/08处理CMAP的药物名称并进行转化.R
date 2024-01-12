library(rio)
library(dplyr)
CMAP_druginfo <- rio::import("data_preload/drugconvertor/GSE92742_Broad_LINCS_pert_info.txt") %>% 
  dplyr::filter(pert_type == "trt_cp") %>%  
  mutate_all(~ifelse(. == "-666" | . == "restricted", NA, .))  %>%
  dplyr::select(-c(pert_type, is_touchstone)) %>% 
  mutate(net_drug_name = tolower(gsub("[- ]", "", pert_iname)))



test_name = CMAP_druginfo %>% dplyr::select("net_drug_name") %>% drop_na() %>% pull()
test_name[duplicated(test_name)]

test_pubchem = CMAP_druginfo %>% dplyr::select("pubchem_cid") %>% drop_na() %>% pull()
test_pubchem[duplicated(test_pubchem)]

save(CMAP_druginfo,file = "data_preload/drugconvertor/GSE92742_LINCS_drug_info.Rdata")
