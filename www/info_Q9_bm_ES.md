In the presentaion of result, you can see at least one plot and one table.  
If you provide annotation of ES, you will see the result of ES and the same to AUC.    
In result of ES, the image is a scatter plot depicting the results of the **Enrichment Score (ES)** for different **signature search methods (SSMs)** across various TopN values. ES is a metric used to evaluate the performance of SSMs, typically in drug efficacy classification tasks. There are four methods represented by different colored dots: **CMap (red)**, **GSEA (blue)**, **XCos (teal)**, **XSum (dark blue)**, and **ZhangScore (orange)**. The ES results for each method at different TopN values are plotted with the corresponding colored dots, with a smooth trend line for each method indicating the change in ES as TopN increases.   
The vertical dashed line in the scatter plot indicates the position of the TopN value where the **minimum ES** is achieved for one or more methods.  
<div style="padding: 10px; text-align: center;">
<img src="imginfoQ9_3.png" width = "80%" height = "80%" />
</div>

In the corresponding table below, the row with the TopN value associated with the **minimum** is placed at the forefront, and the cell containing the **minimum value** is highlighted in yellow.  
<div style="padding: 10px; text-align: center;">
<img src="imginfoQ9_4.png" width = "80%" height = "80%" />
</div>
