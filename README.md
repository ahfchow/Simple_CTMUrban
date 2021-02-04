# Simple_CTMUrban

This is a simple simulator developed in MATLAB (mainly prepared for students with little experience on computer coding) for signal-controlled urban street networks based upon cell transmission model (CTM). The CTM computation is implemented mainly based on work by Kurzhanskiy and Varaiya (2009). 

- Reference: 
Kurzhanskiy A, Kwon J and Varaiya P (2009) Aurora Road Network Modeler. In: Proceedings of 12th IFAC Symposium on Control in Transportation Systems.



## Input file: 
1. UrbanConfig.m 

## Main program: 
1. CTM_UrbanStreet.m
 
## Sub-programs / functions: 
1. CTM.m            - CTM Simulator 
2. MOE.m            - Calculation of 'Measures of Effectiveness'
3. ControlVector.m  - Generation of 'control' vector based on given signal timing plan
4. Slice.m          - Generation of 'shorter' links for simulation 


## Output  
1. delays  
2. density contour
