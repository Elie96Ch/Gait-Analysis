function clean_contacts = clean_ctc(tree)

labels={tree.footContact.label};
    for i=1:length(labels)
    
        data=tree.footContact(i).footContacts;
        [data_idx,removed_data]=cln_idx(data);
        eval(strcat("clean_contacts.", string(labels(i)),"=data_idx;"))
       eval(strcat("clean_contacts.", string(labels(i)),"_rm=removed_data;"))
    end
end


function [cleaned, removed]= cln_idx(data)

    data_idx=find(diff(data)==1)+1;
    data_idx_diff=find(diff(data_idx)<50)+1;
    removed=data_idx(data_idx_diff);
    data_idx(data_idx_diff)=[];
    cleaned=data_idx;
    

end