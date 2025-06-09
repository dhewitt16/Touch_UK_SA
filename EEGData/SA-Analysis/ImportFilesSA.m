%% This script imports BrainProducts EEG files in to EEGLAB and saves as .set files for preprocessing
% Dependencies: EEGLAB on path with BrainProducts import plugin installed
% Set directories for EEGLAB and data files
% Last updated by Danielle Hewitt, 2nd Jan 2024

%Set path for EEGLAB
eeglab_path = '/Users/dhewitt/Analysis/eeglab2022.1/'; %% change for the PC being used
addpath(genpath(eeglab_path));

%Specify subjects and main directory where data is stored
%subjects = {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15'};
subjects = {'19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
mainDirectory = ['/Users/dhewitt/Data/TouchStudy1/SAData24/'];

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

% Looping over all subjects
for i = 1:size(subjects,2)
    currentSubject = subjects{i};

    % Looping over all EEG files
    currentDirectory = [mainDirectory 'T1_' currentSubject '/'];
      %finding all EEG files in subject folder
    for j = 1:length(EEGfiles)
        currentEEGFile = EEGfiles(j).name; %defining current EEG file for import

        % Getting name of current file to make setname
        setfiles = split(currentEEGFile, '.'); % removing the .edf
        setName = char([setfiles(1)]);
        setName = strrep(setName, '2023', '');

        % Load into EEGLAB and save as .set file
        EEG = pop_biosig([currentDirectory currentEEGFile]);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',setName,'gui','off');
        eeglab redraw
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename',[setName '.set'],'filepath',currentDirectory);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

        disp(['Saved: ' currentEEGFile])

    end

end

disp('All done!'); %% if no files are generated, check the path is correct
