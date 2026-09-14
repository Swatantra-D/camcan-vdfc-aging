# camcan-vdfc-aging
codes for camcan vdfc slowing down paper

# codes
vdfc_extraction.m -> files extracts vdFC from preprocessed fMRI data. M/R/S are tasks such as movie, rest, and sensorimotor. The output is a .mat file containing the vdFC matrices for each subject and task.

vdfc_excel_output.m -> files takes the .mat file from vdfc_extraction.m and outputs an excel file with the vdFC matrices for each subject and task.

