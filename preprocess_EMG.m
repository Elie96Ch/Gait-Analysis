function EMG_data=preprocess_EMG(Channels, Data, Fs,varargin)
    
    p = inputParser;

    % Required arguments
    addRequired(p, 'Channels');
    addRequired(p, 'Data');
    addRequired(p, 'Fs');

    % Optional arguments with default values
    addOptional(p, 'nF', 60); % new frequency
    addOptional(p, 'low_cutoff', 10); 
    addOptional(p, 'high_cutoff', 250);
    addOptional(p, 'MVC', false);
    addOptional(p, 'isMVC', false);
    addOptional(p, 'MV_window_size', 500);
    addOptional(p, 'lpf', false);

    % Parse inputs
    parse(p, Channels, Data, Fs, varargin{:});
    
    % Extract parsed input values
    nF = p.Results.nF;
    low_cutoff = p.Results.low_cutoff;
    high_cutoff = p.Results.high_cutoff;
    MVC = p.Results.MVC;
    isMVC = p.Results.isMVC;
    MV_window_size = p.Results.MV_window_size;
    lpf=p.Results.lpf;

    if(MVC)
        MVC_all_Data = load(uigetfile());
        MVC_Channels=MVC_all_Data.Channels;
        MVC_Data=MVC_all_Data.Data;
        MVC_Fs=MVC_all_Data.Fs;    
    end
    
    for i=1:height(Data)

        Time(i,:)=linspace(0,length(Data)/Fs(i),length(Data));

        % Eliminate Bias using detrend
        detrended_data(:,i)=detrend(Data(i,:))';
        
        % Rectify signal using absolute (abs)
        rec_data(:,i)=abs(detrended_data(:,i));
        
        
        fs = Fs(i); % Sampling frequency

        % Design the bandpass filter
        % Normalize the cut-off frequencies by the Nyquist frequency (fs/2)
        [b_bp, a_bp] = butter(5, [low_cutoff high_cutoff] / (fs / 2), 'bandpass');
        
        % Design the notch filter
        notch_freq = 50; % Notch frequency in Hz
        notch_quality = 30; % Quality factor (Q) of the notch filter
        [b_notch, a_notch] = iirnotch(notch_freq / (fs / 2), notch_freq / (fs / 2) / notch_quality);
        
        % Apply the bandpass filter
        filtered_data_bp = filtfilt(b_bp, a_bp, rec_data(:,i));
        
        % Apply the notch filter to the bandpass-filtered data
        filtered_data_notch = filtfilt(b_notch, a_notch, filtered_data_bp);
        
        % Store the result
        filtered_data(:,i) = filtered_data_notch;
        
        envelope_data(:,i) = smooth(abs(filtered_data(:,i)), MV_window_size*fs/1000,'moving');


        % Normalize data
        if (MVC)

            [MVC_mean, MVC_peak] = get_mvc(MVC_Channels(1,:), MVC_Data(1,:), MVC_Fs(1,:));
            Norm_mean_data(:,i)=envelope_data(:,i)/MVC_mean;
            Norm_peak_data(:,i)=envelope_data(:,i)/MVC_peak;

        elseif (~isMVC)
            
            Norm_peak_data(:,i)=envelope_data(:,i)/max(envelope_data(:,i));
            Norm_mean_data(:,i)=envelope_data(:,i)/mean(envelope_data(:,i));

        else
            Norm_peak_data=envelope_data(:,i);
            Norm_mean_data=envelope_data(:,i);
        end
            
            % Resampled at nF Hz
            newframes=Time(i,width(Time))*nF;
            newFrame = 1:newframes;
            oldFrame = 1:length(Norm_peak_data);
            xx = linspace(1,length(oldFrame),length(newFrame));

            
            resampled_NM(:,i) = spline(oldFrame,Norm_mean_data(:,i),xx);
            resampled_NP(:,i) = spline(oldFrame,Norm_peak_data(:,i),xx);

        if(lpf)
            lp_cut_off=lpf;
            [b_lp,a_lp]=butter(4, lp_cut_off/ (nF / 2), 'low');
            resampled_NM(:,i)= filtfilt(b_lp, a_lp, resampled_NM(:,i));
            resampled_NP(:,i)= filtfilt(b_lp, a_lp, resampled_NP(:,i));
        end

    end

    EMG_data.values.prep_NM=resampled_NM;
    EMG_data.values.prep_NP=resampled_NP;
    EMG_data.headers=Channels;


end