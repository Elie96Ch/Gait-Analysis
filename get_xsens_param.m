function Xsens_parameters = get_xsens_param(xsens_processed)
    
  

end
%%
function norm_data = NormalizeTo100(data)

    norm_axis=linspace(1,length(data),100);
    norm_data=spline(1:length(data),data,norm_axis);

end