# camcan-vdfc-aging
codes for camcan vdfc slowing down paper

# codes
[text](vdfc_extraction.m) -> files extracts vdFC from preprocessed fMRI data. M/R/S are tasks such as movie, rest, and sensorimotor. The output is a .mat file containing the vdFC matrices for each subject and task.

[text](vdfc_excel_out.m) -> files takes the .mat file from vdfc_extraction.m and outputs an excel file with the vdFC matrices for each subject and task.

[text](v_dfc_central_tendency_add_ageSex.ipynb) -> file finds the age and sex of each subject and adds it to the excel file created by vdfc_excel_output.m.

[text](vdfc_analysis.ipynb) -> file performs the age vs vdFC graphs for median/sd/mean values of vdfc for each tasks and window types.

