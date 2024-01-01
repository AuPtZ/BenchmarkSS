## generate null distribution for each method

# source("App-1/R/SS.R")
# read gctx
library(cmapR)
library(dplyr)
library(tidyr)
library(tidyverse)
library(stringr)


dir1 = "NULLprocessing/" #数据存储随机生成的NULLexp
dir2 = "NULLprocessing/NULLscore/" # 用于存储计算NULLexp结果的目录
dir3 = "/data_preload/drugexp/" # 药物表达谱的位置
refdir = list.files(dir3) #药物表达谱列表

# generate null data
if(!file.exists( paste0(dir1,"LINC_NULL.rdata") )){
  dir = "~/dataportal/LINCS/GSE92742_Broad_LINCS_Level5_COMPZ.MODZ_n473647x12328.gctx"
  
  sig_GSE92742 <- read.delim("~/dataportal/LINCS/GSE92742_Broad_LINCS_sig_info.txt.gz",comment.char = "!")
  
  rdesc <- read_gctx_meta(dir, dim="row")
  cdesc <- read_gctx_meta(dir, dim="col")
  
  gene_info <- rio::import("~/rprojects/sigsearchmethods/GSE92742_Broad_LINCS_gene_info.txt.gz",
                           format="\t") %>% dplyr::filter(pr_is_lm == 1)
  
  
  
  duochang <- 2000
  
  get_null <- function(row_sample){
    GSE92742 <- parse_gctx(dir,
                           cid= sample(cdesc$id,duochang), 
                           rid = as.character(row_sample) ,
                           matrix_only=TRUE)
    refMatrix <- GSE92742@mat
    rownames(refMatrix) <- row_sample
    colnames(refMatrix) <- 1:duochang
    
    print(row_sample)
    return(as.data.frame(refMatrix) )
  }
  
  null_drug <- parallel::mclapply(as.character(gene_info$pr_gene_id), get_null,mc.cores = 32L)
  
  null_drug <- do.call(rbind,null_drug) 
  
  null_drug1 <- null_drug %>%
    rownames_to_column(var="pr_gene_id") %>%
    mutate(pr_gene_id = as.integer(pr_gene_id)) %>%
    inner_join(gene_info) %>%
    column_to_rownames(var="pr_gene_symbol") %>% 
    dplyr::select(as.character(c(1:(ncol(null_drug)))))
  
  save(null_drug1,file = paste0(dir1,"LINC_NULL.rdata") )
}else{
  load(file = paste0(dir1,"LINC_NULL.rdata") )
}






# get results of null data
# 这里使用并行运算对每一个过程进行加速，而不是对所有过程加速

# 运行单个计算的函数
# i 第几个signature
# funcname ，五个方法之一
# sig_input_all 所有的signature
# threshold 默认为1


