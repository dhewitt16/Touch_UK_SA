
%This program allows viewing of grand average TF data from the brushing
%experiment. It uploads four conditions (slow palm, slow arm, fast palm,
%fast arm), applies the ERD formula to the power data, and creates
%topoplots and time frequency plots showing grand average results.

%Originally by Andrej Stancak, 20/11/2020
%Last modified by Danielle Hewitt, 11/04/23

%=====================================================================
% Set paths for EEGLAB AND FIELDTRIP
eeglab_path = '/Users/dhewitt/Analysis/eeglab2023.1/'; addpath(eeglab_path); %eeglab;
fieldtrip_path = '/Users/dhewitt/Analysis/fieldtrip-20240110/'; addpath(fieldtrip_path); ft_defaults;
d = char(datetime('today'));
%=====================================================================
close all;

cfg  = [];
cfg.sadir  = '/Users/dhewitt/OneDrive - Nexus365/Data/Touch/SAData24/';
cfg.ukdir  = '/Users/dhewitt/OneDrive - Nexus365/Data/Touch/UK/TouchStudy1/Preprocessed_0905/';

%cfg.uksub  = {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15'};
%cfg.sasub = {'20','21','24','26','28','29','30','31','32','33','35','36', '38'};

cfg.uksub  = 1:15;
cfg.sasub = 16:28;

cfg.conds = {'sPalm', 'sArm', 'fPalm', 'fArm'};

alpha = [8 13]; beta = [16 24]; theta = [4 7]; %setting frequency bands of interest
%prefrontal = {'Fp1','Fp2','AFz'}; frontal = {'F1', 'F2', 'F3', 'F4'}; central = {'C3', 'C1', 'Cz', 'C2', 'C4'}; parietal = {'P3', 'P1', 'Pz', 'P2', 'P4'}; temporal = {'T7', 'T8'}; occipital = {'O1','O2'}; %optional electrode clusters

cfg.jointElectrodes = {'Fp1','F3','F7','FC5','FC1','C3','T7','CP5','CP1','Pz','P3','P7','O1', ...
    'Oz','O2','P4','P8','CP6','CP2','Cz','C4','T8','FC6','FC2','F4','F8','Fp2','AF7','AF3','F1','F5','FT7', ...
    'FC3','C1','C5','TP7','CP3','P1','P5','PO7','PO3','POz','PO4','PO8','P6','P2','CPz','CP4','TP8','C6','C2','FC4','FT8','F6','AF8','AF4','F2','FCz'};

cfg.fband = theta; %change to determine which band to run on = run for each band of interest

%=====================================================================
%%Statistics and figures
cfg.el = {'C3','C1','C2','C4','CP3', 'CP1', 'CP2','CP4'}; %type in electrodes themselves or choose a cluster
cfg.epochTime = [0. 0.5]; %for stats
cfg.baselineTime = [-2 -1]; %for baseline correction
cfg.plotTime = [-2 3];
cfg.scale = 20; %scale for figures

%=====================================================================

%loads .mat containing D struct with all pts data if script has already been
%run. Also loads Gfreq and Gtime arrays

Gname = [cfg.sadir 'Touch_SA_allspectra_no19-22-23-25-27-34_0205.mat'];
load(Gname); D_SA = D;

Gname = [cfg.ukdir 'Touch_allspectra_020524.mat'];
load(Gname); D_UK = D;

G.bfArm.time = Gtime;
G.bfArm.freq = Gfreq;

% Get indices of shared electrodes in both datasets
[~, idx_UK] = ismember(cfg.jointElectrodes, D_UK.label);
[~, idx_SA] = ismember(cfg.jointElectrodes, D_SA.label);

% Extract the data for shared electrodes
slowPalm_UK = D_UK.slowPalm(idx_UK, :, :, :);
slowArm_UK = D_UK.slowArm(idx_UK, :, :, :);
fastPalm_UK = D_UK.fastPalm(idx_UK, :, :, :);
fastArm_UK = D_UK.fastArm(idx_UK, :, :, :);

slowPalm_SA = D_SA.slowPalm(idx_SA, :, :, :);
slowArm_SA = D_SA.slowArm(idx_SA, :, :, :);
fastPalm_SA = D_SA.fastPalm(idx_SA, :, :, :);
fastArm_SA = D_SA.fastArm(idx_SA, :, :, :);

% Concatenate the data across participants
slowPalm_combined = cat(4, slowPalm_UK, slowPalm_SA);
slowArm_combined = cat(4, slowArm_UK, slowArm_SA);
fastPalm_combined = cat(4, fastPalm_UK, fastPalm_SA);
fastArm_combined = cat(4, fastArm_UK, fastArm_SA);

%=========================================================================

E = readlocs('/Users/dhewitt/GitHub/TouchStudy/EEG_Data_Preprocessing/SA-UK Collaboration/SA-Analysis/jointels.sfp');

s1=nearest(Gtime,cfg.epochTime(1)); %getting time windows
s2=nearest(Gtime,cfg.epochTime(2));
allt = [nearest(Gtime,cfg.plotTime(1)), nearest(Gtime,cfg.plotTime(2))];

f1=nearest(Gfreq,cfg.fband(1)); %getting freq band
f2=nearest(Gfreq,cfg.fband(2));

% Average over the frequency band and time window
VslowPalm = squeeze(mean(slowPalm_combined(:,f1:f2,:,:),2)); %averaging over freq band
VslowPalm = squeeze(mean(VslowPalm(:,s1:s2,:),2)); %averaging over time window - now 63 els x pts

VslowArm = squeeze(mean(slowArm_combined(:,f1:f2,:,:),2));
VslowArm = squeeze(mean(VslowArm(:,s1:s2,:),2));

VfastPalm = squeeze(mean(fastPalm_combined(:,f1:f2,:,:),2));
VfastPalm = squeeze(mean(VfastPalm(:,s1:s2,:),2));

VfastArm = squeeze(mean(fastArm_combined(:,f1:f2,:,:),2));
VfastArm = squeeze(mean(VfastArm(:,s1:s2,:),2));

%==========================================================================

% Plotting the topoplots for grand averages for all conditions
figure('Name', 'Grand average topoplots for each condition');

subplot(2,2,1);
topoplot(mean(VslowPalm, 2), E, 'style', 'map', 'maplimits', [-cfg.scale cfg.scale]);
colormap(flipud(jet)); colorbar;
title('All Slow Palm');

subplot(2,2,2);
topoplot(mean(VslowArm, 2), E, 'style', 'map', 'maplimits', [-cfg.scale cfg.scale]);
colormap(flipud(jet)); colorbar;
title('All Slow Arm');

subplot(2,2,3);
topoplot(mean(VfastPalm, 2), E, 'style', 'map', 'maplimits', [-cfg.scale cfg.scale]);
colormap(flipud(jet)); colorbar;
title('All Fast Palm');

subplot(2,2,4);
topoplot(mean(VfastArm, 2), E, 'style', 'map', 'maplimits', [-cfg.scale cfg.scale]);
colormap(flipud(jet)); colorbar;
title('All Fast Arm');

%%making fig for av speed and av loc
figure('Name','Grand average topoplots for av conditions');

AvSlow = ((VslowPalm+VslowArm)./2);
AvFast = ((VfastPalm+VfastArm)./2);
AvPalm = ((VslowPalm+VfastPalm)./2);
AvArm = ((VslowArm+VfastArm)./2);

subplot(2,2,1);
topoplot(mean(AvSlow,2),E,'style','map','maplimits',[-cfg.scale cfg.scale]); 
colormap(flipud(jet)); colorbar;
title('All Slow Av');

subplot(2,2,2);
topoplot(mean(AvFast,2),E,'style','map','maplimits',[-cfg.scale cfg.scale]); 
colormap(flipud(jet)); colorbar;
title('All Fast Av');

subplot(2,2,3);
topoplot(mean(AvPalm,2),E,'style','map','maplimits',[-cfg.scale cfg.scale]); 
colormap(flipud(jet)); colorbar;
title('All Palm Av');

subplot(2,2,4);
topoplot(mean(AvArm,2),E,'style','map','maplimits',[-cfg.scale cfg.scale]); 
colormap(flipud(jet)); colorbar;
title('All Arm Av');

%==========================================================================

% Plotting the topoplots for grand averages for all conditions for UK
figure('Name', 'Grand average topoplots for each condition - UK');

subplot(2,2,1);
topoplot(mean(VslowPalm(:,cfg.uksub), 2), E, 'style', 'map', 'maplimits', [-cfg.scale cfg.scale]);
colormap(flipud(jet)); colorbar;
title('UK Slow Palm');

subplot(2,2,2);
topoplot(mean(VslowArm(:,cfg.uksub), 2), E, 'style', 'map', 'maplimits', [-cfg.scale cfg.scale]);
colormap(flipud(jet)); colorbar;
title('UK Slow Arm');

subplot(2,2,3);
topoplot(mean(VfastPalm(:,cfg.uksub), 2), E, 'style', 'map', 'maplimits', [-cfg.scale cfg.scale]);
colormap(flipud(jet)); colorbar;
title('UK Fast Palm');

subplot(2,2,4);
topoplot(mean(VfastArm(:,cfg.uksub), 2), E, 'style', 'map', 'maplimits', [-cfg.scale cfg.scale]);
colormap(flipud(jet)); colorbar;
title('UK Fast Arm');

%%making fig for av speed and av loc
figure('Name','Grand average topoplots for av conditions - UK');

AvSlow = ((VslowPalm+VslowArm)./2);
AvFast = ((VfastPalm+VfastArm)./2);
AvPalm = ((VslowPalm+VfastPalm)./2);
AvArm = ((VslowArm+VfastArm)./2);

subplot(2,2,1);
topoplot(mean(AvSlow(:,cfg.uksub),2),E,'style','map','maplimits',[-cfg.scale cfg.scale]); 
colormap(flipud(jet)); colorbar;
title('UK Slow Av');

subplot(2,2,2);
topoplot(mean(AvFast(:,cfg.uksub),2),E,'style','map','maplimits',[-cfg.scale cfg.scale]); 
colormap(flipud(jet)); colorbar;
title('UK Fast Av');

subplot(2,2,3);
topoplot(mean(AvPalm(:,cfg.uksub),2),E,'style','map','maplimits',[-cfg.scale cfg.scale]); 
colormap(flipud(jet)); colorbar;
title('UK Palm Av');

subplot(2,2,4);
topoplot(mean(AvArm(:,cfg.uksub),2),E,'style','map','maplimits',[-cfg.scale cfg.scale]); 
colormap(flipud(jet)); colorbar;
title('UK Arm Av');

%==========================================================================

% Plotting the topoplots for grand averages for all conditions for SA
figure('Name', 'Grand average topoplots for each condition - SA');

subplot(2,2,1);
topoplot(mean(VslowPalm(:,cfg.sasub), 2), E, 'style', 'map', 'maplimits', [-cfg.scale cfg.scale]);
colormap(flipud(jet)); colorbar;
title('SA Slow Palm');
subplot(2,2,2);
topoplot(mean(VslowArm(:,cfg.sasub), 2), E, 'style', 'map', 'maplimits', [-cfg.scale cfg.scale]);
colormap(flipud(jet)); colorbar;
title('SA Slow Arm');
subplot(2,2,3);
topoplot(mean(VfastPalm(:,cfg.sasub), 2), E, 'style', 'map', 'maplimits', [-cfg.scale cfg.scale]);
colormap(flipud(jet)); colorbar;
title('SA Fast Palm');
subplot(2,2,4);
topoplot(mean(VfastArm(:,cfg.sasub), 2), E, 'style', 'map', 'maplimits', [-cfg.scale cfg.scale]);
colormap(flipud(jet)); colorbar;
title('SA Fast Arm');

%%making fig for av speed and av loc
figure('Name','Grand average topoplots for av conditions - SA');

AvSlow = ((VslowPalm+VslowArm)./2);
AvFast = ((VfastPalm+VfastArm)./2);
AvPalm = ((VslowPalm+VfastPalm)./2);
AvArm = ((VslowArm+VfastArm)./2);

subplot(2,2,1);
topoplot(mean(AvSlow(:,cfg.sasub),2),E,'style','map','maplimits',[-cfg.scale cfg.scale]); 
colormap(flipud(jet)); colorbar;
title('SA Slow Av');

subplot(2,2,2);
topoplot(mean(AvFast(:,cfg.sasub),2),E,'style','map','maplimits',[-cfg.scale cfg.scale]); 
colormap(flipud(jet)); colorbar;
title('SA Fast Av');

subplot(2,2,3);
topoplot(mean(AvPalm(:,cfg.sasub),2),E,'style','map','maplimits',[-cfg.scale cfg.scale]); 
colormap(flipud(jet)); colorbar;
title('SA Palm Av');

subplot(2,2,4);
topoplot(mean(AvArm(:,cfg.sasub),2),E,'style','map','maplimits',[-cfg.scale cfg.scale]); 
colormap(flipud(jet)); colorbar;
title('SA Arm Av');

%==========================================================================

%figure('Name','TFR plots averaged over chosen electrodes');
%GAPall = squeeze(mean(GERDall(EL,:,:,:,:,:),1));

slowPalm_av = squeeze(mean(slowPalm_combined,1));
slowArm_av = squeeze(mean(slowArm_combined,1));
fastPalm_av = squeeze(mean(fastPalm_combined,1));
fastArm_av = squeeze(mean(fastArm_combined,1));

slowPalm_all = squeeze(mean(slowPalm_av,3));
slowArm_all = squeeze(mean(slowArm_av,3));
fastPalm_all = squeeze(mean(fastPalm_av,3));
fastArm_all = squeeze(mean(fastArm_av,3));

figure('Name','TFR plots averaged over all electrodes');
subplot(2,2,1); imagesc(slowPalm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Slow Palm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56], [1 50], 'Color', 'k', 'LineWidth', 1); hold off; axis xy; % adds lines at cue start and end
sample_ticks = ax.XLim(1):10:ax.XLim(2); time_ticks = Gtime(sample_ticks); ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');

