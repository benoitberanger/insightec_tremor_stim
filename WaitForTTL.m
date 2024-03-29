function [ TriggerTime ] = WaitForTTL
global S

if strcmp(S.OperationMode,'Acquisition')
    
    disp('----------------------------------')
    disp('      Waiting for trigger "t"     ')
    disp('                OR                ')
    disp('      Press "Escape" to abort     ')
    disp('----------------------------------')
    disp(' ')
    
    
    % Just to be sure the user is not pushing a button before
    WaitSecs(0.200); % secondes
    
    % Waiting for TTL signal
    while 1
        
        [ keyIsDown , TriggerTime, keyCode ] = KbCheck;
        
        if keyIsDown
            
            if keyCode(S.Parameters.Keybinds.TTL_t_ASCII) % || keyCode(S.Parameters.Keybinds.emulTTL_s_ASCII)
                
                fprintf('Waiting for TTL : MRI trigger received \n')
                break
                
            elseif keyCode(S.Parameters.Keybinds.Stop_Escape_ASCII)
                
                % Eyelink mode 'On' ?
                if strcmp(S.EyelinkMode,'On')
                    Eyelink.STOP % Stop wrapper
                end
                
                sca
                stack = dbstack;
                error('WaitingForTTL:Abort','\n ESCAPE key : %s aborted \n',stack.file)
                
            end
            
        end
        
    end % while
    
    
else % in DebugMod
    
    fprintf('Waiting for TTL : DebugMode \n')
    
    TriggerTime = GetSecs;
    
end

end
