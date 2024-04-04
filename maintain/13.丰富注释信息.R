library(dplyr)

drug_GSE92742 = rio::import("data_preload/drugconvertor/GSE92742_Broad_LINCS_pert_info.txt")

drug_GSE92742 <- drug_GSE92742 %>% dplyr::filter(pert_type == "trt_cp") %>% 
  dplyr::select(pert_id,pert_iname,pubchem_cid,inchi_key_prefix,inchi_key,canonical_smiles)

save(drug_GSE92742,file = "data_preload/annotation/drug_GSE92742.Rdata")