subplot(2,2,2); imagesc(slowArm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Slow Arm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56],[1 50], 'Color', 'k', 'LineWidth', 1); hold off; axis xy; ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');

subplot(2,2,3); imagesc(fastPalm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Fast Palm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56], [1 50], 'Color', 'k', 'LineWidth', 1); hold off; axis xy; ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');

subplot(2,2,4); imagesc(fastArm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Fast Arm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56], [1 50], 'Color', 'k', 'LineWidth', 1); hold off;  axis xy; ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');
colormap(flipud(parula));

%%%%%%%%%%%%%%%%%%%%%%%

%This section extrxts the indices of all valid electrode labels in cfg.el
%==========================================================================
EL = [];
for j=1:size(cfg.el,2)
    for k=1:length(E)
        if strcmp(cfg.el{j},E(k).labels)==1
            EL = [EL k];
        end
    end
end
%==========================================================================

slowPalm_selel = squeeze(mean(slowPalm_combined(EL,:,:,:,:,:),1));
slowArm_selel = squeeze(mean(slowArm_combined(EL,:,:,:,:,:),1));
fastPalm_selel = squeeze(mean(fastPalm_combined(EL,:,:,:,:,:),1));
fastArm_selel = squeeze(mean(fastArm_combined(EL,:,:,:,:,:),1));

