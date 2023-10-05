get_rb_plot <- function(dir_rb,func_sel){
  load(dir_rb)
  library(dplyr)
  library(ggplot2)
  library(ggsci)

  
  colnames(res_topn2) <- c("SS_Xsum","SS_CMap","SS_GESA","SS_ZhangScore","SS_XCos","topn")
  

  
  # 所有的得分
  res_topn11 <- res_topn2 %>% tidyr::pivot_longer(data = .,cols = -topn,
                                                  names_to = "Method", 
                                                  values_to = "Rscore") %>% 
    dplyr::filter(Method %in% c(func_sel)) %>% 
    readr::type_convert()
  
  # 选择的方法的得分
  res_topn12 <- res_topn2 %>% tibble::column_to_rownames("topn") %>% 
    dplyr::select(all_of(c(func_sel))) %>% 
    transmute(topn = rownames(.),
              Method = "average",
              Rscore =  rowMeans(select(.,c(func_sel)), na.rm = TRUE)) %>% 
    readr::type_convert()
  
  # 绘图
  ggplot(res_topn11, mapping = aes(x = topn, y = Rscore,color = Method) ) + 
    geom_line(alpha=0.8,size = 2) +  
    geom_line(data = res_topn12, alpha = 1, size = 2, linetype= "dashed") +
    scale_color_nejm(
      name = "Method",
      breaks = c("SS_Xsum","SS_CMap","SS_GESA","SS_ZhangScore","SS_XCos","average"),
      labels = c("Xsum", "CMAP","GSEA","ZhangScore","Cos","Average")
    ) + 
    labs(x= "Number of Genes",y="Robustness")+ theme_test() 
}