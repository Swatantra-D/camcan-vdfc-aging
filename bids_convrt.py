import os
import shutil

raw_rest = r"/scratch/data/p25ai0202/swat/cam_data/Raw_rest"
raw_mov = r"/scratch/data/p25ai0202/swat/cam_data/raw_mv_bids"

# Only subjects present in both folders
subjects_rest = {
    d for d in os.listdir(raw_rest)
    if os.path.isdir(os.path.join(raw_rest, d))}
subjects_mov = {
    d for d in os.listdir(raw_mov)
    if os.path.isdir(os.path.join(raw_mov, d))}

common_subjects = sorted(subjects_rest & subjects_mov)

for subject in common_subjects:
    mov_subject_path = os.path.join(raw_mov, subject)
    func_path = os.path.join(mov_subject_path, "func")
    anat_path = os.path.join(mov_subject_path, "anat")

    os.makedirs(func_path, exist_ok=True)
    os.makedirs(anat_path, exist_ok=True)

    # Move all files from the subject folder into func and rename them
    for item in os.listdir(mov_subject_path):
        item_path = os.path.join(mov_subject_path, item)
        if os.path.isfile(item_path):
            # Extract file extension (handles double extensions like .nii.gz)
            if item.endswith(".nii"):
                ext = ".nii"
            else:
                _, ext = os.path.splitext(item)
            
            # Construct new filename: <subject>_epi_mov.<ext>
            new_name = f"{subject}_epi_mov{ext}"
            dst_path = os.path.join(func_path, new_name)

            shutil.move(item_path, dst_path)

    # Copy anat from Raw_rest/<subject>/anat into Raw_smt/<subject>/anat
    rest_anat_path = os.path.join(raw_rest, subject, "anat")
    if os.path.isdir(rest_anat_path):
        for item in os.listdir(rest_anat_path):
            src = os.path.join(rest_anat_path, item)
            dst = os.path.join(anat_path, item)
            if os.path.isfile(src):
                shutil.copy2(src, dst)
