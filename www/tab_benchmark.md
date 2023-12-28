### Welcome to Benchmark module!  
#### For demonstration results, please proceed to the job center page.  
In this module, you can evaluate signature search (SS) methods based on signature and well-annotated drugs in L1000.  
The Benchmark module requires the following settings:  

<div style="padding: 10px; text-align: center;">
<img src="imgbm1.png" width = "30%" height = "30%" />
</div>

**1. Select Drug profiles (L1000)**
**2. Select SS methods to test (at least two)**
**3. A signature (header with gene and logFC) to perform test**
**4. Drug annotations which user can download blank annotaion table of drugs by click the download button**  

<div style="padding: 10px; text-align: center;">
<img src="imgbm2.png" width = "30%" height = "30%" />
</div>

**Notably, we provide two types of drug annotation methods (AUC and ES), and users must use at least one method to assess the performance of SS. It is impractical to annotate all drugs; however, the more annotations obtained, the more accurate the results will be.**  
**1. AUC**  
If you have annotations for effective or ineffective L1000 drugs (generally based on whether IC50 < 10μM), you can upload them into step 4a. The file should appear as follows (header with Compound.name and Group):  

<div style="padding: 10px; text-align: center;">
<img src="imgbm3.png" width = "30%" height = "30%" />
</div>

We will then calculate the drug scores and rank them based on the confusion matrix using the Area Under Curve (**AUC**), the higher **AUC** indicates better performance.

**2. ES**
If you have annotations for effective L1000 drugs (generally based on Clinical info, such as FDA-approved drugs), you can upload them into step 4b. The file should appear as follows:  

<div style="padding: 10px; text-align: center;">
<img src="imgbm4.png" width = "30%" height = "30%" />
</div>

We will then calculate the drug scores and perform drug set enrichment score (**ES**), the lower **ES** indicates better performance.  
Finally, click the Run button, and you will obtain a job ID(**jobid**), starting with **BEN**.  
It may take approximately 15 minutes to obtain the results, but you can close the page and input the job ID in the  **job center** for later result inquiry.

<div style="padding: 10px; text-align: center;">
<img src="imgbm5.png" width = "30%" height = "30%" />
</div>

For more information, please vist **Info-Help** page.





