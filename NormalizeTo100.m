function norm_data = NormalizeTo100(data)
    shape_data=size(data);
    if (shape_data(1)<shape_data(2))
        
        data=data';
    
    end
    for i=1:min(size(data))
        norm_axis=linspace(1,length(data(:,i)),100);
        norm_data(:,i)=spline(1:length(data(:,i)),data(:,i),norm_axis);
    end

end