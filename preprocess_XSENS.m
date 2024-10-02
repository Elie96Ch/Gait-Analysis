function xsens_processed=preprocess_XSENS(tree,varargin)

    p = inputParser;

    % Required arguments
    addRequired(p, 'tree');

    % Optional arguments with default values
    addOptional(p, 'stance', false);
    addOptional(p, 'swing', false);
    addOptional(p, 'stride', false);
    addOptional(p, 'step_length', false);
    addOptional(p, 'step_width', false);
    addOptional(p, 'cadence', false);
    addOptional(p, 'joint_angles', false);
    addOptional(p, 'filter_contacts', false);
    
    % addOptional(p, 'ROM', false);
    % addOptional(p, 'MaxANGLE', false);
    % addOptional(p, 'MinANGLE', false);
    
 
    % Parse inputs
    parse(p, tree, varargin{:});
    
    % Extract parsed input values
    stance = p.Results.stance;
    swing=p.Results.swing;
    stride=p.Results.stride;
    step_length=p.Results.step_length;
    step_width=p.Results.step_width;
    cadence=p.Results.cadence;
    joint_angles=p.Results.joint_angles;
    

    % read some basic data from the file
    mvnxVersion = tree.metaData.mvnx_version;
    if (isfield(tree.metaData, 'comment'))
        fileComments = tree.metaData.comment;
    end
    
    frameRate = tree.metaData.subject_frameRate;
    suitLabel = tree.metaData.subject_label;
    originalFilename = tree.metaData.subject_originalFilename;
    recDate = tree.metaData.subject_recDate;
    segmentCount = tree.metaData.subject_segmentCount;
    %retrieve sensor labels
    %creates a struct with sensor data
    if isfield(tree,'sensorData') && isstruct(tree.sensorData)
        sensorData = tree.sensorData;
    end
    %retrieve segment labels
    %creates a struct with segment definitions
    if isfield(tree,'segmentData') && isstruct(tree.segmentData)
        segmentData = tree.segmentData;
    end
    if (p.Results.filter_contacts==false)
        Rhs= find((diff(tree.footContact(3).footContacts))==1)+1;
        Rton= find((diff(tree.footContact(4).footContacts))==1)+1;
        
        Lhs= find((diff(tree.footContact(1).footContacts))==1)+1;
        Lton= find((diff(tree.footContact(2).footContacts))==1)+1;
    else
        clean_contacts = clean_ctc(tree);

        Rhs = clean_contacts.RightFoot_Heel;
        Rton = clean_contacts.RightFoot_Toe;
        
        Lhs = clean_contacts.LeftFoot_Heel;
        Lton = clean_contacts.LeftFoot_Toe;
    end
    count_Rcycles= length(Rhs)-1;
    count_Lcycles= length(Lhs)-1;

    if (abs(count_Rcycles-count_Lcycles))>2
        warning('Check for missing heel strikes')
    end

    xsens_processed.contact.Rhs=Rhs;
    xsens_processed.contact.Rton=Rton;
    xsens_processed.contact.Lhs=Lhs;
    xsens_processed.contact.Lton=Lton;
    xsens_processed.cycles(1)=count_Rcycles;
    xsens_processed.cycles(2)=count_Lcycles;

    
%%

    if (isempty(joint_angles)==false)
        joint_labels={tree.jointData.label};
        for i=1:length(joint_angles)
            temp_idx=find(joint_labels==joint_angles(i));
            All_data=cell(1,3);
            for j=1:count_Rcycles
                temp_angles=tree.jointData(temp_idx).jointAngle(Rhs(j):Rhs(j+1),:);
                temp_min=[min(temp_angles(:,1)),min(temp_angles(:,2)),min(temp_angles(:,3))];
                temp_max=[max(temp_angles(:,1)),max(temp_angles(:,2)),max(temp_angles(:,3))];
                temp_ROM=temp_max-temp_min;
                norm_data = NormalizeTo100(temp_angles);
                All_data{1}=[All_data{1} norm_data(:,1)];
                All_data{2}=[All_data{2} norm_data(:,2)];
                All_data{3}=[All_data{3} norm_data(:,3)];
                eval(strcat(joint_angles(i),".RCycles{1,j}","=norm_data;"))
                eval(strcat(joint_angles(i),".RCycles{2,j}","=temp_min;"))
                eval(strcat(joint_angles(i),".RCycles{3,j}","=temp_max;"))
                eval(strcat(joint_angles(i),".RCycles{4,j}","=temp_ROM;"))
            end
            for k=1:3
            eval(strcat(joint_angles(i),".RC_Mean(k,:)","=mean(All_data{k},2);"))
            eval(strcat(joint_angles(i),".RC_Std(k,:)","=std(All_data{k}',1);"))
            end


            All_data=cell(1,3);
            for j=1:count_Lcycles
                temp_angles=tree.jointData(temp_idx).jointAngle(Lhs(j):Lhs(j+1),:);
                temp_min=[min(temp_angles(:,1)),min(temp_angles(:,2)),min(temp_angles(:,3))];
                temp_max=[max(temp_angles(:,1)),max(temp_angles(:,2)),max(temp_angles(:,3))];
                temp_ROM=temp_max-temp_min;
                norm_data = NormalizeTo100(temp_angles);
                All_data{1}=[All_data{1} norm_data(:,1)];
                All_data{2}=[All_data{2} norm_data(:,2)];
                All_data{3}=[All_data{3} norm_data(:,3)];
                eval(strcat(joint_angles(i),".LCycles{1,j}","=norm_data;"))
                eval(strcat(joint_angles(i),".LCycles{2,j}","=temp_min;"))
                eval(strcat(joint_angles(i),".LCycles{3,j}","=temp_max;"))
                eval(strcat(joint_angles(i),".LCycles{4,j}","=temp_ROM;"))
            end
            for k=1:3
            eval(strcat(joint_angles(i),".LC_Mean(k,:)","=mean(All_data{k},2);"))
            eval(strcat(joint_angles(i),".LC_Std(k,:)","=std(All_data{k}',1);"))
            end
            eval(strcat("xsens_processed.",joint_angles(i),"=",joint_angles(i),";"))
        end
    end
   
   %% 

end

