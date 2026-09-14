
% Script to generate dFC streams for all subjects
clear all; close all; clc;

%% paths and files
addpath("/scratch/data/p25ai0202/swat/mat_softs/dFCwalk-main");

% calculate time to run the script
tic;

output_path = "/scratch/data/p25ai0202/swat/cam_data/vdfc_results";

% new data from preprocessing pipeline
movie_dsk = load("/scratch/data/p25ai0202/swat/cam_data/time_series/TS_movie_dsk_2026-08-16_12-31-50.mat"); % dswau
rest_dsk = load("/scratch/data/p25ai0202/swat/cam_data/time_series/TS_rest_dsk_2026-08-18_11-46-59.mat"); % dswau
smt_dsk = load("/scratch/data/p25ai0202/swat/cam_data/time_series/TS_smt_dsk_2026-08-18_17-07-37.mat"); % dswau
movie_HCP = load("/scratch/data/p25ai0202/swat/cam_data/time_series/TS_movie_HCP_2026-08-15_18-15-51.mat"); % dswau
rest_HCP = load("/scratch/data/p25ai0202/swat/cam_data/time_series/TS_rest_HCP_2026-08-18_10-48-59.mat"); % dswau
smt_HCP = load("/scratch/data/p25ai0202/swat/cam_data/time_series/TS_smt_HCP_2026-08-18_18-16-57.mat"); % dswau

disp('Data loaded successfully.');

% time_series_data = movie_dsk.time_series;
time_series_data = movie_HCP.time_series;


size(time_series_data)

%% remove roi 1 and 36 from the time series data for desikan atlas only
% time_series_data(:, :, [1, 36]) = []; % Remove ROI 1 and 36 from the time series data
% size(time_series_data)

%% calculation of vdfcs
n_subj = size(time_series_data, 1);

window_sizes = 3:107; % Adjust this range based on your needs (e.g., 3:90 for all window sizes from 3 to 90)
lag = 1;
format = '3D';

% Option 1: Store only speeds and speed_series (RECOMMENDED - saves ~90% memory)
% Comment out if you need dfc_streams
STORE_DFC_STREAMS = false; % Set to true only if you need the full dFC streams

all_dfc_speeds = struct();
all_speed_series = struct();
if STORE_DFC_STREAMS
    all_dfc_streams = struct();
end

% Preallocate structure fields for better performance
for w_idx = 1:length(window_sizes)
    field_name = ['W' num2str(window_sizes(w_idx))];
    all_dfc_speeds.(field_name) = zeros(n_subj, 1);
    all_speed_series.(field_name) = cell(n_subj, 1);
    if STORE_DFC_STREAMS
        all_dfc_streams.(field_name) = cell(n_subj, 1);
    end
end

for w_idx = 1:length(window_sizes)
    W = window_sizes(w_idx);
    field_name = ['W' num2str(W)];
    fprintf('Processing window size W = %d (%d/%d)\n', W, w_idx, length(window_sizes));
    
    for subj = 1:n_subj
        % Progress indicator every 50 subjects
        if mod(subj, 50) == 0
            fprintf('  Subject %d/%d\n', subj, n_subj);
        end
        
        % Extract this subject's time series
        subj_ts = squeeze(time_series_data(subj, :, :));
    
        % Phase randomization (if needed, you can implement this here using the PhaseRand_surrogates function)
        % subj_ts = PhaseRand_surrogates(subj_ts, 1); % coherent phase rand Uncomment
        % subj_ts = PhaseRand_surrogates(subj_ts, 0); % incoherent phase rand Uncomment
        subj_ts(isnan(subj_ts)) = 0; % Handle any NaNs that may arise

        % Create dFC stream and calculate speeds
        dfc_stream = TS2dFCstream(subj_ts, W, lag, format);
        dfc_stream(isnan(dfc_stream)) = 0;
        
        [speed, speed_ser] = dFC_Speeds(dfc_stream, 1);
        speed_ser(isnan(speed_ser)) = 0;
        
        % Store results
        all_dfc_speeds.(field_name)(subj) = speed;
        all_speed_series.(field_name){subj} = speed_ser;
        
        if STORE_DFC_STREAMS
            all_dfc_streams.(field_name){subj} = dfc_stream;
        end
        
        % Clear intermediate variables to free memory immediately
        clear subj_ts dfc_stream speed speed_ser;
    end
    
    fprintf('Completed window size W = %d\n\n', W);
end

% clear time_series_data W w_idx subj field_name;

% Merge the structures into a single structure
merged_structure = struct();
merged_structure.all_dfc_speeds = all_dfc_speeds;
merged_structure.all_speed_series = all_speed_series;
if STORE_DFC_STREAMS
    merged_structure.all_dfc_streams = all_dfc_streams;
end

%Export the merged structure to a .mat file
fprintf('Saving results to file...\n');
time = datestr(now, 'HHMMddmmyyyy');
save(fullfile(output_path, ['vdFC_results_HCP_movie_dswau_W3_107_' num2str(time) '.mat']), '-struct', 'merged_structure', '-v7.3');
fprintf('Done! Results saved.\n');
toc; 
% time in minutes
fprintf('Total Time: %.2f minutes\n', toc/60);