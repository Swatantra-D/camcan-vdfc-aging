%% Script to re-run ONLY Denoising (No Bandpass Filtering, No Preprocessing)
% add spm and conn to path
addpath("C:\Users\SWAT\Documents\MATLAB\toolboxes\conn");
addpath("C:\Users\SWAT\Documents\MATLAB\toolboxes\spm");
savepath;

tic
setpref('MATLAB', 'UpdateCheck', 'off');

% Define project file path
project_file = 'G:\camcan\rest_test_conn\Conn_Rest_camCAN_single_batch.mat';

if ~exist(project_file, 'file')
    error('Project file not found at: %s', project_file);
end

disp(['Loading project: ', project_file]);

clear batch;

% Target the single project file
batch.filename = project_file;

% Skip Setup/Preprocessing entirely
batch.Setup.done = 0;

% DENOISING CONFIGURATION
batch.Denoising.filter = [0, inf]; % [0, inf] disables bandpass filtering
batch.Denoising.despiking = 1;
batch.Denoising.detrending = 1;
batch.Denoising.regbp = 1;
batch.Denoising.confounds.names = {'White Matter', 'CSF', 'realignment', 'scrubbing'};

% Execute Denoising step only
batch.Denoising.done = 1;
batch.Denoising.overwrite = 'Yes'; % Overwrite previous denoising results

% Keep downstream analyses disabled
batch.Analysis.done = 0;
batch.vvAnalysis.done = 0;
batch.dynAnalysis.done = 0;
batch.Results.done = 0;
batch.vvResults.done = 0;

% Run CONN batch
conn_batch(batch);

disp('Denoising step completed.');

elapsed_time = toc / 3600;
disp(['Total elapsed time: ', num2str(elapsed_time), ' hours']);                 