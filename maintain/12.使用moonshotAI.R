library(reticulate)
library(dplyr)

use_condaenv("~/miniconda3/envs/pachong/bin/python3.8")
source_python("~/rprojects/SSP/maintain/12.使用moonshotAI.py")

dblist <- rio::import("~/rprojects/SSP/data_preload/annotation/DBfile.xlsx") %>% as.data.frame()

# 初始化一个空的列表来存储结果
disease_results <- vector("list", length = nrow(dblist))

# 对Indication列进行迭代处理
for (i in seq_along(dblist$Indication)) {
  # 调用函数并保存结果
  disease_results[[i]] <- get_moon_chat_answer(dblist$Indication[i])
  
  # 每调用一次函数后打印一条消息
  cat("Processed", i, "of", nrow(dblist), "\n")
  
  # 如果不是每3次调用后的最后一次，则暂停20秒（3次调用需要暂停2次，总共40秒，留下20秒处理时间）
  if (i %% 2 == 0) {
    Sys.sleep(60)
  }
}

# 将列表转换为向量
disease_results <- unlist(disease_results)

# 将结果添加到新列Disease
dblist$Disease <- disease_results
