%----------------------------------------------------------------------
% test_epochextract(epoch_duration, epoch_overlaptime, artifact_process_mode )
%
% sample program to use test_epochextract
% 
% This function epoch sample data, and remove/substitude the contaminated
% epochs, after detecting contaminated epochs by using MSDW methods
%
%	    epoch_duration: duration of epoch
%	    epoch_overlaptime: duration of overlapping time for adjusted epochs
%           artifact_process_mode:  0: ignore artifacts (default) 
%                                   1: substitute adjusted epochs for contaminated epochs artifact
%                                   2: remove contaminated epochs (assign null)
%
% Version 2014.7.14
% Codes & Method by Dr. Won-Du Chang
%
%----------------------------------------------------------------------
% All rights are reserved by Won-Du Chang, ph.D, 
% CoNE Lab, Department of Biomedical Engineering, Hanyang University
% 12cross@gmail.com
%---------------------------------------------------------------------
function  test_epochextract(epoch_duration, epoch_overlaptime,artifact_process_mode )
%basic parameter setup
   if nargin<1
       epoch_duration = 1;
   end
   if nargin<2
       epoch_overlaptime = 0.1;
   end
   if nargin<3
       artifact_process_mode = 0;
   end

   
%%
%load data 
    filepath = 'sample.txt';
    channel_id_2use = 1;  %channel ID to use
    samplingrate_original = 2048; % sampling rates of original  data
    datarange_2use = 1:60* samplingrate_original; % data range to use. e.g. if you want to use the data 60 seconds from the beginning -> 1:60* samplingrate_original
    
    data = load(filepath);
    data = data(datarange_2use,channel_id_2use);

%preprocessing
    samplingFrequency2Use = 64;
    data = Preprocessing(data,samplingrate_original,samplingFrequency2Use);

%%
%EOG Detection
    threshold = 140;
    min_window_width = 6;  %6 = 6/64  = about 93.8 ms
    max_window_width = 14;  %14 = 14/64  = 448/2048 = about 220 ms

    [artifact_range, window_acc_v] = eogdetection_accdiff(data(:,1), min_window_width, max_window_width, threshold); % window_acc_v는 distance list인데 reference 용으로 return하도록 하였음
    
%%
% Epoch Extract
    if artifact_process_mode==0  %extract epoch without artifact detection
        [ epochs, nSubstituted, bSubstituted] = epochextract( data, samplingFrequency2Use ,epoch_duration, epoch_overlaptime, artifact_process_mode );
    else  %reject contaminated epoch
        [ epochs, nSubstituted, bSubstituted] = epochextract( data, samplingFrequency2Use ,epoch_duration, epoch_overlaptime, artifact_process_mode, artifact_range );
    end

%printing Information
    nEpochs = size(epochs,1);
    fprintf(' - Total %d epochs were extracted including the last epoch, which may have no enough data in it\n', nEpochs);
    fprintf(' - %d epochs were subtituted/removed by previous ones because of the artifact\n', nSubstituted);
    tmp = 1:nEpochs;
    list = tmp(1,logical(bSubstituted));
    fprintf(' - ID Lists of contaminated epochs are : ');
    fprintf('%d ',list);
    fprintf('\n');

 %%
 % Display in Graphs
    figure('Name','Signal in Epochs');
    nEpochs = size(epochs,1);
    nPlotRow = 5;
    nPlotColumn = ceil(nEpochs/nPlotRow);
    for i = 1:nEpochs
        subplot(nPlotRow,nPlotColumn,i);

        if isempty(epochs{i})
            plot(0);
        elseif bSubstituted(i) == 1
            plot(epochs{i}(:,1),'Color','r');
        else
            plot(epochs{i}(:,1));
        end
        if(mod(i-1, nPlotColumn)~=0)
            set(gca, 'YTickLabel', []);
        end
        set(gca, 'XTickLabel', []);
        if ~isempty(epochs{i})
            xlim([0,size(epochs{i},1)]);
        end
        ylim([-300,400]);
    end
end

function data = Preprocessing(sourcedata, samplingrate_original, samplingFrequency2Use)
    median_width = 5;
    nRow= size(sourcedata,1);
    resamplingRate = samplingrate_original/samplingFrequency2Use;
    order = 1;
    cut_off_highpass_freq = 0.1; 

    tmp = highpass_simple(sourcedata,order,cut_off_highpass_freq,samplingrate_original);
    tmp = double(tmp(resamplingRate:resamplingRate:nRow,1));
    data = medfilt1(tmp,median_width); 
end

