% Load the "results" file
load(uigetfile('*.mat'));
%% create the xsens table

var_names_kinematics=["Mean ROM ABD/ADD","Mean ROM INT/EXT","Mean ROM FLEX/EXT",...
    "std ROM ABD/ADD","std ROM INT/EXT","std ROM FLEX/EXT",...
    "Mean MAX ABD/ADD","Mean MAX INT/EXT","Mean MAX FLEX/EXT",...
    "std MAX ABD/ADD","std MAX INT/EXT","std MAX FLEX/EXT",...
    "Mean MIN ABD/ADD","Mean MIN INT/EXT","Mean MIN FLEX/EXT",...
    "std MIN ABD/ADD","std MIN INT/EXT","std MIN FLEX/EXT"];
% load the joint names
joint_names=string(fieldnames(xsens_processed));
joint_names(1:2,:)=[];


All_res_RC=[];
for j=1:length(joint_names)
    ROM_temp=[];MAX_temp=[];MIN_temp=[];
    for i=1:xsens_processed.cycles(1)% Right cycles
        eval(strcat("ROM_temp=[ROM_temp;cell2mat(xsens_processed.",joint_names(j),".RCycles(4,i))];"))
        eval(strcat("MAX_temp=[MAX_temp;cell2mat(xsens_processed.",joint_names(j),".RCycles(3,i))];"))
        eval(strcat("MIN_temp=[MIN_temp;cell2mat(xsens_processed.",joint_names(j),".RCycles(2,i))];"))
    end
    All_res_RC=[All_res_RC;[mean(ROM_temp),std(ROM_temp),...
    mean(MAX_temp),std(MAX_temp),...
    mean(MIN_temp),std(MIN_temp)]];
    
end


tbl_kinematics_rc=array2table(All_res_RC,'VariableNames',var_names_kinematics);
All_res_LC=[];
for j=1:length(joint_names)
    ROM_temp=[];MAX_temp=[];MIN_temp=[];
    for i=1:xsens_processed.cycles(2)% Left cycles
        eval(strcat("ROM_temp=[ROM_temp;cell2mat(xsens_processed.",joint_names(j),".LCycles(4,i))];"))
        eval(strcat("MAX_temp=[MAX_temp;cell2mat(xsens_processed.",joint_names(j),".LCycles(3,i))];"))
        eval(strcat("MIN_temp=[MIN_temp;cell2mat(xsens_processed.",joint_names(j),".LCycles(2,i))];"))
    end
    All_res_LC=[All_res_LC;[mean(ROM_temp),std(ROM_temp),...
    mean(MAX_temp),std(MAX_temp),...
    mean(MIN_temp),std(MIN_temp)]];
    
end
tbl_kinematics_lc=array2table(All_res_LC,'VariableNames',var_names_kinematics);
%% create the EMG table
% load the muscle names
muscle_names=string(fieldnames(emg_param));

var_names_EMG=["mean_Mean_env","std_Mean_env",...
    "mean_Peak","std_Peak",...
    "mean_RMS","std_RMS"];

All_res_RC=[];
for m=1:length(muscle_names)

    ENV_temp=[]; 
    for c=1:xsens_processed.cycles(1) % Right cycles
        eval(strcat("ENV_temp=[ENV_temp;mean(emg_param.",muscle_names(m),".RC.env{1,c})];"))
        
    end
    eval(strcat("Peak_mean=mean(cell2mat(emg_param.",muscle_names(m),".RC.envPeak));"))
    eval(strcat("Peak_std=std(cell2mat(emg_param.",muscle_names(m),".RC.envPeak));"))
    eval(strcat("RMS_mean=mean(cell2mat(emg_param.",muscle_names(m),".RC.envRMS));"))
    eval(strcat("RMS_std=std(cell2mat(emg_param.",muscle_names(m),".RC.envRMS));"))
    All_res_RC=[All_res_RC;[mean(ENV_temp),std(ENV_temp),...
    Peak_mean,Peak_std,...
    RMS_mean,RMS_std]];

end
tbl_EMG_rc=array2table(All_res_RC,'VariableNames',var_names_EMG);

All_res_LC=[];
for m=1:length(muscle_names)

    ENV_temp=[]; Peak_temp=[]; RMS_temp=[];
    for c=1:xsens_processed.cycles(2) % Left cycles
        eval(strcat("ENV_temp=[ENV_temp;mean(emg_param.",muscle_names(m),".LC.env{1,c})];"))
        
    end
    eval(strcat("Peak_mean=mean(cell2mat(emg_param.",muscle_names(m),".LC.envPeak));"))
    eval(strcat("Peak_std=std(cell2mat(emg_param.",muscle_names(m),".LC.envPeak));"))
    eval(strcat("RMS_mean=mean(cell2mat(emg_param.",muscle_names(m),".LC.envRMS));"))
    eval(strcat("RMS_std=std(cell2mat(emg_param.",muscle_names(m),".LC.envRMS));"))
    All_res_LC=[All_res_LC;[mean(ENV_temp),std(ENV_temp),...
    Peak_mean,Peak_std,...
    RMS_mean,RMS_std]];

end
tbl_EMG_lc=array2table(All_res_LC,'VariableNames',var_names_EMG);



%%
drct=uigetdir();
userInput = inputdlg({'Enter subject name:', 'Enter speed:', 'Enter trial number and brace status:'},...
    'Input Variables', [1, 1, 1]);

OutFilename = strcat(drct,'\',...
    userInput{1},'_',userInput{2},'kmh_',userInput{3},'.xlsx');

%% Write the table to Excel
writetable([array2table(joint_names,...
    'VariableNames',{'Joint Name'}) tbl_kinematics_rc], OutFilename,...
    'Sheet', 'Right Cycles','Range','A1');
writetable([array2table(muscle_names,...
    'VariableNames',{'Muscle Name'}) tbl_EMG_rc], OutFilename,...
    'Sheet', 'Right Cycles','Range','A15');
writetable([array2table(joint_names,...
    'VariableNames',{'Joint Name'}) tbl_kinematics_lc], OutFilename,...
    'Sheet', 'Left Cycles','Range','A1');
writetable([array2table(muscle_names,...
    'VariableNames',{'Muscle Name'}) tbl_EMG_lc], OutFilename,...
    'Sheet', 'Left Cycles','Range','A15');