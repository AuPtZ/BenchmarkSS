# 删除指定目录下的所有文件
list_dir = c("cache/SM/","cache/BM/","cache/SS/")

for (i in list_dir){
  file.remove(paste0(i,dir(i)))
  dir.create(i)
}