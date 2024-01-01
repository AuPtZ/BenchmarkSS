## get drugexp info

profile_list <- list.files("data_preload/drugexp/")
get_drug_num <- function(profile_dir){
  load(paste0("data_preload/drugexp/",profile_dir))
  drug_num <- ncol(exp_GSE92742)
  rm(exp_GSE92742)
  rm(sig_GSE92742)
  
  profile_dir1 <- gsub(".rdata","",profile_dir)
  profile_dir1 <- gsub(" ","",profile_dir1)
  profile_dir1 <- gsub("_"," ",profile_dir1)
  profile_dir1 <- paste0(profile_dir1," (",drug_num," drugs)")
  
  gc()
  return(list(profile_dir= profile_dir,
              profile_name = profile_dir1,
              drug_num = drug_num))
}
drug_num_list <-  purrr::map_dfr(profile_list, get_drug_num) 
drug_num_list1 <- setNames(drug_num_list$profile_dir, drug_num_list$profile_name)

save(drug_num_list,file="data_preload/others/drug_num_list.rdata")
save(drug_num_list1,file="data_preload/others/drug_num_list1.rdata")