slowPalm_all = squeeze(mean(slowPalm_selel,3));
slowArm_all = squeeze(mean(slowArm_selel,3));
fastPalm_all = squeeze(mean(fastPalm_selel,3));
fastArm_all = squeeze(mean(fastArm_selel,3));

all_all = (slowPalm_all+slowArm_all+fastPalm_all+fastArm_all)./4;

cfg.scale = 20;

figure('Name','TFR plots averaged over chosen electrodes');
subplot(2,2,1); imagesc(slowPalm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Slow Palm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56], [1 50], 'Color', 'k', 'LineWidth', 1); hold off; axis xy; % adds lines at cue start and end
sample_ticks = ax.XLim(1):10:ax.XLim(2); time_ticks = Gtime(sample_ticks); ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');

subplot(2,2,2); imagesc(slowArm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Slow Arm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56],[1 50], 'Color', 'k', 'LineWidth', 1); hold off; axis xy; ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');

subplot(2,2,3); imagesc(fastPalm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Fast Palm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56], [1 50], 'Color', 'k', 'LineWidth', 1); hold off; axis xy; ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');

subplot(2,2,4); imagesc(fastArm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Fast Arm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56], [1 50], 'Color', 'k', 'LineWidth', 1); hold off;  axis xy; ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');
colormap(flipud(parula));

