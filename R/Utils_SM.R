library(memoise)
library(dplyr) # 为了future正常运行使用的
library(tidyr)
library(tidyverse)


local_cache_folder_SM <- cache_filesystem("cache/SM/")

# 主要函数
get_single_method_i  <- function(drug_profile, topn,sel_model_sm1, i.need.logfc, funcname,funcname_mul,
                               direct, bioname1, bioname2){

  print("进入get_single_method_i")
  req(!is.null(drug_profile))
  load(paste0("data_preload/drugexp/",drug_profile))
  
  if(sel_model_sm1 == "singlemethod"){
    
    res_sm <- get_single_res(funcname = funcname,
                             refMatrix = exp_GSE92742,
                             sig_input = i.need.logfc,
                             topn = topn,
                             drug_profile = drug_profile)
    p_sm <- draw_single(res_sm)
  }
  
  if(sel_model_sm1 == "SS_all"){
    
    res_sm <- get_ss_all_res(refMatrix = exp_GSE92742,
                             sig_input = i.need.logfc,
                             funcname_mul = funcname_mul,
                             topn = topn,
                             direct = direct,
                             drug_profile = drug_profile)
    p_sm <- draw_all(res_sm)
    
  }
  
  if(sel_model_sm1 == "SS_cross"){
    # print("SS_corss!")
    
    i.need.logfc1 = i.need.logfc$i.need.logfc1
    i.need.logfc2 = i.need.logfc$i.need.logfc2
    
    res_sm <- get_ss_cross_res(funcname = funcname,
                               refMatrix = exp_GSE92742,
                               sig_input1 = i.need.logfc1,
                               sig_input2 = i.need.logfc2,
                               topn = topn,
                               drug_profile = drug_profile)
    
    p_sm <- draw_cross(res_sm, bioname1=bioname1, 
                       bioname2=bioname2)
    
  }
  
  req(res_sm)
  req(p_sm)
  
  return(list(
    res_sm = res_sm,
    p_sm = p_sm
  ))
}

get_single_res_i <- function(funcname,refMatrix,sig_input,topn, 
                             drug_profile = NULL, threshold = 1){
  
  print("进入get_single_res")
  library(dplyr)
  # print("dplyr加载完毕")
  sig1_up = sig_input %>%
    dplyr::filter(log2FC > threshold) %>%
    dplyr::arrange(desc(log2FC))
  sig1_up = sig1_up$Gene
  
  sig1_dn = sig_input %>%
    dplyr::filter(log2FC < -threshold)%>%
    dplyr::arrange(log2FC)
  sig1_dn = sig1_dn$Gene
  
  if(funcname == "SS_Xsum"){
    
    res_raw <- XSumScore(refMatrix = refMatrix,
                         queryUp = na.omit(sig1_up[1:topn]) ,
                         queryDown = na.omit(sig1_dn[1:topn]),
                         topN = topn)
    
  }
  
  if(funcname == "SS_CMap"){
    res_raw <- KSScore(refMatrix = refMatrix,
                       queryUp = na.omit(sig1_up[1:topn]) ,
                       queryDown = na.omit(sig1_dn[1:topn]))
  }
  
  if(funcname == "SS_GESA"){
    res_raw <- GSEAweight1Score(refMatrix = refMatrix,
                                queryUp = na.omit(sig1_up[1:topn]) ,
                                queryDown = na.omit(sig1_dn[1:topn]))
  }
  
  if(funcname == "SS_ZhangScore"){
    res_raw <- ZhangScore(refMatrix = refMatrix,
                          queryUp = na.omit(sig1_up[1:topn]) ,
                          queryDown = na.omit(sig1_dn[1:topn]))
  }
  
  if(funcname == "SS_XCos"){
    sig_input1 <- sig_input %>% dplyr::filter(log2FC < -threshold) %>% slice_min(log2FC,n=topn)
    sig_input2 <- sig_input %>% dplyr::filter(log2FC > threshold) %>% slice_max(log2FC,n=topn)
    sig_input3 <- rbind(sig_input2,sig_input1)
    sig_input4 <- setNames(sig_input3$log2FC,sig_input3$Gene)
    res_raw <- XCosScore(refMatrix = refMatrix,
                         query = sig_input4,
                         topN = topn)
  }
  
  
  return(get_pval(res_raw = res_raw,
                  drug_profile_null = paste0(drug_profile,"_",funcname,".rdata")))
  
  
  
  # 
  # 
  # 
  # res_raw1 <- get_single_res_m(funcname,refMatrix,sig_input,topn,threshold = 1)
  # res_raw_wq <-  
  # 
  # return(res_raw_wq)
  
} 

