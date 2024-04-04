### How to query drugs if I have a drug signature?
SSP is designed to find promising drug based on oncogenic signature (OGS) and drug annotation.
**BUT it is also applicable for drug signature, but there is a little different.**  
For example, you have to annotate drug "Ineffective" which is actually effective and visa verse in annotation prepare for AUC, and you also need to provide effective drug list for ES but the higher ES indicate high performance.  
**Robustness module** is **not affected** because it is inherently based on the results obtained from drug signature self-retrieval.   