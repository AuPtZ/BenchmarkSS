get_rb_plot <- function(dir_rb,func_sel){
  load(dir_rb)
  library(dplyr)
  library(ggplot2)
  library(ggsci)

  
  colnames(res_topn2) <- c("SS_Xsum","SS_CMap","SS_GSEA","SS_ZhangScore","SS_XCos","TopN")
  
  res_rb <- res_topn2 %>% dplyr::select(c('TopN', all_of(func_sel))) %>%
    mutate_at(vars(-1), round, digits = 4) %>%
    dplyr::rename(any_of(rename_col_rules))
  
  # 找到整个表格中最大值所在的列的列名
  max_col_name <- colnames(res_rb[-1])[which(res_rb[-1] == max(res_rb[-1], na.rm = TRUE), arr.ind = TRUE)[1, "col"]]
  
  # 按照该列从大到小排序
  res_rb <- res_rb %>% dplyr::arrange(desc(!!rlang::sym(max_col_name)))
  
  save(res_rb,file = "rb.rdata")
  print("yes, i get!")
  
  first_row_value <- res_rb[1,1] %>% as_tibble() %>% pull()
  
  # 挑选选择的算法的得分
  res_topn11 <- res_rb %>%
    tidyr::pivot_longer(data = .,cols = -TopN,
                        names_to = "Method", 
                        values_to = "Score") %>% 
    dplyr::mutate(Score = round(Score,4))
  
  # 选择的方法的平均分
  res_topn12 <- res_rb %>% 
    dplyr::transmute(TopN = TopN,
                     Method = "Average",
                     Score = round(rowMeans(dplyr::select(., -TopN), na.rm = TRUE),4)
                     )
  
  
  
  # 绘图
  pic_out <- ggplot(res_topn11, mapping = aes(x = TopN, y = Score,color = Method) ) + 
    geom_line(alpha=0.8,linewidth = 2) +  
    geom_line(data = res_topn12, alpha = 1, linewidth = 2, linetype= "dashed") +
    geom_vline(xintercept = first_row_value, linetype="dashed", color = "black") + 
    scale_color_nejm() + 
    labs(x= "TopN",y="Robustness")+ theme_test() 


    
  

  
  print("输出结果啦！")
  return(list(pic_out = pic_out,res_rb = res_rb))
  
}