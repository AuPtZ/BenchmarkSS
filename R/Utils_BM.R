library(memoise)
library(pROC)
library(ggplot2)

local_cache_folder_BM <- cache_filesystem("cache/BM/")

get_auc_all_i <- function(topn=5,refMatrix,sig_input,IC50_drug,get_ss){
  # print("get_auc_all_i is using")
  sig1_up = sig_input %>%
    dplyr::filter(log2FC > 0) %>%
    dplyr::arrange(desc(log2FC))
  sig1_up = sig1_up$Gene
  
  sig1_dn = sig_input %>%
    dplyr::filter(log2FC < 0)%>%
    dplyr::arrange(log2FC)
  sig1_dn = sig1_dn$Gene
  
  
  
  res_dr_auc <- list(topn=topn)
  
  # method function
  if ("SS_Xsum" %in% get_ss){
    res_xsum_raw <- XSumScore(refMatrix,
                              queryUp = na.omit(sig1_up[1:topn]) ,
                              queryDown = na.omit(sig1_dn[1:topn]),
                              topN = nrow(refMatrix)/2)
    res_xsum_roc <- res_xsum_raw %>% process_raw1(drug_info = IC50_drug)
    auc_xsum <- as.numeric(res_xsum_roc$auc)/100
    res_dr_auc[["auc_xsum"]] <- auc_xsum
    
  } 
  
  if ("SS_CMap" %in% get_ss){
    res_ks_raw <- KSScore(refMatrix,
                          queryUp = na.omit(sig1_up[1:topn]) ,
                          queryDown = na.omit(sig1_dn[1:topn]))
    res_ks_roc <- res_ks_raw %>% process_raw1(drug_info = IC50_drug)
    auc_ks <- as.numeric(res_ks_roc$auc)/100
    res_dr_auc[["auc_ks"]] <- auc_ks
    
  }
  
  if ("SS_GSEA" %in% get_ss){
    res_gs_raw <- GSEAweight1Score(refMatrix,
                                   queryUp = na.omit(sig1_up[1:topn]) ,
                                   queryDown = na.omit(sig1_dn[1:topn]))
    res_gs_roc <- res_gs_raw %>% process_raw1(drug_info = IC50_drug)
    auc_gs <- as.numeric(res_gs_roc$auc)/100
    res_dr_auc[["auc_gs"]] <- auc_gs
    
  }
  if ("SS_ZhangScore" %in% get_ss){
    res_zh_raw <- ZhangScore(refMatrix,
                             queryUp = na.omit(sig1_up[1:topn]) ,
                             queryDown = na.omit(sig1_dn[1:topn]))
    res_zh_roc <- res_zh_raw %>% process_raw1(drug_info = IC50_drug)
    auc_zh <- as.numeric(res_zh_roc$auc)/100
    res_dr_auc[["auc_zh"]] <- auc_zh
    
  }
  if ("SS_XCos" %in% get_ss){
    sig_input1 <- sig_input %>% dplyr::filter(log2FC<0) %>% slice_min(log2FC,n = topn)
    sig_input2 <- sig_input %>% dplyr::filter(log2FC>0) %>% slice_max(log2FC,n = topn)
    sig_input3 <- rbind(sig_input2,sig_input1)
    sig_input4 <- setNames(sig_input3$log2FC,sig_input3$Gene)
    res_cos_raw <- XCosScore(refMatrix,
                             query = sig_input4,
                             topN = nrow(refMatrix)/2)
    res_cos_roc <- res_cos_raw %>% process_raw1(drug_info = IC50_drug)
    auc_cos <- as.numeric(res_cos_roc$auc)/100
    res_dr_auc[["auc_cos"]] <- auc_cos
    
  }
  
  # gc()
  # print(paste0("AUC ",topn))
  return(res_dr_auc %>% lapply(round,4))
}

