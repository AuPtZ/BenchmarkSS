### Welcome to the Benchmark Module!   
In this module, you can evaluate Signature Search Methods (SSMs) based on signatures and well-annotated drugs in LINCS.  
Please follow the steps below to perform job:   

<div style="padding: 10px; text-align: center;">
<img src="imgbm1.png" width = "80%" height = "40%" />
</div>

**1. Select a pharmacotranscriptomic dataset (PTD).**  
**2. Select at least two SSMs for testing**  
**3. A oncogenic signature (OGS) represent a specific cancer.**   
**4. Drug annotations indicating the drug's efficacy in experiments or its approval status in clinic (e.g., FDA-approved).**   

Please be aware that OGS and drug annotation files can be accessed through the help button adjacent to the **steps in the left panel**.    
<div style="padding: 10px; text-align: center;">
<img src="imgbm1.1.gif" width = "50%" height = "40%" />
</div>

OGS is a gene list header with **Gene** and **Log2FC**. Notably, SSP accepts the genes in the format of **gene symbol** and assumes that input **OGS are statistically significant (p < 0.05)**, ensuring their relevance for further analysis.    
Should your OGS contain genes formatted with alternative identifiers (such as EntrezID, Ensembl, UniProt, Gene name, etc.), proceed to the Converter page for the necessary conversion.    
<div style="padding: 10px; text-align: center;">
<img src="imgbm1.2.png" width = "30%" height = "30%" />
</div>

Drug annotations are commonly sourced from databases and resources such as ChEMBL, PubChem, scientific literature, clinical trials, and DrugBank. Users have two options: ① Download a blank annotation table and label it manually, or     
<div style="padding: 10px; text-align: center;">
<img src="imgbm2.png" width = "50%" height = "30%" />
</div>
② Independently compile annotations from various sources and upload them into the Converter module to get a format-compatible annotation file.   
<div style="padding: 10px; text-align: center;">
<img src="imgbm2.1.png" width = "50%" height = "30%" />
</div>

**Notably, the SSP employs two drug annotation metrics, AUC and ES, with users required to select at least one for the performance assessment of SSMs. Annotating every drug is impractical; nonetheless, an increased number of annotations leads to more precise outcomes.**  
Typically, **AUC** reflects drug efficacy as determined by experimental data, while **ES** signifies drug efficacy based on FDA-approved clinical indications. These distinct metrics offer a comprehensive evaluation of SSMs, encompassing both experimental and clinical contexts.      
**Additionally, the SSP provides a primary annotated drug list accessible through the Annotation Module.**  

**1. AUC**  
For annotations of L1000 drugs that are deemed effective or ineffective (typically based on whether IC50 values < 10μM), proceed with the upload during step 4a. The file should appear as follows (header with **Compound.name** and **Group**. Ensure that the file comprises a minimum of five drugs and clearly denotes both two categories of labels: 'effective' and 'ineffective'.):  

<div style="padding: 10px; text-align: center;">
<img src="imgbm3.png" width = "30%" height = "30%" />
</div>

Subsequently, drug scores will be computed and ranked based on the confusion matrix using the Area Under the Curve **(AUC)**, with **a higher AUC signifying superior performance**.   

**2. ES**   
Annotations for clinically efficacious drugs (determined by clinical data, such as those FDA-approved) can be uploaded during step 4b. The file format should be as follows:     

<div style="padding: 10px; text-align: center;">
<img src="imgbm4.png" width = "30%" height = "30%" />
</div>


SSP will calculate drug scores and determine the **enrichment score (ES)**, with **a lower ES indicating enhanced performance**.    
Ultimately, initiate the process by clicking 'Run,' which will generate a job ID (**jobid**) prefixed with 'BEN'. Results are typically available within approximately 15~30 minutes, and a 'Quick Tip' will be provided to assist with result interpretation. Alternatively, you may close the page and retrieve the job ID in the **Job Center**  for future result retrieval.   

<div style="padding: 10px; text-align: center;">
<img src="imgbm5.png" width = "40%" height = "30%" />
</div>

For more information, please visit **Info-Help** page.
Users seeking a preliminary annotation should navigate to the **Annotation** page.




