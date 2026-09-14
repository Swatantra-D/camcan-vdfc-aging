## Code for parcellation and time series extraction from all of the ROIs ###

import datetime
import os
import re
import sys
import time
import glob
# import nilearn
import tempfile
import pandas as pd
import numpy as np
import datetime
# import seaborn as sns
# import matplotlib
# import nilearn.connectome
# import ipywidgets as widgets
# import matplotlib.pyplot as plt
# import jupyter_rfb


# from nilearn import masking
# from nilearn.maskers import *
# from joblib import Memory

# start the timer
start_time = time.time()

# relocating the temporary directory for joblib to a larger space
# Set temporary directory at the start of your script
# temp_dir = r"D:\temp_joblib"
# os.makedirs(temp_dir, exist_ok=True)

# # Set environment variables
# os.environ['TMPDIR'] = temp_dir
# os.environ['JOBLIB_TEMP_FOLDER'] = temp_dir
# os.environ['TEMP'] = temp_dir
# os.environ['TMP'] = temp_dir

# --- 1. CRITICAL: REDIRECT ALL TEMP DIRECTORIES BEFORE NILEARN JOBLIB STARTS ---
temp_dir = r"D:\temp_joblib"
os.makedirs(temp_dir, exist_ok=True)

# Force Python, Joblib, and Loky to use the D drive for memmapping
os.environ['TMPDIR'] = temp_dir
os.environ['JOBLIB_TEMP_FOLDER'] = temp_dir
os.environ['TEMP'] = temp_dir
os.environ['TMP'] = temp_dir

# Import nilearn AFTER environment variables are set
import nilearn
from joblib import Memory
from nilearn.maskers import MultiNiftiLabelsMasker, NiftiLabelsMasker

memory = Memory(temp_dir, verbose=1)
# # Override Python's default temp directory
# tempfile.tempdir = temp_dir

# print(f"Using temporary directory: {temp_dir}")

# # Create custom memory object
temp_dir = r"D:\temp_joblib"
os.makedirs(temp_dir, exist_ok=True)
memory = Memory(temp_dir, verbose=1)

## get the paths of the files

# data directories
# base_data_dir = r"G:\camcan\Rest_preproc"  # the base data directory
# base_data_dir = r"G:\camcan\Rest_preproc"  # the base data directory
base_data_dir = r"G:\camcan\mov_misc"
# getting the files
# folders = ['middle_mov_BIDS', 'young_mov_BIDS', 'old_mov_BIDS'] # not required since the data is not separated like that
# roi folder
roi_dir = r"D:\ROI_files\roi_files"
# get the atlas file
# atlas = "/iitjhome/r23ab0003/roi_files/schaefer_2018/Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.nii.gz"
atlas_2 = r"D:\ROI_files\roi_files\Desikan_space-MNI152NLin6_res-2x2x2.nii.gz" # get desikan atlas
nilearn_memory = r"D:\nilearn_temp"

# get all the files starting with "dswausub" (not just "dswausub-CC") for each group
file_list = []

data_dir = base_data_dir
file_pattern = os.path.join(data_dir,"*","*","sub-*", "func", "dswausub-CC*.nii*")
# file_patter2 = os.path.join(data_dir, "*", "sub-*", "epi_rest", "dswausub-CC*.nii*")
file_list.extend(glob.glob(file_pattern, recursive=True))
# sort the files
# file_list.sort()
file_pattern_2 = os.path.join(r"G:\camcan\movie_preproc\young\movie_exec_denoised", "dswausub-CC*.nii*")
file_pattern_3 = os.path.join(r"G:\camcan\movie_preproc\young",'grou*',"sub*", "func", "dswausub-CC*.nii*")
file_list.extend(glob.glob(file_pattern_2, recursive=True))
file_list.extend(glob.glob(file_pattern_3, recursive=True))
# file_pattern = os.path.join(data_dir, "dswausub-CC*.nii")
# save the 8 chars after "wausub-" as the subject id

