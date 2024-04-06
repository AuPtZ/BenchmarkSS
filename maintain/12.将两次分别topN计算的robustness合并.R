library(parallel)
library(dplyr)
library(tidyr)

# 设置并行环境的核心数，通常设置为可用核心数减一
no_cores <- 32L

# 首先获取tmp的文件列表，定义输入和输出的内容
input_dir = "~/rprojects/SSP/data_preload/robustness/tmp_files"
output_dir = "~/rprojects/SSP/data_preload/robustness"

# 读取tmp的文件
file_list <- list.files(input_dir)

# 基于最后一个_以及最后一个.拆分成表格
split_file_list <- lapply(file_list, function(x) {
  # 使用正则表达式找到最后一个_和最后一个.的位置
  parts <- unlist(strsplit(x, "(?<=.)_(?=.*\\.)|\\.(?=[^.]*$)", perl = TRUE))
  
  # 拆分为所需的三部分
  file_base <- paste(parts[1:(length(parts)-2)], collapse = "_")
  number <- parts[length(parts)-1]
  extension <- parts[length(parts)]
  
  # 返回拆分后的部分
  list(file_base = file_base, number = number, extension = extension)
})

# 将列表转换为数据框
file_list_df <- do.call(rbind, lapply(split_file_list, as.data.frame, stringsAsFactors = FALSE))
rownames(file_list_df) <- NULL # 清除行名
colnames(file_list_df) <- c("PTD", "topn", "extension")
file_list_df <- file_list_df %>% dplyr::mutate(filename = paste0(PTD,"_",topn,".",extension ))

# 摘取09中的计算函数
get_rb_lite <- function(filename,topn){
  load(filename)
  res <- res1 %>% 
    dplyr::summarise(xsum =  cor(input_id,Xsum1) * mean(Xsum2) / sd(Xsum2) ,
                     cmap = cor(input_id,CMap1) * mean(CMap2) / sd(CMap2) ,
                     gsea = cor(input_id,GSEA1) * mean(GSEA2) / sd(GSEA2) ,
                     zhangscore = cor(input_id,ZhangScore1) * mean(ZhangScore2) / sd(ZhangScore2) ,
                     cos = cor(input_id,Cos1) * mean(Cos2) / sd(Cos2)) %>% 
    dplyr::mutate(topn = topn)
  # print(topn)
  return(res)
}

PTD_list = unique(file_list_df$PTD)

for (i in PTD_list){
  filenames <- file_list_df %>% dplyr::filter(PTD %in% i) %>% pull(filename)
  topns <- file_list_df %>% dplyr::filter(PTD %in% i) %>% pull(topn)
  
  combined_results <- mclapply(seq_along(filenames), function(j) {
    result <- get_rb_lite( paste0(input_dir, "/" ,filenames[j]) , as.numeric(topns[j]))
    return(result)
  }, mc.cores = no_cores)
  
  res_topn2 <- do.call(rbind, combined_results)
  
  save(res_topn2,file = paste0(output_dir,"/",i))
  print(i)
}





