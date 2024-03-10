### Welcome to Application module! 
#### For demo results, please go to the Job Center page.  
In this module, you can apply Signature Search methods (SSMs) to query drugs based on the signature input.   
**SSP assumes that input oncogenic signatures are statistically significant (p < 0.05) by default, ensuring their relevance for further analysis.**  
Here we provide three ways to find promising drugs:  

<div style="padding: 10px; text-align: center;">
<img src="imgsm1.png" width = "50%" height = "50%" />
</div>  

As shown in the picture:
1. **Single method** : Single method: Query drugs using one SSM, as the **traditional way**. Typically, **abs(logFC) > ±1** is used for filter differentially expressed genes.  
2. **SS_cross** : Query drugs using **two signatures** and rank them by overall scores (ScoreSum). SS_cross aims to found polypharmacological drugs.
3. **SS_all** : Query drugs across multiple SS methods and rank them in the same direction (up or down) using robust rank aggregation (RRA), SS_all takes all SSM into account and found the **greatest common drugs**.  
**Different way requires different steps:**  

For the **Single method**, we need four steps:  
① Select a desired SSM,  
② Select one pharmacotranscriptomic dataset (PTD),  
③ Upload your **signature file (header with 'Gene' and 'log2FC')**, and  
④ Set how many top genes (up and down) to use, it may be hinted from the benchmark module or robustness module.  

<div style="padding: 10px; text-align: center;">
<img src="imgsm2.png" width = "70%" height = "70%" />
</div>

For **SS_cross**, step ③ is different:  
two signature files and their names are required, the name of the first signature represents the X axis, and the second represents the Y axis in the result figure.   

<div style="padding: 10px; text-align: center;">
<img src="imgsm3.png" width = "70%" height = "70%" />
</div>


For **SS_all**, step ① is different:    
you can select some methods and a direction to rank the drugs, generally, if you upload an oncogenic signature, choose **'down'**; otherwise, choose **'up'**.   

<div style="padding: 10px; text-align: center;">
<img src="imgsm4.png" width = "70%" height = "70%" />
</div>

Finally, click the "Run" button and you will get a **jobid** in Job Center for result inquiry later.

<div style="padding: 10px; text-align: center;">
<img src="imgsm5.png" width = "40%" height = "40%" />
</div>

For more information, please visit the **Info-Help** page.  