get_es_all_i <- function(topn=5,refMatrix,sig_input,drug_sig,get_ss){
  # print("get_es_all_i is using")
  sig1_up = sig_input %>%
    dplyr::filter(log2FC > 0) %>%
    dplyr::arrange(desc(log2FC))
  sig1_up = sig1_up$Gene
  
  sig1_dn = sig_input %>%
    dplyr::filter(log2FC < 0)%>%
    dplyr::arrange(log2FC)
  sig1_dn = sig1_dn$Gene
  
  res_dr_es <- list(topn=topn)
  
  # method function
  if ("SS_Xsum" %in% get_ss){
    res_xsum_raw <- XSumScore(refMatrix,
                              queryUp = na.omit(sig1_up[1:topn]) ,
                              queryDown = na.omit(sig1_dn[1:topn]),
                              topN = nrow(refMatrix)/2)
    
    es_xsum <- process_raw2(res_ss_list = setNames(res_xsum_raw[ ,1],rownames(res_xsum_raw)),drug_sig_input = drug_sig)
    
    res_dr_es[["es_xsum"]] <- es_xsum
    
    # rm(res_xsum_raw)
    # rm(es_xsum)
    
  }
  
  
  if ("SS_CMap" %in% get_ss){
    res_ks_raw <- KSScore(refMatrix,
                          queryUp = na.omit(sig1_up[1:topn]) ,
                          queryDown = na.omit(sig1_dn[1:topn]))
    
    es_ks <- process_raw2(res_ss_list = setNames(res_ks_raw[ ,1],rownames(res_ks_raw)),drug_sig_input = drug_sig)
    
    res_dr_es[["es_ks"]] <- es_ks
    
    # rm(res_ks_raw)
    # rm(es_ks)
    
  }
  
  if ("SS_GSEA" %in% get_ss){
    res_gs_raw <- GSEAweight1Score(refMatrix,
                                   queryUp = na.omit(sig1_up[1:topn]) ,
                                   queryDown = na.omit(sig1_dn[1:topn]))
    es_gs <- process_raw2(res_ss_list = setNames(res_gs_raw[ ,1],rownames(res_gs_raw)),drug_sig_input = drug_sig)
    res_dr_es[["es_gs"]] <- es_gs
    
    # rm(res_gs_raw)
    # rm(es_gs)
    
  }
  
  if ("SS_ZhangScore" %in% get_ss){
    res_zh_raw <- ZhangScore(refMatrix,
                             queryUp = na.omit(sig1_up[1:topn]) ,
                             queryDown = na.omit(sig1_dn[1:topn]))
    es_zh <- process_raw2(res_ss_list = setNames(res_zh_raw[ ,1],rownames(res_zh_raw)),drug_sig_input = drug_sig)
    res_dr_es[["es_zh"]] <- es_zh
    
    # rm(res_zh_raw)
    # rm(es_zh)
    
  }
  
  if ("SS_XCos" %in% get_ss){
    sig_input1 <- sig_input %>% dplyr::filter(log2FC<0) %>% slice_min(log2FC,n = topn)
    sig_input2 <- sig_input %>% dplyr::filter(log2FC>0) %>% slice_max(log2FC,n = topn)
    sig_input3 <- rbind(sig_input2,sig_input1)
    sig_input4 <- setNames(sig_input3$log2FC,sig_input3$Gene)
    res_cos_raw <- XCosScore(refMatrix,
                             query = sig_input4,
                             topN = nrow(refMatrix)/2)
    es_cos <- process_raw2(res_ss_list = setNames(res_cos_raw[ ,1],rownames(res_cos_raw)),drug_sig_input = drug_sig)
    res_dr_es[["es_cos"]] <- es_cos
    
  }
  
  # print(paste0("ES ",topn))
  return( res_dr_es %>% lapply(round,4) )
  
}

