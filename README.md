# EOGPauseBlinkRelation
Analysis pipeline for the manuscript "Eye-blink patterns reflect attention to continuous speech"

This folder contains the analysis pipeline for the manuscript "Eye-blink patterns reflect attention to continuous speech" (doi: tba).

The corresponding dataset can be found in the OpenNeuro repository https://openneuro.org/datasets/ds004369

To replicate the analysis use MATLAB R2019b and follow these steps:

1) Download all scripts into one folder.
2) Download the BIDS dataset from https://openneuro.org/datasets/ds004015 into a folder that is on the same level as the folder containing the scripts. 
3) Download EEGLAB v2020.0 and add the respective path within bjh_00_pause_blink_main.m. 
4) Downlod the BLINKER toolbox (https://github.com/VisLab/EEG-Blinks) and unzip it into the plugin folder of EEGLAB
7) Within bjh_00_pause_blink_main.m specify the name of the folder in which you downloaded the data (BIDS_folder_name).
8) Run bjh_00_pause_blink_main.m from within the folder containing all scripts. As a result, a folder called data will be created on the same level as the BIDS and script folder in which intermediate data and figures will be stored (the intermediate data will amount to 1 GB, this process takes several minutes).
9) After you completely ran the analysis you can run specific parts again and skip others by changing the config structure within bjh_00_0_main_cEEGrid.m (1 means the analysis step will be run, 0 means it will be skipped).

If there are any remaining questions do not hesitate to contact me at bjoern.holtze[at]uol.de.