XSumScore <- function(refMatrix, queryUp, queryDown,topN = 500, pval = F){
  

  if (is.data.frame(refMatrix)) {
    refMatrix <- as.matrix(refMatrix)
  }
  if (is.null(colnames(refMatrix)) || is.null(rownames(refMatrix))) {
    stop("Warning: refMatrix should have both rownames and colnames!")
  }
  if (!is.character(queryUp)) {
    queryUp <- as.character(queryUp)
  }
  if (!is.character(queryDown)) {
    queryUp <- as.character(queryDown)
  }
  if (topN > nrow(refMatrix)/2) {
    stop("Warning: topN is lager than half\n
         the length of gene list!")
  }
  matrixToRankedList <- function(refMatrix, topN) {
    refList <- vector("list", ncol(refMatrix))
    for (i in 1:ncol(refMatrix)) {
      refList[[i]] <- c(head(refMatrix[order(refMatrix[,i],
                                             decreasing = TRUE), i], 
                             n = topN), 
                        tail(refMatrix[order(refMatrix[,i], 
                                             decreasing = TRUE), i], 
                             n = topN))
    }
    return(refList)
  }
  
  XSum <- function(refList, queryUp, queryDown) {
    scoreUp <- sum(refList[match(queryUp, names(refList))], 
                   na.rm = T)
    scoreDown <- sum(refList[match(queryDown, names(refList))], 
                     na.rm = T)
    return(scoreUp - scoreDown)
  }
  
  refList <- matrixToRankedList(refMatrix, topN = topN)
  score <- lapply(refList, XSum, queryUp = queryUp, queryDown = queryDown)
  score <- as.vector(do.call(rbind, score))
  
  if(pval){
    scoreResult <- data.frame(Score = score,pValue=1,pAdjValue = 1)
  }else(
    scoreResult <- data.frame(Score = score)
  )
  
  rownames(scoreResult) <- colnames(refMatrix)
  return(scoreResult)
}

KSScore <- function(refMatrix, queryUp, queryDown, pval = F){

  if (is.data.frame(refMatrix)) {
    refMatrix <- as.matrix(refMatrix)
  }
  if (is.null(colnames(refMatrix)) || is.null(rownames(refMatrix))) {
    stop("Warning: refMatrix should have both rownames and colnames!")
  }
  if (!is.character(queryUp)) {
    queryUp <- as.character(queryUp)
  }
  if (!is.character(queryDown)) {
    queryUp <- as.character(queryDown)
  }
  matrixToRankedList <- function(refMatrix) {
    refList <- vector("list", ncol(refMatrix))
    for (i in 1:ncol(refMatrix)) {
      refList[[i]] <- names(refMatrix[order(refMatrix[, 
                                                      i], decreasing = TRUE), i])
    }
    return(refList)
  }
  ksScore <- function(refList, query) {
    lenRef <- length(refList)
    queryRank <- match(query, refList)
    queryRank <- sort(queryRank[!is.na(queryRank)])
    lenQuery <- length(queryRank)
    if (lenQuery == 0) {
      return(0)
    }
    else {
      d <- (1:lenQuery)/lenQuery - queryRank/lenRef
      a <- max(d)
      b <- -min(d) + 1/lenQuery
      ifelse(a > b, a, -b)
    }
  }
  ks <- function(refList, queryUp, queryDown) {
    scoreUp <- ksScore(refList, queryUp)
    scoreDown <- ksScore(refList, queryDown)
    ifelse(scoreUp * scoreDown <= 0, scoreUp - scoreDown, 
           0)
  }
  refList <- matrixToRankedList(refMatrix)
  queryUp <- intersect(queryUp, rownames(refMatrix))
  queryDown <- intersect(queryDown, rownames(refMatrix))
  score <- lapply(refList, ks, queryUp = queryUp, queryDown = queryDown)
  score <- as.vector(do.call(rbind, score))
  
  if(pval){
    scoreResult <- data.frame(Score = score,pValue=1,pAdjValue = 1)
  }else(
    scoreResult <- data.frame(Score = score)
  )
  
  rownames(scoreResult) <- colnames(refMatrix)
  return(scoreResult)
}

GSEAweight1Score <- function(refMatrix, queryUp, queryDown, pval = F){

  if (is.data.frame(refMatrix)) {
    refMatrix <- as.matrix(refMatrix)
  }
  if (is.null(colnames(refMatrix)) || is.null(rownames(refMatrix))) {
    stop("Warning: refMatrix should have both rownames and colnames!")
  }
  if (!is.character(queryUp)) {
    queryUp <- as.character(queryUp)
  }
  if (!is.character(queryDown)) {
    queryUp <- as.character(queryDown)
  }
  matrixToRankedList <- function(refMatrix) {
    refList <- vector("list", ncol(refMatrix))
    for (i in 1:ncol(refMatrix)) {
      refList[[i]] <- refMatrix[order(refMatrix[, i], decreasing = TRUE), 
                                i]
    }
    return(refList)
  }
  weight1EnrichmentScore <- function(refList, query) {
    tagIndicator <- sign(match(names(refList), query, nomatch = 0))
    noTagIndicator <- 1 - tagIndicator
    N <- length(refList)
    Nh <- length(query)
    Nm <- N - Nh
    correlVector <- abs(refList)
    sumCorrelTag <- sum(correlVector[tagIndicator == 1])
    normTag <- 1/sumCorrelTag
    normNoTag <- 1/Nm
    RES <- cumsum(tagIndicator * correlVector * normTag - 
                    noTagIndicator * normNoTag)
    maxES <- max(RES)
    minES <- min(RES)
    maxES <- ifelse(is.na(maxES), 0, maxES)
    minES <- ifelse(is.na(minES), 0, minES)
    ifelse(maxES > -minES, maxES, minES)
  }
  weight1 <- function(refList, queryUp, queryDown) {
    scoreUp <- weight1EnrichmentScore(refList, queryUp)
    scoreDown <- weight1EnrichmentScore(refList, queryDown)
    ifelse(scoreUp * scoreDown <= 0, scoreUp - scoreDown, 
           0)
  }
  refList <- matrixToRankedList(refMatrix)
  queryUp <- intersect(queryUp, rownames(refMatrix))
  queryDown <- intersect(queryDown, rownames(refMatrix))
  score <- lapply(refList, weight1, queryUp = queryUp, queryDown = queryDown)
  score <- as.vector(do.call(rbind, score))
  
  if(pval){
    scoreResult <- data.frame(Score = score,pValue=1,pAdjValue = 1)
  }else(
    scoreResult <- data.frame(Score = score)
  )
  
  rownames(scoreResult) <- colnames(refMatrix)
  return(scoreResult)
}

ZhangScore <- function(refMatrix, queryUp, queryDown, pval = F){
  if (is.data.frame(refMatrix)) {
    refMatrix <- as.matrix(refMatrix)
  }
  if (is.null(colnames(refMatrix)) || is.null(rownames(refMatrix))) {
    stop("Warning: refMatrix should have both rownames and colnames!")
  }
  if (is.null(queryUp)) {
    queryUp <- character(0)
  }
  if (is.null(queryDown)) {
    queryDown <- character(0)
  }
  if (!is.character(queryUp)) {
    queryUp <- as.character(queryUp)
  }
  if (!is.character(queryDown)) {
    queryUp <- as.character(queryDown)
  }
  matrixToRankedList <- function(refMatrix) {
    refList <- vector("list", ncol(refMatrix))
    for (i in 1:ncol(refMatrix)) {
      refSort <- refMatrix[order(abs(refMatrix[, i]), decreasing = TRUE), 
                           i]
      refRank <- rank(abs(refSort)) * sign(refSort)
      refList[[i]] <- refRank
    }
    return(refList)
  }
  computeScore <- function(refRank, queryRank) {
    if (length(intersect(names(refRank), names(queryRank))) > 
        0) {
      maxTheoreticalScore <- sum(abs(refRank)[1:length(queryRank)] * 
                                   abs(queryRank))
      score <- sum(queryRank * refRank[names(queryRank)], 
                   na.rm = TRUE)/maxTheoreticalScore
    }
    else {
      score <- NA
    }
    return(score)
  }
  refList <- matrixToRankedList(refMatrix)
  queryVector <- c(rep(1, length(queryUp)), rep(-1, length(queryDown)))
  names(queryVector) <- c(queryUp, queryDown)
  score <- lapply(refList, computeScore, queryRank = queryVector)
  score <- as.vector(do.call(rbind, score))
  
  if(pval){
    scoreResult <- data.frame(Score = score,pValue=1,pAdjValue = 1)
  }else(
    scoreResult <- data.frame(Score = score)
  )
  
  rownames(scoreResult) <- colnames(refMatrix)
  return(scoreResult)
}

XCosScore <- function (refMatrix, query, topN = 500, pval = F){
  if (is.data.frame(refMatrix)) {
    refMatrix <- as.matrix(refMatrix)
  }
  if (is.null(colnames(refMatrix)) || is.null(rownames(refMatrix))) {
    stop("Warning: refMatrix must have both rownames and colnames!")
  }
  if (!is.numeric(query)) {
    stop("Warning: query must be a numeric vector!")
  }
  if (is.null(names(query))) {
    stop("Warning: query must have names!")
  }
  if (topN > nrow(refMatrix)/2) {
    stop("Warning: topN is lager than half\n
         the length of gene list!")
  }
  matrixToRankedList <- function(refMatrix, topN) {
    refList <- vector("list", ncol(refMatrix))
    for (i in 1:ncol(refMatrix)) {
      refList[[i]] <- c(head(refMatrix[order(refMatrix[, i], decreasing = TRUE), i], n = topN), 
                        tail(refMatrix[order(refMatrix[, i], decreasing = TRUE), i], n = topN))
    }
    return(refList)
  }
  XCos <- function(refList, query) {
    reservedRef <- refList[match(intersect(names(refList), 
                                           names(query)), names(refList))]
    reservedRef[order(names(reservedRef))]
    reservedQuery <- query[match(intersect(names(refList), 
                                           names(query)), names(query))]
    reservedQuery[order(names(reservedQuery))]
    if (length(reservedRef) == 0) {
      return(NA)
    }
    else {
      return((crossprod(reservedRef, reservedQuery)/sqrt(crossprod(reservedRef) * 
                                                           crossprod(reservedQuery)))[1, 1])
    }
  }
  refList <- matrixToRankedList(refMatrix, topN = topN)
  score <- lapply(refList, XCos, query = query)
  score <- as.vector(do.call(rbind, score))
  
  if(pval){
    scoreResult <- data.frame(Score = score,pValue=1,pAdjValue = 1)
  }else(
    scoreResult <- data.frame(Score = score)
  )
  
  
  rownames(scoreResult) <- colnames(refMatrix)
  return(scoreResult)
}

saveres <- function(i,sig_input_all,funcname,threshold,refMatrix){
  
  sig_input = sig_input_all[,as.character(i),drop=F] %>% rownames_to_column(var="Gene")
  

  
  colnames(sig_input) <- c("Gene","log2FC")
  
  sig1_up = sig_input %>%
    dplyr::filter(log2FC > threshold) %>%
    dplyr::arrange(desc(log2FC))
  sig1_up = sig1_up$Gene
  
  sig1_dn = sig_input %>%
    dplyr::filter(log2FC < -threshold)%>%
    dplyr::arrange(log2FC)
  sig1_dn = sig1_dn$Gene
  

  if (funcname == "SS_Xsum"){
    res_raw <- XSumScore(refMatrix = refMatrix,
                         queryUp = na.omit(sig1_up[1:489]) ,
                         queryDown = na.omit(sig1_dn[1:489]),
                         topN = 489)
  }
  
  if (funcname == "SS_CMap"){
    res_raw <- KSScore(refMatrix = refMatrix,
                       queryUp = na.omit(sig1_up[1:489]) ,
                       queryDown = na.omit(sig1_dn[1:489]))
  }
  
  if (funcname == "SS_GSEA"){
    res_raw <- GSEAweight1Score(refMatrix = refMatrix,
                                queryUp = na.omit(sig1_up[1:489]) ,
                                queryDown = na.omit(sig1_dn[1:489]))
  }
  
  if (funcname == "SS_ZhangScore"){
    res_raw <- ZhangScore(refMatrix = refMatrix,
                          queryUp = na.omit(sig1_up[1:489]) ,
                          queryDown = na.omit(sig1_dn[1:489]))
  }
  
  if (funcname == "SS_XCos"){
    sig_input1 <- sig_input %>% dplyr::filter(log2FC < -threshold) %>% slice_min(log2FC,n=489)
    sig_input2 <- sig_input %>% dplyr::filter(log2FC > threshold) %>% slice_max(log2FC,n=489)
    sig_input3 <- rbind(sig_input2,sig_input1)
    sig_input4 <- setNames(sig_input3$log2FC,sig_input3$Gene)
    res_raw <- XCosScore(refMatrix = refMatrix,
                         query = sig_input4,
                         topN = 489)
  }
  
  if( i %% 100 == 0) {
    print(paste0(funcname," ",i) )
  }
  
  return(res_raw)
  
}




get_ss_res <- function(refdir1,sig_input_all,threshold,funcname){
  

  if(!file.exists(paste0(dir2, refdir1, "_", funcname, ".rdata"))){
    
    load(paste0(dir3,refdir1)) 
    
    print(paste0("processing ",refdir1))

    res_raw <- parallel::mclapply(1:2000 ,
                                  saveres,
                                  sig_input_all = null_drug1, 
                                  funcname = funcname,
                                  threshold = 1,refMatrix = exp_GSE92742,
                                  mc.cores = 25L)

    nulldistribution <- do.call(cbind,res_raw) %>% round(4)
    print(paste0(dir2, refdir1, "_", funcname, ".rdata"))
    save(nulldistribution,file = paste0(dir2, refdir1, "_", funcname, ".rdata"))
    rm(nulldistribution)
    gc()

  }
}


for (k1 in c("SS_Xsum","SS_XCos","SS_ZhangScore","SS_GSEA","SS_CMap")) {
  purrr::map(refdir,get_ss_res,sig_input_all = null_drug1, threshold =1,funcname=k1)
  print(k1)
}





