This repository contains analysis code for the paper:

**"Distinct neural dynamics in prefrontal and premotor cortex during flexible perceptual decisions"**

---

## 📄 Paper

* Preprint: https://www.biorxiv.org/content/10.64898/2026.02.02.702013v1

---

## 📦 Data Access

* Data required to generate the plots are available on **Zenodo**
* Full dataset is available upon request

---

## ⚙️ Setup Instructions

1. Download the data folder:

   ```
   analysisData_NC
   ```

2. Place it in the same directory as:

   ```
   analysisCode_NC
   ```

3. Run the scripts corresponding to each figure


## 📁 File Structure

```
├── Fig1_behavior                                   Contains code to plot Fig1 and FigS1
│   ├── Fig1d_behavior.m                            % plots Fig 1d: chronometric curves and reaction time curves 

├── Fig1_npix_snip                                  Contains code to plot Fig1
│   ├── Fig1fg_npix.m                               % plots Fig1f-g: 1 example Neuropixels recording session

├── Fig2_PSTH                                       Contains code to plot Fig2 and FigS2
│   ├── Fig2_plotPSTH.m                             % plots Fig2a-h and FigS2a-h 
│   ├── FigS2_single_unit_MI    
│   │   ├── FigS2iJ_plotMixedSelectResults.m        % plots FigS2i-j   
│   │   ├── FigS2kl_plotMI.m                        % plots FigS2k-l  

├── Fig3_dpca                                       Contains code to plot Fig2c
│   ├── Fig3c_dlpfc_dpca.m      
│   ├── Fig3c_pmd_dpca.m

├── Fig3_pca                                        Contains code to plot Fig2a-b
│   ├── Fig3a_pcaExpVar.m
│   ├── Fig3b_dlpfc_pca.m
│   └── Fig3b_pmd_pca.m

├── Fig4_geometry                                   Contains code to plot Fig4, FigS3, FigS4
│   ├── Fig4abd_pca_visualize
│   │   ├── Fig4ab_pca_pfc_pmd.m                    % plots Fig4a-b: PCA projected to 2 PC axes           
│   │   ├── Fig4d_pca_cue.m                         % plots Fig4d: PCA with different difficulties
│   │   ├── FigS4c_pca_cue_move.m                   % plots FigS4c: PCA aligned to movement onset
│   ├── Fig4ce_nonlinear_decoding
│   │   ├── Fig4c_nonlinearDecoding.m               % plots Fig4c: nonlinear choice decoding 
│   │   ├── Fig4e_nonlinearDecoding_stimulus.m      % plots Fig4e: nonlinear decoding with stimulus 
│   │   ├── FigS4bc_quatilateralDecoding.m          % plots FigS4b-c: decode all 6 color-action combinations
│   └── Fig4fg_correct_wrong            
│       ├── Fig4fg_plotStimDecoder_CW.m            % plots Fig4f-g: decoder for correct vs wrong trials

├── Fig5_function_gradient                          Contains code to plot Fig5 and FigS5
│   ├── Fig5abc_plotSingleUnitsDPCA.m               % plots Fig5a-c: scatter plot of dPCA loadings       
│   ├── Fig5de_areaDpcaProject.m                    % plots Fig5d-e: dPCA loadings of each area
│   ├── Fig5d_areaSpectrolaminar.m                  % plots Fig5d: spectrolaminar profile
│   ├── FigS5df_plotSingelUnitsES.m                 % plots FigS5d-f: effect size scatter
│   ├── FigS5h_plotSingleUnitsDPCA_mix.m            % plots FigS5h: mixed selectivity index

├── Fig6_linearRNN                                  Contains code to plot Fig6
│   ├── Fig6b_rotation_angle_analysis.m        
│   ├── Fig6bc_pca_dpca.m
│   └── XORModel3.m

├── FigS7_RNN                                       Contains code to plot FigS7
│   ├── FigS7c_plotAreaResults.m
│   ├── FigS7de_compareModelsResults.m
│   ├── FigS7fg_dpca_variance.m

├── README.md
└── utils                                           Utility codes and helper functions
```



## 🧠 Notes

* Scripts are named to match figure panels in the paper
* For some plots, data is in the same location as code
* Some figures contains a `legacy` folder, which contains the code to generate data or statistical test
* Utility functions are located in `utils/`

---

## 📬 Contact

For questions or data access, please reach out directly.

---
