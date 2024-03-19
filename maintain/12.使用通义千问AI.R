library(reticulate)
library(dplyr)

use_condaenv("~/miniconda3/envs/pachong/bin/python3.8")
source_python("~/rprojects/SSP/maintain/12.使用通义千问api.py")

dblist <- rio::import("~/rprojects/SSP/data_preload/annotation/DBfile.xlsx") %>% as.data.frame()

# 初始化一个空的列表来存储结果
disease_results <- vector("list", length = nrow(dblist))

# 对Indication列进行迭代处理
for (i in seq_along(dblist$Indication)) {
  # 调用函数并保存结果
  disease_results[[i]] <- call_with_messages(dblist$Indication[i])
  
  # 每调用一次函数后打印一条消息
  cat("Processed", i, "of", nrow(dblist), "\n")
  
  Sys.sleep(2)
}

# 将列表转换为向量
disease_results <- unlist(disease_results)

# 将结果添加到新列Disease
dblist$Disease <- disease_results

rio::export(dblist,file = "~/rprojects/SSP/data_preload/annotation/DBfileANNOTATED.xlsx")
