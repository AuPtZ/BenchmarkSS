### How to use Robustness and interpret the results?  
Considering the significant attrition rates, considerable expenses, and sluggish progress in new drug discovery and development, the idea of repurposing 'old' drugs to treat a variety of diseases is progressively gaining appeal. An effective method that has been validated involves annotating drugs with known diseases, thereby discovering that similar drugs may potentially have superior therapeutic effects.   
Currently, there are numerous methods for drug repurposing, one of which is based on pharmacotranscriptomic datasets. This method involves drug screening through disease signatures obtained from sequencing cell lines or patient tissue samples, a process we refer to as Signature Search (SS).   
In **Benchmark** module, we test SS methods based on annotation of drugs. Actually, it may be **inapplicable when drugs without sufficient annotation**.   
Therefore, we introduce **robustness module** testing the performance of SS methods based on **pharmacotranscriptomic dataset self-similarity**!  
Briefly, we label these drugs from 1 to N, where N is the number of drugs in one set.  
For each drug profile, we extract the top x up-regulated and top x down-regulated DEGs as its signature, which we then query into one of these SS methods to obtain matching scores for these drugs.   
Next, we rank the drugs based on their scores.  
Three parameters are used to assess the robustness of these methods at different x:  
1. Correlation (**R**) of the input and top1 output for all drugs.  
2. The mean of the difference scores between the top1 and top2 outputs.  
3. The standard deviation (**SD**) of the difference between the scores of top1 and top2 outputs.   
Finally, the drug retrieval **performance score** can be expressed by the following formula:  

$$
performance score =  \\frac{ Mean \\times R }{SD}
$$

A satisfactory performance is achieved if **the method accurately returns the input drug (stronger correlation) and distinguishes well between drugs (more significant difference score) with maintains good stability (lower SD)**.  
In this study, we tested performance scores for the cases of x at **100,110,120......480**, respectively.  

<div style="padding: 10px; text-align: center;">
<img src="imginfo10.PNG" width = "80%" height = "80%" />
</div>



As shown in the figure, a higher **performance score** indicates greater robustness, indicating that the method is more accurate.  
The results may differ from the **Benchmark** module because it is an overall performance evaluation.
The best topN are required to be used in the **Application** module.
