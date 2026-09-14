%% This script is used to run preprocessing of all subjects with CONN toolbox

% add spm and conn to path
addpath('/scratch/data/p25ai0202/swat/mat_softs/spm');
addpath('/scratch/data/p25ai0202/swat/mat_softs/conn');
savepath;
tic

% Suppress specific warnings
setpref('MATLAB', 'UpdateCheck', 'off');
% Define the folder containing the subjects

data_folder ='/scratch/data/p25ai0202/swat/cam_data/raw_mv_bids/pt3';
cd(data_folder);

disp(data_folder);

% Get list of subjects
subjects = dir(fullfile(data_folder, 'sub-*'));
num_subjects = length(subjects);


% FIND functional/structural files
% note: this will look for all data in these folders, irrespestive of the specific download subsets entered as command-line arguments
NSUBJECTS=num_subjects;
cwd=pwd;
FUNCTIONAL_FILE=cellstr(conn_dir('sub-*epi_mov.nii'));
STRUCTURAL_FILE=cellstr(conn_dir('sub-*T1w.nii.gz'));
if rem(length(FUNCTIONAL_FILE),NSUBJECTS),error('mismatch number of functional files %n', length(FUNCTIONAL_FILE));end
if rem(length(STRUCTURAL_FILE),NSUBJECTS),error('mismatch number of anatomical files %n', length(FUNCTIONAL_FILE));end
nsessions=length(FUNCTIONAL_FILE)/NSUBJECTS;
FUNCTIONAL_FILE=reshape(FUNCTIONAL_FILE,[nsessions, NSUBJECTS]);
STRUCTURAL_FILE={STRUCTURAL_FILE{1:NSUBJECTS}};
disp([num2str(size(FUNCTIONAL_FILE,1)),' sessions']);
disp([num2str(size(FUNCTIONAL_FILE,2)),' subjects']);
TR=2.470; % Repetition time


% CONN-SPECIFIC SECTION: RUNS PREPROCESSING/SETUP/DENOISING/ANALYSIS STEPS
BATCH_SIZE = 16;
num_batches = ceil(NSUBJECTS / BATCH_SIZE);

% Run batches of subjects in groups of BATCH_SIZE
for batch_idx = 1:num_batches
    start_idx = (batch_idx - 1) * BATCH_SIZE + 1;
    end_idx = min(batch_idx * BATCH_SIZE, NSUBJECTS);
    NSUBJECTS_BATCH = end_idx - start_idx + 1;

    disp(['Processing batch ', num2str(batch_idx), ' of ', num2str(num_batches), ...
          ' (subjects ', num2str(start_idx), ' to ', num2str(end_idx), ')']);

    FUNCTIONAL_FILE_BATCH = FUNCTIONAL_FILE(:, start_idx:end_idx);
    STRUCTURAL_FILE_BATCH = STRUCTURAL_FILE(start_idx:end_idx);

    clear batch;
    batch.filename = fullfile(cwd, sprintf('Conn_Rest_camCAN_batch_%02d.mat', batch_idx));

    % SETUP & PREPROCESSING step (using default values for most parameters, see help conn_batch to define non-default values)
    batch.Setup.isnew = 1;
    batch.parallel.N = NSUBJECTS_BATCH; % number of parallel processing workers
    batch.parallel.profile = 'Background process (Unix,Mac)';
    batch.Setup.nsubjects = NSUBJECTS_BATCH;
    batch.Setup.RT = TR;                                        % TR (seconds)
    batch.Setup.functionals = repmat({{}}, [NSUBJECTS_BATCH, 1]);       % Point to functional volumes for each subject/session

    for nsub = 1:NSUBJECTS_BATCH
        for nses = 1:nsessions
            batch.Setup.functionals{nsub}{nses}{1} = FUNCTIONAL_FILE_BATCH{nses, nsub};
        end
    end
    batch.Setup.structurals = STRUCTURAL_FILE_BATCH;                  % Point to anatomical volumes for each subject

    nconditions = nsessions;                                  % treats each session as a different condition
    batch.Setup.conditions.names = {'movie'}; % condition name (can be anything, but must be consistent across subjects)
    for ncond = 1
        for nsub = 1:NSUBJECTS_BATCH
            for nses = 1:nsessions
                batch.Setup.conditions.onsets{ncond}{nsub}{nses} = 0;
                batch.Setup.conditions.durations{ncond}{nsub}{nses} = inf;
            end
        end
    end


    batch.Setup.preprocessing.steps = {'functional_realign&unwarp','functional_center', 'functional_slicetime', 'functional_art','structural_center', 'functional_segment&normalize_indirect','functional_smooth'};
    batch.Setup.preprocessing.removescans = 4; % remove initial scans
    batch.Setup.preprocessing.sliceorder = 'descending';
    batch.Setup.preprocessing.art_thresholds = [3, 0.5]; % global and motion thresholds "Conservative"
    batch.Setup.preprocessing.fwhm = 6; % smoothing kernel size (mm)
    batch.Setup.done = 1;
    batch.Setup.overwrite = 'Yes';

    % batch.Setup.analyses = 3; % voxel-to-voxel analysis not required

    % batch.Denoising.filter = [0.008, 0.1];
    batch.Denoising.despiking = 1;
    batch.Denoising.detrending = 1;
    batch.Denoising.regbp = 1;
    batch.Denoising.confounds.names = {'White Matter','CSF','realignment','scrubbing'};
    batch.Denoising.done = 1;
    batch.Denoising.overwrite = 'Yes';  % Ensure the specified denoising settings override any existing settings

    batch.QA.plots = [1 2 5 9 11 12];

    batch.Analysis.done = 0;
    batch.vvAnalysis.done = 0;
    batch.dynAnalysis.done = 0;
    batch.Results.done = 0;
    batch.vvResults.done = 0;

    conn_batch(batch);
    disp(['Batch ', num2str(batch_idx), ' completed']);
end

elapsed_time = toc;
elapsed_time = elapsed_time / 3600;

disp(['Elapsed time: ', num2str(elapsed_time), ' hours']);
