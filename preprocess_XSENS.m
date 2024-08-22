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

    Rhs= find((diff(tree.footContact(3).footContacts))==1)+1;
    Rton= find((diff(tree.footContact(4).footContacts))==1)+1;
    
    Lhs= find((diff(tree.footContact(1).footContacts))==1)+1;
    Lton= find((diff(tree.footContact(2).footContacts))==1)+1;
    count_Rcycles= length(Rhs)-1;
    count_Lcycles= length(Lhs)-1;

    xsens_processed.contact.Rhs=Rhs;
    xsens_processed.contact.Rton=Rton;
    xsens_processed.contact.Lhs=Lhs;
    xsens_processed.contact.Lton=Lton;

%%

    if (isempty(joint_angles)==false)
        joint_labels={tree.jointData.label};
        for i=1:length(joint_angles)
            temp_idx=find(joint_labels==joint_angles(i));
            for j=1:count_Rcycles
                eval(strcat(joint_angles(i),".RHs{j}","=tree.jointData(",string(temp_idx),...
                ").jointAngle(Rhs(j):Rhs(j+1),:);"))
            end
            for j=1:count_Lcycles
                eval(strcat(joint_angles(i),".LHs{j}","=tree.jointData(",string(temp_idx),...
                ").jointAngle(Lhs(j):Lhs(j+1),:);"))
            end
            eval(strcat("xsens_processed.",joint_angles(i),"=",joint_angles(i),";"))
        end
    end
   
   %% 

end