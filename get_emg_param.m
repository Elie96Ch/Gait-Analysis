function EMG_parameters = get_emg_param(xsens_processed,prep_EMG_data)
% function to segment, time-normalize, and calculate RMS and Peak values
    
    for k=1:height(prep_EMG_data.headers)
        
         A = prep_EMG_data.headers(k,:);
         A = strtok(A, ':');
         A = erase(A,{')','(',' '});

        for i=1:xsens_processed.cycles(1) % iterate through right cycles
            temp=prep_EMG_data.values.prep_NP(xsens_processed.contact.Rhs(i)...
                :xsens_processed.contact.Rhs(i+1),k);
            temp=NormalizeTo100(temp);
            eval(strcat("EMG_parameters.",A,".RC.env(i,:)=temp;"))
            eval(strcat("EMG_parameters.",A,".RC.envRMS{1,i}=rms(temp);"))
            eval(strcat("EMG_parameters.",A,".RC.envPeak{1,i}=max(temp);"))
        end
           eval(strcat("EMG_parameters.",A,".RC.MeanEnv =",...
           "mean(EMG_parameters.",A,".RC.env,1);"))
           eval(strcat("EMG_parameters.",A,".RC.StdEnv =",...
           "std(EMG_parameters.",A,".RC.env,1);"))

        for i=1:xsens_processed.cycles(2) % iterate through left cycles
            temp=prep_EMG_data.values.prep_NP(xsens_processed.contact.Lhs(i)...
                :xsens_processed.contact.Lhs(i+1),k);
            temp=NormalizeTo100(temp);
            eval(strcat("EMG_parameters.",A,".LC.env(i,:)=temp;"))
            eval(strcat("EMG_parameters.",A,".LC.envRMS{1,i}=rms(temp);"))
            eval(strcat("EMG_parameters.",A,".LC.envPeak{1,i}=max(temp);"))
        end
        eval(strcat("EMG_parameters.",A,".LC.MeanEnv =",...
           "mean(EMG_parameters.",A,".LC.env,1);"))
        eval(strcat("EMG_parameters.",A,".LC.StdEnv =",...
           "std(EMG_parameters.",A,".LC.env,1);"))
    end

end
%%
% function norm_data = NormalizeTo100(data)
% 
%     norm_axis=linspace(1,length(data),100);
%     norm_data=spline(1:length(data),data,norm_axis);
% 
% end