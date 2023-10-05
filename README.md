# Signature Search Polestar (SSP)

#### Description
Signature Search Polestar (SSP), a webserver integrating drug profiles in L1000 with five state-of-art SS methods and provide three modules to facilitate drug repurposing. 


#### Introduction
The growing interest in human genes and accessibility of high-throughput technologies directly lead to exponential increase data size in pharmacotranscriptomic profiles.

Profile-based method has been widely used for screening drugs and identifying molecular actions of drugs，which could remarkably enhance novel drug-disease pair discovery without relying on drug- or disease-specific prior knowledge. This analysis method was named “signature search (SS)”. Meanwhile, various SS methods were proposed, but how to find the optimal method and top differentially expressed genes (DEGs) for certain data is still challenging. How to find the optimal methods and parameters for different signature input and drug profiles is still challenging.

Signature Search Polestar (SSP) is a webserver integrating the largest uniform drug profiles in L1000 with five state-of-art (XSum, CMap, GESA, ZhangScore, XCos) and provide three modules to facilitate drug repurposing:

1. Benchmark: Two indices (AUC and Enrichment Score) based on drugs annotations are employed to evaluate the performance of SS methods at different top DEGs. The results indicate the best evaluation method and the best top DEGs for input disease signature.
2. Robustness: A robust index based on drug profiles itself is developed to evaluate the overall performance of SS methods at different top DEGs. This module is applicable when meets insufficient drug annotations.
3. Application: Three tools (single method, SS_all and SS_cross) enable user to utilize optimal SS methods with disease signatures. The results present scores of promising drug repurposing for disease signature.


#### Software Architecture

```
├── app.R
├── beforerun.R
├── benchmark_tab.R
├── cache
├── data_preload
├── data_tab.R
├── demo
├── demoLoop.txt
├── info_tab.R
├── jobcenter_tab.R
├── LICENSE
├── NULLprocessing
├── R
├── README.md
├── results
├── robustness_tab.R
├── selfloop.R
├── sessioninfo.rdata
├── sessionInfo.txt
├── singlemethod_tab.R
├── SSP.Rproj
└── www
```




#### Installation

This site provide core code in SSP.
A full demo (18G) needs to be download manually via below link
http://work.biotcm.net:20002/down/tZzQfL9ltGkO.gz
download and unzip the file, and run beforerun.R for essential packages installment
then run the app.R file in Rstudio


#### Instructions

Linux is highly recommended for multi-cores computing.
