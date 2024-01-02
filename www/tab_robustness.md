### Welcome to Robustness module!
In this module, you can evaluate the performance of signature search (SS) methods.  
In the **Benchmark module**, we tested SS methods based on drug annotations.   
However, it may not be appropriate when there is **insufficient annotation** for the profiles.   
Hence, we test the performance of SS methonds based on **profile self-similarity**.  
Briefly, we labeled these drugs from 1 to N (N being the order of drugs in one set).  
For each drug profile, we extracted the top x up-regulated and top x down-regulated DEGs and defined them as a signature. This signature was then queried into one of the SS methods to obtain the matching scores of these drugs.  
We then ranked the drugs based on their scores.  
To evaluate the robustness of these methods at different x values, three parameters were used:  
**1. Correlation (R) of the input and top1 output for all drugs.**  
**2. The mean of the difference scores between the top 1 and top 2 outputs.**  
**3. The standard deviation (SD) of the difference between the scores of the top 1 and top 2 outputs.**  
Finally, the drug retrieval performance score can be expressed by the following formula:

$$ 
Score_{mean} =  \\sqrt{ abs(Score_{sig1} \\times Score_{sig2}) }
$$

A satisfactory performance was achieved if the method **accurately return the input drug (stronger correlation)** and **distinguish well between drugs (more significant difference score) and maintained good stability (lower SD)**.  
In this study, we tested performance scores for the cases of x at 100,110,120......480, respectively.
