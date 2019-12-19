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

msg.Rest            = 1;
msg.Real_Left       = 2;
msg.Real_Right      = 3;
msg.Imaginary_Left  = 4;
msg.Imaginary_Right = 5;
msg.Instruction     = 6;


%% Finalize

% Pulse duration
msg.duration    = 0.003; % seconds

ParPortMessages = msg; % shortcut

end % function
