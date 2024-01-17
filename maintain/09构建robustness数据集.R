# to get rank based on self loops
# rio::export(exp_GSE92742,file = "demoLoop.txt",format = "tsv",row.names=T)
# topn = 100
# cpname = unique(loop1$compounds)[1]
# threshold = 0

library(dplyr)

XSumScore <- function(refMatrix, queryUp, queryDown,topN = 500, pval = F){
  
  # print("XSumScore is using")
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
  # print("KSScore is using")
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
  # print("GSEAweight1Score is using")
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


get_rank_sp <- function(cpname,refMatrix,threshold,topn){
  
  # print(cpname)
  
  sig_input <- refMatrix %>% dplyr::select(all_of(cpname)) %>% tibble::rownames_to_column(var = "Gene") %>% 
    tidyr::pivot_longer(!Gene, names_to = "compounds", values_to = "log2FC") %>% dplyr::arrange(log2FC)
  
  sig1_up <- sig_input %>% filter(log2FC > threshold) %>% 
    dplyr::arrange(desc(log2FC)) %>% dplyr::select(Gene) %>% unlist(use.names = F)
  sig1_dn <- sig_input %>% filter(log2FC < -threshold) %>% 
    dplyr::arrange(log2FC) %>% dplyr::select(Gene) %>% unlist(use.names = F)
  
  
  .S <- function(scores) {
    p <- max(scores)
    q <- min(scores)
    ifelse(scores == 0, 0, ifelse(scores > 0, scores / p, -scores / q))
  }
  
  res_xsum_raw <- XSumScore(refMatrix,
                            queryUp = na.omit(sig1_up[1:topn]) ,
                            queryDown = na.omit(sig1_dn[1:topn]),
                            topN = nrow(refMatrix)/2) %>% 
    dplyr::transmute(Scale_score = .S(Score))
  
  res_ks_raw <- KSScore(refMatrix,
                        queryUp = na.omit(sig1_up[1:topn]) ,
                        queryDown = na.omit(sig1_dn[1:topn])) %>% 
    dplyr::transmute(Scale_score = .S(Score))
  
  res_gs_raw <- GSEAweight1Score(refMatrix,
                                 queryUp = na.omit(sig1_up[1:topn]) ,
                                 queryDown = na.omit(sig1_dn[1:topn])) %>% 
    dplyr::transmute(Scale_score = .S(Score))
  
  res_zh_raw <- ZhangScore(refMatrix,
                           queryUp = na.omit(sig1_up[1:topn]) ,
                           queryDown = na.omit(sig1_dn[1:topn])) %>% 
    dplyr::transmute(Scale_score = .S(Score))
  
  
  sig_input1 <- sig_input %>% dplyr::filter(log2FC < -threshold) %>% slice_min(log2FC,n = topn)
  sig_input2 <- sig_input %>% dplyr::filter(log2FC > threshold) %>% slice_max(log2FC,n = topn)
  sig_input3 <- rbind(sig_input2,sig_input1)
  sig_input4 <- setNames(sig_input3$log2FC,sig_input3$Gene)
  res_cos_raw <- XCosScore(refMatrix,
                           query = sig_input4,
                           topN = nrow(refMatrix)/2) %>% 
    dplyr::transmute(Scale_score = .S(Score))
  
  
  get_rank <- function(res_tb){
    rank_num <- res_tb %>% tibble::rownames_to_column(var = "name") %>% 
      dplyr::arrange(desc(Scale_score))  %>% 
      dplyr::slice(1) %>%  
      dplyr::select(name) %>% unlist(use.names = F)
    return(rank_num)
  }
  
  get_diff <- function(res_tb){
    rank_diff <- res_tb %>% tibble::rownames_to_column(var = "name") %>% 
      dplyr::arrange(desc(Scale_score))
    rank_diff <- rank_diff[1,2] - rank_diff[2,2]
    return(rank_diff)
  }
  
  res_all_1 <- do.call(
    cbind,
    lapply(list(res_xsum_raw,res_ks_raw,res_gs_raw,res_zh_raw,res_cos_raw),
           get_rank
    )
  )
  
  res_all_2 <- do.call(
    cbind,
    lapply(list(res_xsum_raw,res_ks_raw,res_gs_raw,res_zh_raw,res_cos_raw),
           get_diff
    )
  )
  
  colnames(res_all_1) <- c("Xsum1","CMap1","GSEA1","ZhangScore1","Cos1")
  colnames(res_all_2) <- c("Xsum2","CMap2","GSEA2","ZhangScore2","Cos2")
  res_all <- cbind(res_all_1,res_all_2)
  return(as.data.frame(res_all))
  
}

get_rb <- function(topn,refMatrix,threshold,file_input_string){
  
  colnames(refMatrix) <- 1:ncol(refMatrix)
  
  # (1) Correlation (R) of the input and top1 output for all ingredients.
  # (2) Mean of the difference scores between top1 and top2 in outputs.
  # (3) Standard deviation (SD) of the difference between scores of top1 and top2 in output.
  
  res1 <- purrr::map(as.character(1:ncol(refMatrix)) , get_rank_sp, 
                     refMatrix = refMatrix,threshold = threshold,topn = topn) %>% 
    purrr::list_rbind() %>%
    tibble::rownames_to_column(var = "input_id") %>% 
    readr::type_convert()
  
  save(res1,file = paste0("data_preload/robustness/tmp_files/",
                          file_input_string,"_",topn,".rdata"))
  
  res <- res1 %>% 
    dplyr::summarise(xsum =  cor(input_id,Xsum1) * mean(Xsum2) / sd(Xsum2) ,
                     cmap = cor(input_id,CMap1) * mean(CMap2) / sd(CMap2) ,
                     gsea = cor(input_id,GSEA1) * mean(GSEA2) / sd(GSEA2) ,
                     zhangscore = cor(input_id,ZhangScore1) * mean(ZhangScore2) / sd(ZhangScore2) ,
                     cos = cor(input_id,Cos1) * mean(Cos2) / sd(Cos2)) %>% 
    dplyr::mutate(topn = topn)
  
  print(topn)
  return(res)
  
}


dir_drug =  "data_preload/drugexp/" 
dir_robust = "data_preload/robustness/"

# 获取文件列表
file_list <- list.files(dir_drug)
file_info_list <- lapply(file.path(dir_drug, file_list), file.info)

file_sizes <- unlist(lapply(file_info_list, function(info) info$size))
file_list <- file_list[order(file_sizes, decreasing = T)]

for (gg in file_list){
  if(gg %in% list.files(dir_robust)){
    print(paste0("PASS ",gg))
  }else{
    print(gg)
    load(paste0(dir_drug,gg))
    res_topn <- parallel::mclapply(seq(from = 100, to = 480, by = 10),
                                   get_rb,refMatrix = exp_GSE92742,
                                   threshold = 0.585, mc.cores = 39L,file_input_string = gg)
    res_topn2 <- res_topn %>% do.call(rbind,.)
    save(res_topn2,file = paste0(dir_robust,gg))
    print(gg)
  }
  
}

# refMatrix = read.table("~/rprojects/BenchmarkSS/demoLoop.txt", row.names = 1, header = T) 