# file_list = glob.glob(file_pattern,recursive=True)
# sort the files
# file_list.sort()
# get the number of files
num_files = len(file_list)

# check how many of these files are less than 50 MB in size
file_sizes = [os.path.getsize(file) for file in file_list]
small_files = [file for file, size in zip(file_list, file_sizes) if size < 50 * 1024 * 1024]

# exclude the small files from the file list
file_list = [file for file in file_list if file not in small_files]
print("Number of files after excluding small files:", len(file_list))

# add the correct 27 files to the file list
# folder = r"G:\camcan\rest"
# correct_list = []
# correct_list.extend(glob.glob(os.path.join(folder, "dswausub-CC*.nii*"), recursive=True))
# # merge the lists
# file_list.extend(correct_list)
# print("Number of files after merging with correct files:", len(file_list))

file_list.sort()
subject_ids = [file.split("-")[1][:8] for file in file_list]

# setup nifti masker
masker = MultiNiftiLabelsMasker(labels_img=atlas_2, standardize=False, detrend=True, memory=memory, verbose=1, n_jobs=8)
# masker_2 = NiftiLabelsMasker(labels_img=atlas_2, standardize=False, detrend=True, memory=memory, verbose=1)
# masker.fit(file_list[0])

# print("Masker fit done")
# print("number of files", num_files)
# masker fit and get the time series

# get the time series for all subjects
# time_series = masker.fit_transform(file_list)
time_series = []
final_subjects = []
error_subjects = []
# time_series_all_desikan = masker_2.fit_transform(file_list)

for file, subj_id in zip(file_list, subject_ids):
        try:
            ts = masker_2.fit_transform(file)
            time_series.append(ts)
            final_subjects.append(subj_id)
        # clear nilearn memory after each iteration to prevent memory overload
            masker_2.memory.clear(warn=False)
            print(f"Processed {file} (subject {subj_id})")
        except Exception as e:
            print(f"Error processing {file} (subject {subj_id})")
            error_subjects.append(subj_id)
            continue



# convert the time series to numpy array
# time_series_all = np.array(time_series)
time_series_all = masker.fit_transform(file_list)
time_series_all_desikan = np.array(time_series_all)
# time_series_all_desikan = np.array(time_series_all_desikan)
# save the time series to a file
# time_series_file = "/scratch/data/r23ab0003/dataset/camcan/raw_data/timesereis_files/time_series_schaefer_400.npy"
# np.save(time_series_file, time_series_all)
# add timestamp to the filename
timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
time_series_file_desikan = r"C:\Users\SWAT\Documents\data\time_series\time_series_movie_desikan_all_denoised_{}.npy".format(timestamp)
np.save(time_series_file_desikan, time_series_all_desikan)

# save the subject ids to a .csv file
subject_ids_file = r"C:\Users\SWAT\Documents\data\time_series\subject_ids_movie_desikan_all_denoised_{}.csv".format(timestamp)
# subject_ids_df = pd.DataFrame(subject_ids, columns=["subject_id"])
subject_ids_df = pd.DataFrame(final_subjects, columns=["subject_id"])
subject_ids_df.to_csv(subject_ids_file, index=False)
# print("Time series saved to", time_series_file)
print("Subject ids saved to", subject_ids_file)

# print the shape of the time series
# print("Time series shape", time_series_all.shape)
print("Subject ids shape", subject_ids_df.shape)

# print the subject ids
print(subject_ids_df)

end_time = time.time()
# print the time for the script to run
print("Script run time:", (end_time - start_time)/3600)
# error subjects
error_subjects_df = pd.DataFrame(error_subjects, columns=["subject_id"])
error_subjects_file = r"C:\Users\SWAT\Documents\data\time_series\error_subjects_movie_desikan_all_denoised_{}.csv".format(timestamp)
error_subjects_df.to_csv(error_subjects_file, index=False)