get_benchmark_i <- function(IC50_drug,FDA_drug, i.need.logfc ,sel_exp,sel_ss){
  
  # print("进入get_benchmark_i")
  cores = get_cores()
  # i.need.logfc <- rio::import(dir_sig)
  ###################
  ### AUC part
  ###################
  if(!is.null(IC50_drug)){

    res_ic50 <- get_dr_auc(IC50_drug = IC50_drug,
                           i.need.logfc = i.need.logfc,
                           sel_exp = sel_exp,
                           sel_ss = sel_ss,
                           cores = cores) %>% rename(any_of(rename_col_rules))
    
    if(is.null(FDA_drug)){
      
      return(
        list(patch_output =res_ic50,
             label_output = "AUC")
      )
    }
    
  }
  ## AUC end
  
  ###################
  ### ES part
  ###################
  if(!is.null(FDA_drug)){

    res_fda <- get_dr_es(FDA_drug = FDA_drug,
                         i.need.logfc = i.need.logfc,
                         sel_exp = sel_exp,
                         sel_ss = sel_ss,
                         cores = cores) %>% rename(any_of(rename_col_rules))
    
    if(is.null(IC50_drug)){
      
      # incProgress(10/n, detail = "DR ES Job finished!")
      return(
        list(patch_output = res_fda,
             label_output = "ES")
      )
      
    }
    # else{
    #   pp <-  get_dr_es()
    #   # patch_es_sum = get_dr_es()[["patch_es_sum"]]
    #   # p2 = res_dr_auc[["p2"]]
    # }
  }
  ### ES end
  
  # both exist
  if(!is.null(FDA_drug) & !is.null(IC50_drug)){
    # incProgress(10/n, detail = "Job finished!")
    return(
      list(patch_output_auc = res_ic50,
           patch_output_es = res_fda,
           label_output = "ALL")
    )
  }
  
  # })
  
}

get_dr_auc_i <- function(IC50_drug,i.need.logfc,sel_exp,sel_ss,cores){
  
  
  load(paste0("data_preload/drugexp/",sel_exp))
  
  IC50_GSE92742 <- exp_GSE92742[, colnames(exp_GSE92742) %in% IC50_drug$`Compound.name`]
  
  patch_auc_sum <- parallel::mclapply(seq(from=100, to=489, by=1),
                                      get_auc_all,
                                      refMatrix = IC50_GSE92742,
                                      sig_input = i.need.logfc,
                                      IC50_drug = IC50_drug,
                                      get_ss = sel_ss,
                                      mc.cores = cores)
  
  patch_auc_sum <- do.call(rbind, patch_auc_sum) %>% tibble::as_tibble() %>% 
    dplyr::transmute( across(where(is.list),unlist )) 
  
  return(patch_auc_sum)
  
}

get_dr_es_i <- function(FDA_drug, i.need.logfc, sel_exp,sel_ss,cores){
  
  
  load(paste0("data_preload/drugexp/",sel_exp))
  
  patch_es_sum <- parallel::mclapply(seq(from=100, to=489, by=1),
                                     get_es_all,
                                     refMatrix = exp_GSE92742,
                                     sig_input = i.need.logfc,
                                     drug_sig = FDA_drug$`Compound.name`,
                                     get_ss = sel_ss,
                                     mc.cores = cores)
  
  
  patch_es_sum <- do.call(rbind, patch_es_sum) %>% tibble::as_tibble() %>% 
    dplyr::transmute( across(where(is.list),unlist )) 
  
  return(patch_es_sum)
} 


get_auc_all <- memoise::memoise(get_auc_all_i,cache = local_cache_folder_BM)
get_es_all <- memoise::memoise(get_es_all_i,cache = local_cache_folder_BM)
get_benchmark <- memoise::memoise(get_benchmark_i,cache = local_cache_folder_BM)
get_dr_auc <- memoise::memoise(get_dr_auc_i,cache = local_cache_folder_BM)
get_dr_es <- memoise::memoise(get_dr_es_i,cache = local_cache_folder_BM)


