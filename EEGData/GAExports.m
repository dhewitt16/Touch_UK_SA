
%% Short script to combine SA and UK Touch ERD data as a table in wide format.

% The input is two data files from BrushERDExport_theta.m or
% BrushERDExport.m = need to have been previously run for UK and SA data
% individually.

% Output is a table with 9 columns:
% Participants x FreqBand (first value 4, 8 or 16) x FreqBandName x
% Electrode (63) x ElectrodeName x SlowOther x SlowSelf x FastOther x
% FastSelf

% Danielle Hewitt, 19th May 2025

%=====================================================================

cfg.dir  = '/Users/dhewitt/OneDrive - Nexus365/Data/Touch/';
epochs = [0 500]; % 0 500, 0 700 or 500 3000
dateofExport = char("19-May-2025"); %data just in theta band from stim onset
%d = char("02-May-2024"); %all data

% =============== Finding the data

if isequal(epochs, [0 700]) || isequal(epochs, [0 500])
    fprintf(["Epoched data in theta band loading .... \nUsing timepoints specified \n"])

    cfg.UKfile = [cfg.dir 'UK/TouchStudy1/Preprocessed_0905/AllERD_UK1_theta_' num2str(epochs(1)) '-' num2str(epochs(2)) 'ms_' dateofExport '.xlsx'];
    cfg.SAfile = [cfg.dir 'SAData24/AllERD_SA_allpts_theta_' num2str(epochs(1)) '-' num2str(epochs(2)) 'ms_' dateofExport '.xlsx'];
    outname = [cfg.dir 'AllERD_UKandSA_theta_' num2str(epochs(1)) '-' num2str(epochs(2)) 'ms_' dateofExport '.xlsx'];

else

    fprintf("Epoched data in all bands loading .... \nUsing all timepoints from 0.5 to 3s \n")

    cfg.UKfile = [cfg.dir 'UK/TouchStudy1/Preprocessed_0905/AllERD_UK1_' dateofExport '.xlsx'];
    cfg.SAfile = [cfg.dir 'SAData24/AllERD_SA_allpts_' dateofExport '.xlsx'];
    outname = [cfg.dir 'AllERD_UKandSA_500-3000ms_' dateofExport '.xlsx'];

end

% =============== Loading the data and joining the files
UKdataTable =  readtable(cfg.UKfile);
SAdataTable =  readtable(cfg.SAfile);

AlldataTable = [SAdataTable; UKdataTable];

% =============== Saving the output
writetable(AlldataTable,outname);
disp(['Results saved to ' outname])