%==========================================================================

figure('Name','GA TFR plots averaged over chosen electrodes');
imagesc(all_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Grand Average Touch'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56], [1 50], 'Color', 'k', 'LineWidth', 1); hold off;  axis xy; ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');
colormap(flipud(parula));

%==========================================================================
%%% UK TF Plot

slowPalm_all = squeeze(mean(slowPalm_selel(:,:,cfg.uksub),3));
slowArm_all = squeeze(mean(slowArm_selel(:,:,cfg.uksub),3));
fastPalm_all = squeeze(mean(fastPalm_selel(:,:,cfg.uksub),3));
fastArm_all = squeeze(mean(fastArm_selel(:,:,cfg.uksub),3));

all_all = (slowPalm_all+slowArm_all+fastPalm_all+fastArm_all)./4;

cfg.scale = 20;

figure('Name','UK TFR plots averaged over chosen electrodes');
subplot(2,2,1); imagesc(slowPalm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Slow Palm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56], [1 50], 'Color', 'k', 'LineWidth', 1); hold off; axis xy; % adds lines at cue start and end
sample_ticks = ax.XLim(1):10:ax.XLim(2); time_ticks = Gtime(sample_ticks); ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');

subplot(2,2,2); imagesc(slowArm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Slow Arm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56],[1 50], 'Color', 'k', 'LineWidth', 1); hold off; axis xy; ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');

