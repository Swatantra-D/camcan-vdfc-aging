## Code for parcellation and time series extraction from all of the ROIs ###
import datetime
import os
import re
import sys
import time
import glob
import scipy.io
# import nilearn
import tempfile
import pandas as pd
import numpy as np
import datetime

# start the timer
start_time = time.time()

# REDIRECT ALL TEMP DIRECTORIES BEFORE NILEARN JOBLIB STARTS ---
temp_dir = r"/scratch/data/p25ai0202/swat/tmp"
os.makedirs(temp_dir, exist_ok=True)

# Force Python, Joblib, and Loky to use the D drive for memmapping
os.environ['TMPDIR'] = temp_dir
os.environ['JOBLIB_TEMP_FOLDER'] = temp_dir
os.environ['TEMP'] = temp_dir
os.environ['TMP'] = temp_dir

# Import nilearn AFTER environment variables are set
import nilearn
from joblib import Memory
from nilearn.maskers import NiftiLabelsMasker

memory = Memory(temp_dir, verbose=1)
# Override Python's default temp directory
# tempfile.tempdir = temp_dir

# print(f"Using temporary directory: {temp_dir}")

# Create custom memory object
temp_dir = r"/scratch/data/p25ai0202/swat/tmp"
os.makedirs(temp_dir, exist_ok=True)
memory = Memory(temp_dir, verbose=1)

## get the paths of the files
base_data_dir = r"/scratch/data/p25ai0202/swat/cam_data/raw_mv_bids"  # the base data directory
roi_dir = r"/scratch/data/p25ai0202/swat/atlases" # roi dir
out_dir = r"/scratch/data/p25ai0202/swat/cam_data/time_series" # out dir
# get the atlas file
desikan_atlas = os.path.join(roi_dir, "Desikan_space-MNI152NLin6_res-2x2x2.nii.gz") # get desikan atlas
hcp_atlas = os.path.join(roi_dir, "MNI_Glasser_HCP_v1.0.nii.gz") # get hcp atlas
schaefer_atlas = os.path.join(roi_dir, "Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.nii.gz") # get schaefer atlas
nilearn_memory = memory

# get all the files starting with "dswausub" (not just "dswausub-CC") for each group
file_list = []

data_dir = base_data_dir # set data dir
file_pattern = os.path.join(data_dir,"*","sub-*", "func", "dswausub-CC*.nii*") # define file pattern
file_list.extend(glob.glob(file_pattern, recursive=True)) # search and extend the file list with the found files
num_files = len(file_list) # get the number of files found
print("Number of files found:", num_files)

# check how many of these files are less than 50 MB in size
file_sizes = [os.path.getsize(file) for file in file_list]
small_files = [file for file, size in zip(file_list, file_sizes) if size < 50 * 1024 * 1024]
# exclude the small files from the file list
file_list = [file for file in file_list if file not in small_files]
print("Number of files after excluding small files:", len(file_list))

file_list.sort()
# file_list = file_list[0:10] # test length
subject_ids = [file.split("-")[1][:8] for file in file_list]
# setup nifti masker
masker = NiftiLabelsMasker(labels_img=hcp_atlas, memory=memory, verbose=0)
masker.fit(file_list[0])

# Process files one-by-one to avoid nilearn concatenating all 4D runs into one huge array.
time_series_all = []
kept_subject_ids = []
error_files = []

for i, (fmri_file, subject_id) in enumerate(zip(file_list, subject_ids), start=1):
	try:
		ts = masker.transform(fmri_file)
		time_series_all.append(ts.astype(np.float32, copy=False))
		kept_subject_ids.append(subject_id)
		print(f"[{i}/{len(file_list)}] Extracted time series: {subject_id} -> {ts.shape}")
	except Exception as exc:
		error_files.append((subject_id, fmri_file, str(exc)))
		print(f"[{i}/{len(file_list)}] Failed: {subject_id} -> {exc}")

if not time_series_all:
	raise RuntimeError("No time series were extracted successfully.")

# saving
timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S") # add timestamp to the filename
time_series_file_hcp = os.path.join(out_dir, "time_series_movie_HCP_all_{}.npy".format(timestamp))
mat_file_hcp = time_series_file_hcp.replace(".npy", ".mat")
subject_ids_mat = np.array(kept_subject_ids, dtype=object).reshape(-1, 1) # subject ids list
unique_shapes = {arr.shape for arr in time_series_all}
if len(unique_shapes) == 1:
	time_series_all_np = np.stack(time_series_all, axis=0)
	scipy.io.savemat(mat_file_hcp, mdict={'time_series': time_series_all_np, 'subject_ids': subject_ids_mat}) # export as mat file
	np.save(time_series_file_hcp, time_series_all_np) # save as npy file
	print("Time series saved to", time_series_file_hcp)
	print("MAT file saved to", mat_file_hcp)
	print("Time series shape", time_series_all_np.shape)
else:
	ragged_file = time_series_file_hcp.replace(".npy", "_ragged.npy")
	time_series_ragged = np.array(time_series_all, dtype=object).reshape(-1, 1)
	np.save(ragged_file, np.array(time_series_all, dtype=object), allow_pickle=True)
	scipy.io.savemat(mat_file_hcp, mdict={'time_series': time_series_ragged, 'subject_ids': subject_ids_mat})
	print("Time series have varying shapes; saved ragged object array to", ragged_file)
	print("MAT file saved to", mat_file_desikan)
	print("Unique shapes:", sorted(unique_shapes))

# save the subject ids to a .csv file
# subject_ids_file = os.path.join(out_dir, "subject_ids_movie_HCP_all_denoised_{}.csv".format(timestamp))
subject_ids_df = pd.DataFrame(kept_subject_ids, columns=["subject_id"])
subject_ids_file = os.path.join(out_dir, "subject_ids_movie_HCP_all_denoised_{}.csv".format(timestamp))
subject_ids_df.to_csv(subject_ids_file, index=False)
# print("Time series saved to", time_series_file)
print("Subject ids saved to", subject_ids_file)
print("subject ids number", len(kept_subject_ids))

if error_files:
	error_df = pd.DataFrame(error_files, columns=["subject_id", "file", "error"])
	error_file = os.path.join(out_dir, "error_subjects_movie_HCP_all_denoised_{}.csv".format(timestamp))
	error_df.to_csv(error_file, index=False)
	print("Error file saved to", error_file)
	print("Number of failed subjects", len(error_files))

end_time = time.time()
print("Script run time:", (end_time - start_time)/3600) # print the time for the script to run

# error subjects
# error_subjects_df = pd.DataFrame(error_subjects, columns=["subject_id"])
# error_subjects_file = r"C:\Users\SWAT\Documents\data\time_series\error_subjects_movie_desikan_all_denoised_{}.csv".format(timestamp)
# error_subjects_df.to_csv(error_subjects_file, index=False)
