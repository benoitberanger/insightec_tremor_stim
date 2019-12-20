function ParPortMessages = PrepareParPort
global S

%% On ? Off ?

switch S.ParPort
    
    case 'On'
        
        % Open parallel port
        OpenParPort;
        
        % Set pp to 0
        WriteParPort(0);
        
    case 'Off'
        
end


%% Prepare messages

msg.Instructions = 88;
msg.Relax        = 12;
msg.Posture      = 11;
msg.EndText      = 99;


%% Finalize

% Pulse duration
msg.duration    = 0.003; % seconds

ParPortMessages = msg; % shortcut


end % function
