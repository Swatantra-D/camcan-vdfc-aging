%% merge the files %%
clc; 
clear;

% load files
% Load new desikan atlas data
output_path = "/scratch/data/p25ai0202/swat/cam_data/vdfc_results";
rest_vdfc = load("/scratch/data/p25ai0202/swat/cam_data/vdfc_results/vDFC_results_RH_W3_107_094820082026.mat");
movie_vdfc = load("/scratch/data/p25ai0202/swat/cam_data/vdfc_results/vDFC_results_MH_W3_107_224519082026.mat");
smt_vdfc = load("/scratch/data/p25ai0202/swat/cam_data/vdfc_results/vDFC_results_SH_W3_107_063020082026.mat");

% Load Subject ID Files (Different sequences and counts)
rest_id_path = "/scratch/data/p25ai0202/swat/cam_data/time_series/subID_rst_HCP_2026-08-18_18-16-57.csv";
movie_id_path = "/scratch/data/p25ai0202/swat/cam_data/time_series/subID_movie_HCP_2026-08-15_18-15-51.csv";
smt_id_path = "/scratch/data/p25ai0202/swat/cam_data/time_series/subID_smt_dsk_2026-08-18_17-07-37.csv";

rest_subj_table = readtable(rest_id_path);
movie_subj_table = readtable(movie_id_path);
smt_subj_table = readtable(smt_id_path);

% Extract IDs from the first column and ensure they are formatted as a cell array of strings
rest_ids = cellstr(string(rest_subj_table{:, 1}));
movie_ids = cellstr(string(movie_subj_table{:, 1}));
smt_ids = cellstr(string(smt_subj_table{:, 1}));

%% Define Constants and Window Bins
conditions = {'rest', 'movie', 'smt'};
window_bin_labels = {'Short', 'Medium', 'Long'};
window_bins_smt_rst = {3:8, 8:30, 31:107}; 
window_bins_movie = {3:6, 7:24, 25:85}; 
window_bins_smt = {3:8, 8:30, 31:107}; 

timestamp = datestr(now, 'HHMMddmmyyyy');

%% Independent Processing per Condition
for cond_idx = 1:length(conditions)
    cond_name = conditions{cond_idx};
    
    % Dynamic assignment based on the specific condition
    if strcmp(cond_name, 'rest')
        condition_data = rest_vdfc.all_speed_series;
        window_bins = window_bins_smt_rst;
        sub_ids = rest_ids;
    elseif strcmp(cond_name, 'movie')
        condition_data = movie_vdfc.all_speed_series;
        window_bins = window_bins_movie;
        sub_ids = movie_ids;
    elseif strcmp(cond_name, 'smt')
        condition_data = smt_vdfc.all_speed_series;
        window_bins = window_bins_smt;
        sub_ids = smt_ids;
    end
    
    % Determine subject count dynamically for this condition
    n_subj = length(sub_ids);
    fprintf('\n=== Processing %s condition (%d subjects) ===\n', upper(cond_name), n_subj);
    
    % ------------------------------------------------------------------------
    % Step 1: Pool speeds per subject by window type
    % ------------------------------------------------------------------------
    cond_binned = struct();
    
    for bin_idx = 1:length(window_bins)
        bin_label = window_bin_labels{bin_idx};
        window_range = window_bins{bin_idx};
        
        binned_speeds = cell(n_subj, 1);
        
        for subj = 1:n_subj
            subject_speeds = [];
            for w = window_range
                field_name = ['W' num2str(w)];
                if isfield(condition_data, field_name) && ~isempty(condition_data.(field_name){subj})
                    subject_speeds = [subject_speeds; condition_data.(field_name){subj}];
                end
            end
            binned_speeds{subj} = subject_speeds;
        end
        
        cond_binned.(bin_label) = binned_speeds;
    end
    
    % Save condition-specific binned workspace
    save(fullfile(output_path, ['speed_series_binned_' cond_name '_' timestamp '.mat']), 'cond_binned', '-v7.3');
    
    % ------------------------------------------------------------------------
    % Step 2: Calculate central tendency metrics (Separately)
    % ------------------------------------------------------------------------
    cond_medians = struct();
    cond_means = struct();
    cond_sds = struct();
    
    for bin_idx = 1:length(window_bin_labels)
        bin_label = window_bin_labels{bin_idx};
        binned_data = cond_binned.(bin_label);
        
        medians = zeros(n_subj, 1);
        means = zeros(n_subj, 1);
        sds = zeros(n_subj, 1);
        
        for subj = 1:n_subj
            speeds = binned_data{subj};
            if ~isempty(speeds)
                medians(subj) = median(speeds);
                means(subj) = mean(speeds);
                sds(subj) = std(speeds);
            else
                medians(subj) = NaN; 
                means(subj) = NaN;
                sds(subj) = NaN;
            end
        end
        
        cond_medians.(bin_label) = medians;
        cond_means.(bin_label) = means;
        cond_sds.(bin_label) = sds;
    end
    
    % ------------------------------------------------------------------------
    % Step 3: Create separate Data Table and Export CSV
    % ------------------------------------------------------------------------
    all_data = {};
    row_idx = 1;
    
    for bin_idx = 1:length(window_bin_labels)
        bin_label = window_bin_labels{bin_idx};
        
        mean_vals = cond_means.(bin_label);
        median_vals = cond_medians.(bin_label);
        sd_vals = cond_sds.(bin_label);
        
        for subj = 1:n_subj
            all_data{row_idx, 1} = sub_ids{subj};       % Participant ID
            all_data{row_idx, 2} = cond_name;          % Condition Name
            all_data{row_idx, 3} = bin_label;          % Window type
            all_data{row_idx, 4} = mean_vals(subj);    % Mean
            all_data{row_idx, 5} = median_vals(subj);  % Median
            all_data{row_idx, 6} = sd_vals(subj);      % SD
            
            row_idx = row_idx + 1;
        end
    end
    
    % Convert to table with requested variables (Age/Sex removed)
    output_table = cell2table(all_data, 'VariableNames',{'ID', 'condition', 'window', 'vdfc_mean', 'vdfc_median', 'vdfc_sd'});
    
    % Export condition-specific CSV file
    csv_filename = fullfile(output_path, ['vdfc_central_tendency_' cond_name '_' timestamp '.csv']);
    writetable(output_table, csv_filename);
    
    fprintf('✓ CSV exported successfully (%d rows) to:\n%s\n', height(output_table), csv_filename);
end