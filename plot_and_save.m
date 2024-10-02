function plot_and_save(data,type,plot_type,varargin)

    p = inputParser;

    % Required arguments
    addRequired(p, 'data');
    addRequired(p, 'type');
    addRequired(p, 'plot_type');

    % Optional arguments with default values
    addOptional(p, 'directory', pwd); % new frequency
    addOptional(p, 'saving', false); 
   
    
    % Parse inputs
    parse(p,data,type,plot_type, varargin{:});
    
    % Extract parsed input values
    directory = p.Results.directory;
    saving = p.Results.saving;


fields = fieldnames(data);
if (strcmp(type , 'emg'))

    if (strcmp(plot_type,'All_env'))

                % Right side
            for k=1:length(fields)

                figure;
                
                F=fields{k};
                
                for i=1:min(size(data.(F).RC.env))
                    plot(data.(F).RC.env(i,:))
                    hold on
                end
                title(strcat(F,"  All envRC"))
                hold off
                if (saving==true)
                    saveas(gcf,  strcat(directory,"\",F,"_All_envRC.png"));
                end

                % Left side
                figure
                
                for i=1:min(size(data.(F).LC.env))
                    plot(data.(F).LC.env(i,:))
                    hold on
                end
                title(strcat(F," All envLC"))
                if (saving==true)
                   saveas(gcf,  strcat(directory,"\",F,"_All_envLC.png"));
                end
            end
            
    elseif(strcmp(plot_type,'Mean_env'))

        for k=1:length(fields)

                % Right side
                figure;
                F=fields{k};
                mean_data=data.(F).RC.MeanEnv;
                upper_bound = mean_data + data.(F).RC.StdEnv;
                lower_bound = mean_data - data.(F).RC.StdEnv;
                x = 1:length(mean_data);
                fill([x fliplr(x)], [upper_bound fliplr(lower_bound)], [0.9 0.9 0.9], 'EdgeColor', 'none');
                hold on
                plot(mean_data)
                hold on
                legend(strcat(F,"_Mean_envRC"))
                if (saving==true)
                    saveas(gcf,  strcat(directory,"\",F,"_Mean_envRC.png"));
                end
                hold off
            
                % Left side
                figure;
                mean_data=data.(F).LC.MeanEnv;
                upper_bound = mean_data + data.(F).LC.StdEnv;
                lower_bound = mean_data - data.(F).LC.StdEnv;
                x = 1:length(mean_data);
                fill([x fliplr(x)], [upper_bound fliplr(lower_bound)], [0.9 0.9 0.9], 'EdgeColor', 'none');
                hold on
                plot(mean_data)
                hold on
                legend(strcat(F,"_Mean_envLC"))
                if (saving==true) 
                    saveas(gcf,  strcat(directory,"\",F,"_Mean_envLC.png"));
                end
               
        end
        

    else
        warning("Specify plot_type ('All_env' or 'Mean_env')")
    end
elseif (strcmp(type , 'xsens'))
    fields(1:2) = [];
    angles_names=["Abduction/Adduction","Internal/External Rotation","Flexion/Extension"];
        if (strcmp(plot_type,'All_env'))

                % Right side
            for k=1:length(fields)

                figure;
                F=fields{k};
                
                for angle=1:3
                    for i=1:data.cycles(1)
                        subplot(3,1,angle)
                        plot(data.(F).RCycles{1, i}(:,angle))
                        ylabel(angles_names(angle))
                        title(strcat(F," All envRC"))
                        hold on
                    end
                end
                
                hold off
                if (saving==true)
                    saveas(gcf,  strcat(directory,"\",F,"_All_envRC.png"));
                end

                % Left side
                figure
                
                for angle=1:3
                    for i=1:data.cycles(2)
                        subplot(3,1,angle)
                        plot(data.(F).LCycles{1, i}(:,angle))
                        ylabel(angles_names(angle))
                        title(strcat(F," All envLC"))
                        hold on
                    end
                end
                
                if (saving==true)
                   saveas(gcf,  strcat(directory,"\",F,"_All_envLC.png"));
                end
            end
            
    elseif(strcmp(plot_type,'Mean_env'))

        for k=1:length(fields)

                % Right side
                figure;
                F=fields{k};
                for angle=1:3
                    mean_data=data.(F).RC_Mean(angle,:);
                    upper_bound = mean_data + data.(F).RC_Std(angle,:);
                    lower_bound = mean_data - data.(F).RC_Std(angle,:);
                    x = 1:length(mean_data);
                    subplot(3,1,angle)
                    fill([x fliplr(x)], [upper_bound fliplr(lower_bound)], [0.9 0.9 0.9], 'EdgeColor', 'none');
                    hold on
                    plot(mean_data)
                    hold on 
                    title(strcat(F," ",angles_names(angle)," Mean envRC"))
                end
               
                if (saving==true)
                    saveas(gcf,  strcat(directory,"\",F,"_Mean_envRC.png"));
                end
                hold off
            
                % Left side
                figure;
               for angle=1:3
                    mean_data=data.(F).LC_Mean(angle,:);
                    upper_bound = mean_data + data.(F).LC_Std(angle,:);
                    lower_bound = mean_data - data.(F).LC_Std(angle,:);
                    x = 1:length(mean_data);
                    subplot(3,1,angle)
                    fill([x fliplr(x)], [upper_bound fliplr(lower_bound)], [0.9 0.9 0.9], 'EdgeColor', 'none');
                    hold on
                    plot(mean_data)
                    hold on 
                    title(strcat(F," ",angles_names(angle)," Mean envLC"))
                end
                if (saving==true) 
                    saveas(gcf,  strcat(directory,"\",F,"_Mean_envLC.png"));
                end
               
        end
        

    else
        warning("Specify plot_type ('All_env' or 'Mean_env')")
    end

else
    warning("Specify data type ('emg' or 'xsens')")
end