get_ss_all_res_i <- function(refMatrix,sig_input,funcname_mul,topn,direct,drug_profile = NULL){
  
  print("进入SS_all")
  res_mul <- purrr::map(funcname_mul,get_single_res,
                        refMatrix = refMatrix,
                        sig_input = sig_input,
                        topn = topn,
                        drug_profile = drug_profile)
  
  get_rra <- function(res_order,funcname_one,direct = "Down",only.name =F){
    
    ll <- data.frame(
      name = res_mul[[res_order]] %>% arrange(desc(abs(Score))) %>%
        dplyr::filter(Direction == direct) %>% select(name) %>% unlist(use.names = F),
      method = funcname_one
    )
    
    if(only.name){
      return(ll[[1]])
    }else{
      return(ll)
    }
  }
  
  # get data frame for summary
  res_mul2 <- purrr::map2_dfr(.x = 1:length(funcname_mul), .y = funcname_mul,
                              .f = get_rra, direct = direct, only.name =F)
  
  # get list for rra
  res_mul3 <- purrr::map2(.x = 1:length(funcname_mul), .y = funcname_mul,
                          .f = get_rra, direct = direct, only.name = T)
  
  summary <- res_mul2 %>% group_by(name) %>%
    summarise(Freq=n(), method = paste(method, collapse = ", ")) %>%
    na.omit() %>% arrange(desc(Freq))
  
  star_rra <- RobustRankAggreg::aggregateRanks(res_mul3)
  star_rra <- cbind(star_rra, "rra_rank" = seq(1,nrow(star_rra)))
  
  summary <- left_join(star_rra, summary, by=c("Name" = "name") )
  # 
  # rio::export(summary,"111.TXT")
  return(summary)
  # }else{
  #   print("at least two methods!")
  # }
  
}

get_ss_cross_res_i <- function(funcname,refMatrix,sig_input1,sig_input2,topn,drug_profile = NULL){
  
  print("进入SS_cross")
  res1 <-  get_single_res(funcname = funcname ,refMatrix = refMatrix,
                          sig_input = sig_input1,topn = topn,drug_profile = drug_profile)
  res2 <-  get_single_res(funcname = funcname ,refMatrix = refMatrix,
                          sig_input = sig_input2,topn = topn,drug_profile = drug_profile)
  
  res_m <- full_join(res1,res2,by="name")
  res_m <- res_m %>% transform(nominal_padj= sqrt(p.adjust.x * p.adjust.y),
                               cal_label = sqrt(abs(Scale_score.x * Scale_score.y)))
  res_m$block <- apply(res_m[,c("Scale_score.x","Scale_score.y")],FUN = add_block,MARGIN=1)
  
  return(res_m)
}

## 尽可能存储缓存，试一试
get_single_method <- memoise::memoise(get_single_method_i,cache = local_cache_folder_SM)
get_single_res <- memoise::memoise(get_single_res_i,cache = local_cache_folder_SM)
get_ss_all_res <- memoise::memoise(get_ss_all_res_i,cache = local_cache_folder_SM)
get_ss_cross_res <- memoise::memoise(get_ss_cross_res_i,cache = local_cache_folder_SM)



get_pval <- function(res_raw, drug_profile_null){
  
  get_pval_inner <- Vectorize(function(drug_name,drug_score){
    
    
    library(RSQLite)
    conn <- dbConnect(RSQLite::SQLite(), "data_preload/nulldistribution/Nulldistribution.db")
    
    drug_null <- tbl(conn,drug_profile_null)  %>%  
      dplyr::filter(drugname == drug_name) %>% collect() %>%
      dplyr::select(-drugname)   %>% unlist(use.names = FALSE)
    
    dbDisconnect(conn)
    
    if(drug_score < 0){
      p.value <- sum(drug_null[[1]]<=drug_score)/length(drug_null[[1]])
    } else {
      p.value <- sum(drug_null[[1]]>=drug_score)/length(drug_null[[1]])
    }
    
    return(p.value)
  })
  
  res_raw <- res_raw %>% tibble::rownames_to_column(var = "name") %>%
    mutate(pvalue = get_pval_inner(name,Score),
           Scale_score = .S(Score),
           Direction = .D(Scale_score))%>%
    arrange(desc(Score))
  
  res_raw$p.adjust = p.adjust(res_raw$pvalue)
  
  return(res_raw)
}