subplot(2,2,3); imagesc(fastPalm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Fast Palm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56], [1 50], 'Color', 'k', 'LineWidth', 1); hold off; axis xy; ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');

subplot(2,2,4); imagesc(fastArm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Fast Arm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56], [1 50], 'Color', 'k', 'LineWidth', 1); hold off;  axis xy; ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');
colormap(flipud(parula));

%==========================================================================
%%% SA TF Plot

slowPalm_all = squeeze(mean(slowPalm_selel(:,:,cfg.sasub),3));
slowArm_all = squeeze(mean(slowArm_selel(:,:,cfg.sasub),3));
fastPalm_all = squeeze(mean(fastPalm_selel(:,:,cfg.sasub),3));
fastArm_all = squeeze(mean(fastArm_selel(:,:,cfg.sasub),3));

all_all = (slowPalm_all+slowArm_all+fastPalm_all+fastArm_all)./4;

cfg.scale = 20;

figure('Name','SA TFR plots averaged over chosen electrodes');
subplot(2,2,1); imagesc(slowPalm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Slow Palm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56], [1 50], 'Color', 'k', 'LineWidth', 1); hold off; axis xy; % adds lines at cue start and end
sample_ticks = ax.XLim(1):10:ax.XLim(2); time_ticks = Gtime(sample_ticks); ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');

subplot(2,2,2); imagesc(slowArm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Slow Arm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56],[1 50], 'Color', 'k', 'LineWidth', 1); hold off; axis xy; ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');

subplot(2,2,3); imagesc(fastPalm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Fast Palm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56], [1 50], 'Color', 'k', 'LineWidth', 1); hold off; axis xy; ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');

subplot(2,2,4); imagesc(fastArm_all,[-cfg.scale, cfg.scale]); ax=gca; ax.XLim = allt; ax.YLim = [1 50]; set(gca,'XLim',ax.XLim,'YLim',ax.YLim); title('Fast Arm'); colorbar;
hold on; line([26 26], [1 50], 'Color', 'k', 'LineWidth', 1); hold on; line([56 56], [1 50], 'Color', 'k', 'LineWidth', 1); hold off;  axis xy; ax.XTick = sample_ticks; ax.XTickLabel = time_ticks; xlabel('Time (s)');
colormap(flipud(parula));