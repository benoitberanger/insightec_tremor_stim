function [ names , onsets , durations ] = SPMnod
global S

%SPMNOD Build 'names', 'onsets', 'durations' for SPM

EchoStart(mfilename)

try
    %% Preparation
    
    % 'names' for SPM
    names = {
        'Instructions'
        'Relax'
        'Posture'
        'EndText'
        };
    
    % 'onsets' & 'durations' for SPM
    onsets    = cell(size(names));
    durations = cell(size(names));
    
    % Shortcut
    EventData = S.TaskData.ER.BlockData;
    
    
    %% Onsets building
    
    for event = 1 : size(EventData,1)
        
        where = find(strcmp(EventData{event,1}, names));
        if ~isempty(where)
            onsets{where} = [onsets{where} ; EventData{event,2}];
        end
        
    end
    
    
    %% Durations building
    
    
    for event = 1:size(EventData,1)
        
        where = find(strcmp(EventData{event,1}, names));
        if ~isempty(where)
            durations{where} = [ durations{where} ; EventData{event+1,2}-EventData{event,2}] ;
        end
        
    end
    
    
    %     %% Add Clicks to SPM model input
    %
    %     if ~strcmp(S.Task,'EyelinkCalibration')
    %
    %         N = length(names);
    %
    %         fingers = S.Parameters.Fingers.Names;
    %
    %         for f = 1:length(fingers)
    %             click_spot.(fingers{f}) = regexp(S.TaskData.KL.KbEvents(:,1),fingers{f});
    %             click_spot.(fingers{f}) = ~cellfun(@isempty,click_spot.(fingers{f}));
    %             click_spot.(fingers{f}) = find(click_spot.(fingers{f}));
    %         end
    %
    %         count = 0 ;
    %         for f = 1:length(fingers)
    %
    %             count = count + 1 ;
    %
    %             names{N+count} = fingers{f};
    %
    %             if ~isempty(S.TaskData.KL.KbEvents{click_spot.(fingers{f}),2})
    %                 click_idx = cell2mat(S.TaskData.KL.KbEvents{click_spot.(fingers{f}),2}(:,2)) == 1;
    %                 click_idx = find(click_idx);
    %                 % the last clickk can be be unfinished : button down + end of stim = no button up
    %                 if isempty(S.TaskData.KL.KbEvents{click_spot.(fingers{f}),2}{click_idx(end),3})
    %                     S.TaskData.KL.KbEvents{click_spot.(fingers{f}),2}{click_idx(end),3} =  S.TaskData.ER.Data{end,2} - S.TaskData.KL.KbEvents{click_spot.(fingers{f}),2}{click_idx(end),1};
    %                 end
    %                 onsets{N+count}    = cell2mat(S.TaskData.KL.KbEvents{click_spot.(fingers{f}),2}(click_idx,1));
    %                 durations{N+count} = cell2mat(S.TaskData.KL.KbEvents{click_spot.(fingers{f}),2}(click_idx,3));
    %             else
    %                 onsets{N+count}    = [];
    %                 durations{N+count} = [];
    %             end
    %
    %         end
    %
    %     end
    
    
catch err
    
    sca
    warning(err.message)
    
end

EchoStop(mfilename)

end % function
