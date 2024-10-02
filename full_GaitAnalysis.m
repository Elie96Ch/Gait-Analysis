% ************************************************************************
% * Copyright         : 2024 Elie Chebel
% * File Name         : full_GaitAnalysis.m
% * Description       : This code is used to load, process and return the
% results of Gait recordings (based on Xsens mocap and Delsys EMG data)
% *                    
% * Revision History  :
% * Date		Author 			Comments
% * ------------------------------------------------------------------
% * 01/09/2024	<Elie>	       <Secondary Functions Updated>
% ************************************************************************
%% Load all data
% Loading Xsens data (Use MVNX format)

[filename, ~] =uigetfile({'*.mvnx'},'File Selector','Select Xsens .mvnx file');
tree = load_mvnx(filename);
required_angles=["jRightHip","jRightKnee","jRightAnkle","jLeftHip","jLeftKnee","jLeftAnkle"];
xsens_preprocessed = preprocess_XSENS(tree,'joint_angles',required_angles,'filter_contacts',true);

%%
% Loading EMG data (Preferably in .mat, to load it in .xlsx or .csv make sure headers are not incuded in the file)

[filename, pathname] =uigetfile({'*.mat';'*.xlsx';'*.csv'},'File Selector','Select EMG file');
fullpath = fullfile(pathname, filename);
[~, ~, ext] = fileparts(fullpath);

switch lower(ext)
        case '.mat'
            disp('MAT-file selected');
          load(fullpath);
        case '.xlsx'
            disp('Excel file selected');
            emg_data=readtable(fullpath);
            Channels=string(emg_data.Properties.VariableNames(2:2:end))';
            Data=emg_data.Variables;Data=Data(:,2:2:end)';
            Time=emg_data.Variables;Time=Time(:,1:2:end)';
            for i=1:height(Time)
                Fs(i)=100/max(Time(i,101));
            end
        case '.csv'
            disp('CSV file selected (Not supported)');
        otherwise
            disp('Unknown file format');
end

prep_EMG_data=preprocess_EMG(Channels, Data, Fs,'MVC', true);
emg_param=get_emg_param(xsens_preprocessed,prep_EMG_data);

%%
% Save results
directory=uigetdir('Select where to save the figures');
save(strcat(directory,"/results.mat"),'xsens_preprocessed','prep_EMG_data','emg_param')

%% Plot and Save EMG

plot_and_save(emg_param,'emg','Mean_env','directory',directory,'saving',false)
plot_and_save(xsens_preprocessed,'xsens','Mean_env','directory',directory,'saving',false)
%%
close all
%% Parameters to prepare
% from xsens:
%     ROM
%     Min
%     Max
% Later: Gait parameters (Stride, step width ...)

% from EMG:
%     RMS(MeanEnvelope)
%     Peak activation (with mvc?)
% Later: Co-contraction



