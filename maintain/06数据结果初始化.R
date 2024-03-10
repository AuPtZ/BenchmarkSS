# 删除指定目录下的所有文件
list_dir = c("cache/SM/","cache/BM/","cache/SS/")

for (i in list_dir){
  file.remove(paste0(i,dir(i)))
  dir.create(i)
}

# 初始化结果数据resinfo.db文件
library(RSQLite)

# Connect to the SQLite database
con <- dbConnect(SQLite(), "results/resinfo.db")

# List all tables in the database
tables <- dbListTables(con)
print(tables)

# Read a table into a data frame
# Replace "table_name" with the name of the table you want to read
df <- dbGetQuery(con, "SELECT * FROM 'res'")



# Tables to keep
keep_tables <- c('res', 'BEN1709818230GTS_AUC', 'BEN1709818230GTS_ES','APP1709818670ZIA')

# Remove tables not in keep_tables
for (table in tables) {
  if (!(table %in% keep_tables)) {
    dbRemoveTable(con, table)
  }
}

dbExecute(con, "DELETE FROM res")

dbExecute(con, "VACUUM")


# Don't forget to close the connection when you're done
dbDisconnect(con)

# 新测试的数据BEN1704094360ZDO
