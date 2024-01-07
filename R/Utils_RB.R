get_rb_plot <- function(dir_rb,func_sel){
  load(dir_rb)
  library(dplyr)
  library(ggplot2)
  library(ggsci)

  
  colnames(res_topn2) <- c("SS_Xsum","SS_CMap","SS_GSEA","SS_ZhangScore","SS_XCos","TopN")
  

  
  # 挑选选择的算法的得分
  res_topn11 <- res_topn2 %>% dplyr::select(c('TopN', all_of(func_sel))) %>% 
    dplyr::rename(any_of(rename_col_rules)) %>% 
    tidyr::pivot_longer(data = .,cols = -TopN,
                        names_to = "Method", 
                        values_to = "Score") 
  
  # 选择的方法的平均分
  res_topn12 <- res_topn2 %>% 
    dplyr::transmute(TopN = TopN,
                     Method = "Average",
                     Score = rowMeans(dplyr::select(., -TopN), na.rm = TRUE))
  
  # 绘图
  ggplot(res_topn11, mapping = aes(x = TopN, y = Score,color = Method) ) + 
    geom_line(alpha=0.8,linewidth = 2) +  
    geom_line(data = res_topn12, alpha = 1, linewidth = 2, linetype= "dashed") +
    scale_color_nejm() + 
    labs(x= "TopN",y="Robustness")+ theme_test() 
}