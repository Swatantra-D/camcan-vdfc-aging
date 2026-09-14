% Script to generate dFC results for movie HCP data
clear all; close all; clc;

% Paths and files
addpath('/scratch/data/p25ai0202/swat/mat_softs/dFCwalk-main');
tic;

output_path = '/scratch/data/p25ai0202/swat/cam_data/vdfc_results';
input_file = '/scratch/data/p25ai0202/swat/cam_data/time_series/TS_movie_HCP_2026-08-15_18-15-51.mat';
input_data = load(input_file);
time_series_data = input_data.time_series;
clear input_data;
disp('Movie HCP data loaded successfully.');

% Calculation of vDFCs
n_subj = size(time_series_data, 1);
window_sizes = 3:107;
lag = 1;
format = '3D';
STORE_DFC_STREAMS = false;

all_dfc_speeds = struct();
all_speed_series = struct();
if STORE_DFC_STREAMS
    all_dfc_streams = struct();
end

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
    fprintf('Processing W = %d (%d/%d)\n', W, w_idx, length(window_sizes));

    for subj = 1:n_subj
        subj_ts = squeeze(time_series_data(subj, :, :));
        subj_ts(isnan(subj_ts)) = 0;
        dfc_stream = TS2dFCstream(subj_ts, W, lag, format);
        dfc_stream(isnan(dfc_stream)) = 0;
        [speed, speed_ser] = dFC_Speeds(dfc_stream, 1);
        speed_ser(isnan(speed_ser)) = 0;

        all_dfc_speeds.(field_name)(subj) = speed;
        all_speed_series.(field_name){subj} = speed_ser;
        if STORE_DFC_STREAMS
            all_dfc_streams.(field_name){subj} = dfc_stream;
        end

        clear subj_ts dfc_stream speed speed_ser;
    end
end

merged_structure = struct();
merged_structure.all_dfc_speeds = all_dfc_speeds;
merged_structure.all_speed_series = all_speed_series;
if STORE_DFC_STREAMS
    merged_structure.all_dfc_streams = all_dfc_streams;
end

if ~exist(output_path, 'dir')
    mkdir(output_path);
end
time = datestr(now, 'HHMMddmmyyyy');
output_file = fullfile(output_path, ['vDFC_results_MH_W3_107_' num2str(time) '.mat']);
save(output_file, '-struct', 'merged_structure', '-v7.3');
fprintf('Results saved to %s\n', output_file);
fprintf('Total Time: %.2f minutes\n', toc / 60);