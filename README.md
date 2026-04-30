This repository contains analysis codes for the paper: Distinct neural dynamics in prefrontal and premotor cortex during flexible perceptual decisions

Data required to generate plots are freely accessible on zenoto:

Full data is available upon request.

Download the data folder: anaalysisData_NC to the same directory as analysisCode_NC. 

Here is the partial file tree: 

├── Fig1_behavior                       Contains code to plot Fig1 and FigS1
│   ├── Fig1d_behavior.m                % plots Fig 1d: chronometric curves and reaction time curves 


├── Fig1_npix_snip                      Contains code to plot Fig1
│   ├── Fig1fg_npix.m                   % plots Fig1f-g: 1 exmaple neuropixel recording session


├── Fig2_PSTH                           Contains code to plot Fig2 and FigS2
│   ├── Fig2_plotPSTH.m                 % plot Fig2a-h and FigS2a-h 
│   ├── FigS2_single_unit_MI    
│   │   ├── FigS2iJ_plotMixedSelectResults.m      % plot Fig2Si-j   
│   │   ├── FigS2kl_plotMI.m                      % plot Fig2Sk-h  


├── Fig3_dpca                           Contains code to plot Fig2c
│   ├── Fig3c_dlpfc_dpca.m      
│   ├── Fig3c_pmd_dpca.m



├── Fig3_pca                            Contains code to plot Fig2a-b
│   ├── Fig3a_pcaExpVar.m
│   ├── Fig3b_dlpfc_pca.m
│   └── Fig3b_pmd_pca.m


├── Fig4_geometry                       Contains code to plot Fig4, FigS3, FigS4
│   ├── Fig4abd_pca_visualize
│   │   ├── Fig4ab_pca_pfc_pmd.m            % plot Fig4a-b: pca projected to 2 PC axes           
│   │   ├── Fig4d_pca_cue.m                 % plot Fig4d: pca with different difficulties
│   │   ├── FigS4c_pca_cue_move.m           % plot FigS4c: pca alignes to movement onset
│   ├── Fig4ce_nonlinear_decoding
│   │   ├── Fig4c_nonlinearDecoding.m                  % plot Fig4c: nonlinear choice decoding 
│   │   ├── Fig4e_nonlinearDecoding_stimulus.m         % plot Fig4e: nonlinear choice decoding with stimulus 
│   │   ├── FigS4bc_quatilateralDecoding.m             % plot FigS4b-c: decode all 6 color-action combinations
│   └── Fig4fg_correct_wrong            
│       ├── Fig4fg_plotStimDecoder_CW.m                % plot Figf-g: decoders to predict correct vs wrong trials



├── Fig5_function_gradient               Contains code to plot Fig5 and FigS5
│   ├── Fig5abc_plotSingleUnitsDPCA.m           % plot Fig5a-c: scatter plot of dpc loadings       
│   ├── Fig5de_areaDpcaProject.m                % plot Fig5d-e: dpca loadings of each area
│   ├── Fig5d_areaSpectrolaminar.m              % plot Fig5d: each area's spectrolaminar profile
│   ├── FigS5df_plotSingelUnitsES.m             % plot FigS5d-f: scatter plot of effect size
│   ├── FigS5h_plotSingleUnitsDPCA_mix.m        % plot FigS5h: mixed selectivity index



├── Fig6_linearRNN                      Contains code to plot Fig6
│   ├── Fig6b_rotation_angle_analysis.m        
│   ├── Fig6bc_pca_dpca.m
│   └── XORModel3.m


├── FigS7_RNN                           Contains code to plot FigS7
│   ├── FigS7c_plotAreaResults.m
│   ├── FigS7de_compareModelsResults.m
│   ├── FigS7fg_dpca_variance.m
├── README.md
└── utils                               Utility codes and helper functions





