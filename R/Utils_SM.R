library(memoise)
library(dplyr) # 为了future正常运行使用的
library(tidyr)
library(tidyverse)


local_cache_folder_SM <- cache_filesystem("cache/SM/")

# 主要函数
get_single_method_i  <- function(drug_profile, topn,sel_model_sm1, i.need.logfc, funcname,funcname_mul,
                               direct, bioname1, bioname2){

  # print("进入get_single_method_i")
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
  
  # print("进入get_single_res")
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
  
  if(funcname == "SS_GSEA"){
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
  
  res_raw <- res_raw %>% dplyr::arrange(desc(abs(Score)))
  
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
  
  # print("进入SS_all")
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
  
  # save(res_mul, res_mul2,res_mul3,rename_col_rules,file="1.rdata")
  summary <- res_mul2 %>% mutate(method = case_when(
    method == "SS_Xsum" ~ "XSum",
    method == "SS_CMap" ~ "CMap",
    method == "SS_GSEA" ~ "GSEA",
    method == "SS_ZhangScore"~"ZhangScore",
    method == "SS_XCos" ~ "XCos",
    TRUE ~ as.character(method)  # 如果都不匹配，保持原样
  )) %>%
    group_by(name) %>%
    summarise(Freq=n(), method = paste(method, collapse = ", ")) %>%
    na.omit() %>% arrange(desc(Freq))
  
  star_rra <- RobustRankAggreg::aggregateRanks(res_mul3)
  # star_rra <- cbind(star_rra, "rra_rank" = seq(1,nrow(star_rra)))
  
  summary <- left_join(star_rra, summary, by=c("Name" = "name") )
  summary$Score <- -log2(summary$Score)
  # 
  # rio::export(summary,"111.TXT")
  return(summary %>% mutate_if(is.numeric, round, digits = 10))
  # }else{
  #   print("at least two methods!")
  # }
  
}

get_ss_cross_res_i <- function(funcname,refMatrix,sig_input1,sig_input2,topn,drug_profile = NULL){
  
  # print("进入SS_cross")
  res1 <-  get_single_res(funcname = funcname ,refMatrix = refMatrix,
                          sig_input = sig_input1,topn = topn,drug_profile = drug_profile)
  res2 <-  get_single_res(funcname = funcname ,refMatrix = refMatrix,
                          sig_input = sig_input2,topn = topn,drug_profile = drug_profile)
  
  res_m <- full_join(res1,res2,by="name")
  res_m <- res_m %>% transform(nominal_padj= sqrt(p.adjust.x * p.adjust.y),
                               cal_label = sqrt(abs(Scale_score.x * Scale_score.y)))
  res_m$block <- apply(res_m[,c("Scale_score.x","Scale_score.y")],FUN = add_block,MARGIN=1)
  
  # save(res_m, file = "res_m.rdata")
  
  res_m <- res_m %>% 
    dplyr::select(name,cal_label, nominal_padj, block, Scale_score.x,Scale_score.y) %>% 
    dplyr::arrange(desc(cal_label)) %>% mutate_if(is.numeric, round, digits = 4)
  
  return(res_m)
}

## 尽可能存储缓存，试一试
get_single_method <- memoise::memoise(get_single_method_i,cache = local_cache_folder_SM)
get_single_res <- memoise::memoise(get_single_res_i,cache = local_cache_folder_SM)
get_ss_all_res <- memoise::memoise(get_ss_all_res_i,cache = local_cache_folder_SM)
get_ss_cross_res <- memoise::memoise(get_ss_cross_res_i,cache = local_cache_folder_SM)



get_pval <- function(res_raw, drug_profile_null){
  
  library(RSQLite)
  conn <- dbConnect(RSQLite::SQLite(), "data_preload/nulldistribution/Nulldistribution.db")
  
  nulldistribution <- tbl(conn,drug_profile_null) %>% 
    as_tibble() %>% 
    rename_with(~make.names(., unique = TRUE))
  # nulldistribution <- nulldistribution %>% rename( "Score"= "Score.0")
  res_raw <- res_raw %>% rownames_to_column(var = "drugname")  %>% 
    inner_join(nulldistribution, by = "drugname") %>%
    rowwise() %>% 
    transmute(name = drugname, 
              Score,
              pvalue = mean(abs(c_across(starts_with("X"))) >= abs(Score))
              )
  # transmute直接使用p.adjust只是对单个pvalue值进行计算，因此需要运行后再计算p.adjust
  res_raw$Scale_score = .S(res_raw$Score)
  res_raw$Direction = .D(res_raw$Scale_score)
  res_raw$p.adjust = p.adjust(res_raw$pvalue)
  
  return(res_raw %>% mutate_if(is.numeric, round, digits = 4))
}


draw_single <- function(data){
  
  # save(data,file = "data.rdata")
  data = as.data.frame(data)
  data1 = rbind(slice_max(data, Scale_score,
                          n = 10,with_ties = FALSE),
                slice_min(data, Scale_score,
                          n = 10,with_ties = FALSE)) %>% #  distinct() %>%
  mutate(name = factor(name, levels = name[order(Scale_score)]),
         logP = -log10(pvalue+0.0001),
         tooltip_text = paste("Name:", name, 
                               "<br>Scale_score:", round(Scale_score, 2), 
                               "<br>logP:", round(logP, 2))
         )



  
  p1 <- ggplot2::ggplot(data1, aes(x = Scale_score, y = name,xend = 0, yend = name, text =tooltip_text )) +
    geom_segment(linetype = 2) +
    geom_point(aes(col = logP , size = abs(Scale_score))) +
    scale_colour_gradientn(colors = c("blue", "red")) +
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
      col = "logP"
    ) + scale_y_discrete(position = "left",labels= function(x) str_wrap(x,width=30))
  
  # 使用plotly::ggplotly转换p，并指定tooltip参数
  plotly_p1 <- plotly::ggplotly(p1, tooltip = "text") # 使用text作为工具提示
  
  return(plotly_p1)



}





