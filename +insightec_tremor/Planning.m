function [ EP , Parameters ] = Planning
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.OperationMode = 'Acquisition';
end


%% Paradigme

TR = 1.000; % seconds

Parameters.nDiscard             = 6;                     % integer, number of volume to discard

Parameters.nTrials              = 20;                    % integer

Parameters.Instruction_duration = 15;                    % seconds

Parameters.Relax_nInc           = 4;                     % integer
Parameters.Relax_nDec           = Parameters.Relax_nInc;
Parameters.Relax_tInc           = 0.5;                   % seconds
Parameters.Relax_tDec           = Parameters.Relax_tInc;
Parameters.Relax_fontRatio      = 2;                     % font size ratio : it will start at X and finish at X*fontRatio
Parameters.Relax_midDuration    = 6;                     % seconds
Parameters.Relax_jitter         = [-1 +1];               % seconds

Parameters.Posture_duration     = 30;                    % seconds

Parameters.EndOfTask_duration   = 10;                    % seconds


switch S.OperationMode
    case 'Acquisition'
        
        % pass, keep main paramters
        
    case 'FastDebug'
        
        Parameters.nDiscard             = 0;                     % integer, number of volume to discard
        
        Parameters.nTrials              = 4;                     % integer
        
        Parameters.Instruction_duration = 1;                     % seconds
        
        Parameters.Relax_nInc           = 4;                     % integer
        Parameters.Relax_nDec           = Parameters.Relax_nInc;
        Parameters.Relax_tInc           = 0.2;                   % seconds
        Parameters.Relax_tDec           = Parameters.Relax_tInc;
        
        Parameters.Relax_midDuration    = 2;                     % seconds
        Parameters.Relax_jitter         = [-1 +1];               % seconds
        
        Parameters.Posture_duration     = 2;                     % seconds
        
        Parameters.EndOfTask_duration   = 2;                     % seconds
        
    case 'RealisticDebug'
        
        Parameters.nDiscard             = 0;                     % integer, number of volume to discard
        
        Parameters.nTrials              = 4;                     % integer
        
end


%% Jitter

jitter_range = diff(Parameters.Relax_jitter)/2;
jitter_vect  = linspace(-jitter_range, jitter_range, Parameters.nTrials);
jitter_vect  = Shuffle(jitter_vect);


%% Define a planning <--- paradigme


% Create and prepare @EventPlanning object
header = { 'name', 'onset', 'duration' 'RelaxJitter'};
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddStartTime('WaitForScanner',0);

% --- Stim ----------------------------------------------------------------

EP.AddPlanning({ 'DiscardVolumes' NextOnset(EP) Parameters.nDiscard*TR          [] })

EP.AddPlanning({ 'Instructions'   NextOnset(EP) Parameters.Instruction_duration [] })

for iTrial = 1 : Parameters.nTrials
    
    if iTrial == 1
        relax_dur =                                                 Parameters.Relax_midDuration                       + Parameters.Relax_nDec * Parameters.Relax_tDec;
    else
        relax_dur = Parameters.Relax_nInc * Parameters.Relax_tInc + Parameters.Relax_midDuration + jitter_vect(iTrial) + Parameters.Relax_nDec * Parameters.Relax_tDec;
    end
    
    EP.AddPlanning({ 'Relax'   NextOnset(EP) relax_dur                   jitter_vect(iTrial) })
    
    EP.AddPlanning({ 'Posture' NextOnset(EP) Parameters.Posture_duration []                  })
    
end

EP.AddPlanning({ 'Relax'   NextOnset(EP) Parameters.Relax_tInc         [] })

EP.AddPlanning({ 'EndText' NextOnset(EP) Parameters.EndOfTask_duration [] })

% --- Stop ----------------------------------------------------------------

EP.AddStopTime('EndOfStim',NextOnset(EP));


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargout < 1
    
    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , NextOnset(EP) )
    fprintf( '\n' )
    
    EP.Plot
    
end


end % function
