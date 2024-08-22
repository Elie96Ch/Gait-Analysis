function [MVC_mean, MVC_peak] = get_mvc(Channels, Data, Fs)

    processed_data=preprocess_EMG(Channels, Data, Fs,'isMVC',true);
    MVC_peak=max(processed_data.values.prep_NM);
    MVC_mean=mean(processed_data.values.prep_NM);

end