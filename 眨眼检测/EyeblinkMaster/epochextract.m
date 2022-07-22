%----------------------------------------------------------------------
% [ epochs, nSubstituted, bSubstituted] = epochextract( data,samplingrate ,epoch_duration, epoch_overlaptime, artifact_range )
%
% This function epoch sample data, and remove/substitude the contaminated
% epochs, after detecting contaminated epochs by using MSDW methods
%
% 파라메터 설명
%           data: Source data
%           samplingrate: sampling rate (Hz)
%           epoch_duration: duration of epoch
%           epoch_overlaptime: duration of overlapping time for adjusted epochs
%           artifact_process_mode:  0: ignore artifacts (default) 
%                                   1: substitute adjusted epochs for contaminated epochs artifact
%                                   2: remove contaminated epochs (assign null)
%           artifact_range: range of artifact
%
% Version 2014.07.14
% Codes & Method by Dr. Won-Du Chang
%
% Extract epoch according to the duration and overlappping time
% time unit follows seconds
% artifact_rage is in time index
%
% epoch overlapping can cause data loss according to the sampling rates. 
% we recommend not to use the epoch overlapping if you do not want to risk
% it
%----------------------------------------------------------------------
% All rights are reserved by Won-Du Chang, ph.D, 
% CoNE Lab, Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function [ epochs, nSubstituted, bSubstituted] = epochextract( data,samplingrate ,epoch_duration, epoch_overlaptime, artifact_process_mode, artifact_range )
    %기본 변수 설정
    nRow = size(data,1);
    total_record_time = nRow / samplingrate;
    nEpoch = ceil((total_record_time-epoch_overlaptime) / (epoch_duration - epoch_overlaptime));
    epochs = cell(nEpoch,1);
    bSubstituted = zeros(nEpoch,1);

    bArtifact = zeros(nRow,1); 
    if nargin<5 || artifact_process_mode==0
        nArtifact = 0;
        artifact_process_mode = 0;
    else
        nArtifact = size(artifact_range,1);
        for i=1:nArtifact
            bArtifact(artifact_range(i,1):artifact_range(i,2)) = 1;
        end
    end
    

    nSubstituted = 0;
    counter = 0;
    for i=1:nEpoch
        bArtifactFound = 0;
        starting_index = round((i-1) * (epoch_duration - epoch_overlaptime) * samplingrate+1);
        ending_index = round(starting_index+ epoch_duration * samplingrate-1);
        if(ending_index>nRow) 
            ending_index = nRow;
        end
        
        for j=starting_index:ending_index
            if bArtifact(j)==1
                bArtifactFound = 1;
                break;
            end
        end
        if bArtifactFound ==0  
            epochs{i} = data(starting_index:ending_index,:);
        elseif ( i>1 && size(epochs(i-1),1)~=0 ) 
            if artifact_process_mode ==1
                epochs{i} = epochs{i-1};
            else
                epochs{i} = [];
            end
            bSubstituted(i) = 1;
            nSubstituted = nSubstituted +1;
        else
            counter = counter+1;
            bSubstituted(i) = 1;
            nSubstituted = nSubstituted +1;
        end
    end
    for i=counter:-1:1  
        if artifact_process_mode ==1
            epochs{i} = epochs {i+1};  
        else
            epochs{i} = [];
        end
    end
    

end

