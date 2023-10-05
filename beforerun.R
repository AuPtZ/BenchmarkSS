load("sessioninfo.rdata")


for (pkg in sI[["packages"]]$package){
  if (! require(pkg,character.only=T) ) {
    BiocManager::install(pkg,ask = F,update = F)
    require(pkg,character.only=T) 
  }
}

for (pkg in sI[["packages"]]$package){
  if (! require(pkg,character.only=T) ) {
    install.packages(pkg,ask = F,update = F)
    require(pkg,character.only=T) 
  }
}

#前面的所有提示和报错都先不要管。主要看这里
for (pkg in sI[["packages"]]$package){
  require(pkg,character.only=T) 
}