draw_single <- function(data,x = "Scale_score",y = "name",colby = "pvalue",
                        color = c("blue", "red")){
  
  
  data1 = rbind(slice_max(data, Scale_score,
                          n = 10,with_ties = FALSE),
                slice_min(data, Scale_score,
                          n = 10,with_ties = FALSE)) %>% distinct()
  
  score <- data1[, x]
  y <- data1[, y]
  Pval <- data1[, colby]
  p <- ggplot2::ggplot(data1, aes(score, forcats::fct_reorder(y, score))) +
    geom_segment(aes(xend = 0, yend = y), linetype = 2) +
    geom_point(aes(col = -log10(Pval+0.0001) , size = abs(score))) +
    scale_colour_gradientn(colours = color) +
    scale_size_continuous(range = c(2, 6)) +
    ylab(NULL) +
    theme_minimal() +
    theme(panel.background = element_rect(
      colour = "black",
      size = 0.5
    )) +
    labs(
      x = "Scaled Score", y = "Drugs",
      size = "Scaled Score",
      col = colby
    ) + scale_y_discrete(position = "left",labels= function(x) str_wrap(x,width=30))
  return(p)
  
  
}


draw_all <- function(summary){
  sm <-summary %>% as_tibble() %>%
    separate_rows(method, sep = ", ") %>%
    mutate(appear = T) %>%
    spread(key="method", value = "appear") %>%
    arrange(rra_rank)
  sm[is.na(sm)] <- F
  
  # p1 <- ComplexUpset::upset(data = sm,
  #                           intersect = colnames(sm)[5:ncol(sm)])
  
  p2 <- ggplot(sm[order(sm$Score),][1:10,],aes(-1*log10(Score),reorder(Name, dplyr::desc(rra_rank)))) +
    geom_point(aes(size = factor(Freq)  ,color=-1*log10(Score))) +
    scale_color_gradient(low="green",high = "red") + labs(x="-log10(Rank Score)",
                                                          y="",
                                                          title="",
                                                          colour = "-log10(Rank Score)",
                                                          size = "Method")+theme_test() + theme(
                                                            axis.text = element_text(colour = "black")
                                                          )+
    scale_y_discrete(position = "left",labels= function(x) str_wrap(x,width=30))
  
  # p1 / {plot_spacer() + p2 + plot_layout(ncol = 2, width = c(0.1, 2))} #强制对齐
  
  return(p2)
  
  # 建议输出分辨率为3:4可以获得最好的效果
  
  
  
  
}

draw_cross <- function(res_m,bioname1="Biological Process 1", bioname2="Biological Process 2"){
  
  stopifnot(is.character(bioname1) & is.character(bioname2))
  
  # 筛选每个象限排序靠前的化合物
  # for_label2 <- res_m %>% filter(block != "NQ") %>% group_by(block) %>%
  #   slice_max(order_by = cal_label, n = show_n)
  # 
  # 
  # if (show_block %in% c("Q1","Q2","Q3","Q4")){
  #   for_label2 <- for_label2[for_label2$block == show_block,]
  # }
  # 
  cbPalette <- c("#999999", "#F8766D", "#B79F00", "#00BA38", "#00BFC4")
  # show_cap=paste(for_label2$name)
  
  res_m %>%
    ggplot(aes(x=Scale_score.x, y=Scale_score.y)) +
    geom_point(alpha=0.5,aes(color=block)) +theme_test()+ theme(
      axis.title = element_text( face = "bold"),
      axis.text = element_text(colour = "black"),
      legend.title = element_text(),
      legend.text = element_text())+ labs(x = bioname1, y = bioname2)+
    scale_colour_manual(values=cbPalette)+ theme(legend.position="none")
  
}

# 添加分区
add_block <- function(x){
  
  num1 = x[1]
  num2 = x[2]
  if(num1 >0 & num2 >0){
    return("Q1")
  }
  if(num1 <0 & num2 >0){
    return("Q2")
  }
  if(num1 <0 & num2 <0){
    return("Q3")
  }
  if(num1 >0 & num2 <0){
    return("Q4")
  }
  if(num1 ==0 | num2 ==0){
    return("NQ")
  }
}

# 计算联合p值
cal_p <- function(x){
  num1 = x[1]
  num2 = x[2]
  if (num1 ==1 | num2 ==1) {
    return(1)
  } else {
    return(sqrt(num1 * num2))
  }
}

# Function to scale scores
.S <- function(scores) {
  p <- max(scores)
  q <- min(scores)
  ifelse(scores == 0, 0, ifelse(scores > 0, scores / p, -scores / q))
}

# 判断方向
.D <- function(scores) {
  p <- max(scores)
  q <- min(scores)
  ifelse(scores > 0.4, "Up", ifelse(scores < -0.4, "Down", "None"))
}
