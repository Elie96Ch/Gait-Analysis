% ************************************************************************
% * Copyright         : 2024 Elie Chebel
% * File Name         : full_GaitAnalysis.m
% * Description       : This code is used to load, process and return the
% results of Gait recordings (based on Xsens mocap and Delsys EMG data)
% *                    
% * Revision History  :
% * Date		Author 			Comments
% * ------------------------------------------------------------------
% * -/-/-	<>	<>
% ************************************************************************
%% Load all data
% Loading Xsens data (Use MVNX format)

[filename, ~] =uigetfile({'*.mvnx'},'File Selector','Select Xsens .mvnx file');
tree = load_mvnx(filename);
required_angles=["jRightHip","jRightKnee","jRightAnkle","jLeftHip","jLeftKnee","jLeftAnkle"];
xsens_processed = preprocess_XSENS(tree,'joint_angles',required_angles);

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
            disp('CSV file selected');
        otherwise
            disp('Unknown file format');
end

prep_EMG_data=preprocess_EMG(Channels, Data, Fs,'MV_window_size',100);
figure;
plot(prep_EMG_data.values.prep_NM(:,1))
legend(prep_EMG_data.headers)