draw_all <- function(sm){

  # 首先，对sm数据进行排序并选取前10个记录
  sm_sorted <- sm[order(sm$Score, decreasing = T), ][1:10, ]
  
  # 对Name进行基于rra_rank的重新排序
  sm_sorted$Name <- factor(sm_sorted$Name, levels = sm_sorted$Name[order(sm_sorted$Score)])
  
  sm_sorted$Freq <- factor(sm_sorted$Freq)
  
  sm_sorted$tooltip_text <- paste("Name:", sm_sorted$Name, 
                              "<br>Score:", round(sm_sorted$Score, 2), 
                              "<br>Freq:", sm_sorted$Freq)
  
  p2 <- ggplot(sm_sorted,aes(x = Score, y = Name, size = Freq,color=Score , text = tooltip_text)) +
    geom_point() +
    scale_color_gradient(low="green",high = "red") + labs(x="Score",
                                                          y=NULL,
                                                          title=NULL,
                                                          colour = "Score",
                                                          size = "Method")+theme_test() + theme(
                                                            axis.text = element_text(colour = "black")
                                                          )+
    scale_y_discrete(position = "left",labels= function(x) str_wrap(x,width=30))
  
  # 使用plotly::ggplotly转换p，并指定tooltip参数
  plotly_p2 <- plotly::ggplotly(p2, tooltip = "text") # 使用text作为工具提示
  
  return(plotly_p2)
  
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
  
  res_m$tooltip_text <- paste("Name:", res_m$name, 
                              "<br>Scale_score.x:", round(res_m$Scale_score.x, 2), 
                              "<br>Scale_score.y:", round(res_m$Scale_score.y, 2))
  
  p3 <- res_m %>% 
    ggplot(aes(x=Scale_score.x, y=Scale_score.y,color=block,text=tooltip_text)) +
    geom_point(alpha=0.5) +theme_test()+ theme(
      axis.title = element_text( face = "bold"),
      axis.text = element_text(colour = "black"),
      legend.title = element_text(),
      legend.text = element_text())+ labs(x = bioname1, y = bioname2)+
    scale_colour_manual(values=cbPalette)+ theme(legend.position="none")
  
  # 使用plotly::ggplotly转换p，并指定tooltip参数
  plotly_p3 <- plotly::ggplotly(p3, tooltip = "text") # 使用text作为工具提示
  
  return(plotly_p3)
  
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