process_raw1 <- function(res_ss_raw,drug_info){
  res_ss <- res_ss_raw %>% rownames_to_column(var= "pert_iname") %>%
    left_join(drug_info,by = c("pert_iname" = "Compound.name")) %>% 
    dplyr::select(c("pert_iname","Group","Score")) %>% 
    distinct(pert_iname, .keep_all = T) %>%
    column_to_rownames(var="pert_iname") %>%
    mutate(Group=factor(Group,level=c("Ineffective","Effevtive")))
  roc1 <- roc(Group ~ Score, res_ss,
              percent=TRUE,
              ci=FALSE,
              plot=FALSE,
              print.auc=TRUE,
              direction = ">",
              quiet = TRUE)
  return(roc1)
}

process_raw2 <- function(res_ss_list,drug_sig_input){
  res_drug1 <- gsea1(reflist = sort(res_ss_list,decreasing = T),
                     set = drug_sig_input)
  return(res_drug1)
}

gsea1 <- function(reflist, set, w=1) {
  
  
  # Get elements in set that are in the ref list
  set <- intersect(names(reflist), set)
  
  # Sort the reference list
  # Get the list order, from higher (1)to smaller (n)
  ix <- order(reflist, decreasing=TRUE)
  reflist <- reflist[ix] # Reorder the reference list
  
  # Initialize variables for running sum
  es <- 0
  nes <- 0
  p.value <- 1
  
  # Identify indexes of set within the sorted reference list
  inSet <- rep(0, length(reflist))
  inSet[which(names(reflist) %in% set)] <- 1
  
  ### Compute Enrichment Score
  # Compute running sum for hits
  hits<-abs(reflist*inSet) # Get the values for the elements in the set
  hits<-hits^w # Raise this score to the power of w
  score_hit <- cumsum(hits) # Cumulative sum of hits' scores
  # The cumulative sum is divided by the final  sum value
  score_hit <- score_hit / score_hit[length(score_hit)]
  
  # Compute running sum for non-hits
  score_miss <- cumsum(1-inSet)
  score_miss <- score_miss/score_miss[length(score_miss)]
  
  # The Running Score is the difference between the two scores! Hits - nonhits
  running_score <- score_hit - score_miss
  
  # Safety measure, in the case the random genes have all a weight of 0
  if(all(is.na(running_score))){
    running_score<-rep(0,length(running_score))
  }
  
  # The ES is actually the minimum or maximum Running Scores
  if(abs(max(running_score))>abs(min(running_score))){
    es<-max(running_score)
  } else {
    es<-min(running_score)
  }
  
  return(es)
}



draw_dr_auc <- function(res_input){
  
  res_auc <- res_input %>%  as_tibble() %>% pivot_longer(
    cols = -TopN,
    names_to = "method",
    values_to = "AUC") %>% as_tibble() %>%
    mutate(`AUC` = as.numeric(`AUC`),
           `TopN` =as.numeric(`TopN`))
  
  p1 <- ggplot(data=res_auc, mapping = aes(x=TopN, y=`AUC`)) +
    geom_point(aes(color = method)) +
    stat_smooth(aes(color = method),
                #method = MASS::rlm,
                method = "lm",formula=y~I(x^(-1)),
    ) +  theme_test() + ggsci::scale_color_npg()
  
  return(p1)
}

draw_dr_es <- function(res_input){
  res_es <- res_input %>% as_tibble() %>% pivot_longer(
    cols = -TopN,
    names_to = "method",
    values_to = "ES") %>% as_tibble() %>%
    mutate(`ES` = as.numeric(`ES`),
           `TopN` =as.numeric(`TopN`))
  
  p2 <- ggplot(data=res_es, mapping = aes(x=TopN, y=`ES`)) +
    geom_point(aes(color = method)) +
    stat_smooth(aes(color = method),
                #method = MASS::rlm,
                method = "lm",formula=y~I(x^(-0.5)),
    ) + theme_test() + ggsci::scale_color_npg()
  return(p2)
}