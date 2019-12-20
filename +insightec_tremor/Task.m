function [ TaskData ] = Task
global S

try
    %% Tunning of the task
    
    [ EP, Parameters ] = insightec_tremor.Planning;
    TaskData.Parameters = Parameters;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    
    %% Prepare objects
    
    [ TEXT ] = insightec_tremor.Prepare.Text;
    
    
    %% Eyelink
    
    Common.StartRecordingEyelink;
    
    
    %% Go
    
    % Initialize some variables
    exit_flag = 0;
    nRelax    = 0;
    
    base_font = S.Parameters.insightec_tremor.Text_Relax.FontSize;
    dfont     = base_font/Parameters.Relax_nInc/Parameters.Relax_fontRatio;
    font_inc  = base_font / Parameters.Relax_fontRatio + dfont : dfont : base_font;
    font_dec  = fliplr(font_inc);
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt );
        
        event_name = EP.Data{evt,1};
        
        switch event_name
            
            case 'WaitForScanner' % ---------------------------------------
                
                TEXT.WaitForScanner.Draw
                
                Screen('DrawingFinished', S.PTB.wPtr);
                Screen('Flip', S.PTB.wPtr);
                
                StartTime = Common.StartTimeEvent;
                
            case 'DiscardVolumes' % ---------------------------------------
                
                ER.AddEvent({event_name GetSecs-StartTime [] EP.Data{evt,4:end}});
                
                nDiscard = Parameters.nDiscard;
                fprintf('volumes to discard = %d \n', nDiscard)
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                while nDiscard > 0
                    
                    % Fetch keys
                    [keyIsDown, secs, keyCode] = KbCheck;
                    
                    if keyIsDown
                        
                        if keyCode(S.Parameters.Keybinds.TTL_t_ASCII)
                            nDiscard = nDiscard - 1;
                            fprintf('volumes discarded = %d \n', Parameters.nDiscard-nDiscard)
                            ER.AddEvent({event_name secs-StartTime [] EP.Data{evt,4:end}});
                            WaitSecs(0.200); % pulse duration is ~20ms, so we wait a bit
                        end
                        
                        % ~~~ ESCAPE key ? ~~~
                        [ exit_flag, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if exit_flag
                            break
                        end
                    end
                    
                end % while
                if exit_flag
                    break
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            case {'Instructions', 'Posture', 'EndText'} % -----------------------------------------
                
                TEXT.(event_name).Draw
                when = StartTime + EP.Data{evt,2} - S.PTB.slack;
                Screen('DrawingFinished', S.PTB.wPtr);
                lastFlipOnset = Screen('Flip', S.PTB.wPtr, when);
                Common.SendParPortMessage(event_name);
                
                ER.AddEvent({event_name lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                RR.AddEvent({event_name lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                
                when = StartTime + EP.Data{evt+1,2} - S.PTB.slack;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                secs = lastFlipOnset;
                while secs < when
                    
                    % Fetch keys
                    [keyIsDown, secs, keyCode] = KbCheck;
                    
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ exit_flag, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if exit_flag
                            break
                        end
                    end
                    
                end % while
                if exit_flag
                    break
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            case 'Relax' % ------------------------------------------------
                
                nRelax = nRelax + 1;
                
                if nRelax == 1
                
                    % Full Size ===========================================
                    
                    TEXT.Relax.font_size = base_font;
                    TEXT.Relax.Draw
                    when = StartTime + EP.Data{evt,2} - S.PTB.slack;
                    Screen('DrawingFinished', S.PTB.wPtr);
                    lastFlipOnset = Screen('Flip', S.PTB.wPtr, when);
                    Common.SendParPortMessage(event_name);
                    
                    ER.AddEvent({event_name lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                    RR.AddEvent({event_name lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                    
                    when = StartTime + EP.Data{evt,2} + Parameters.Relax_midDuration - S.PTB.slack;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    secs = lastFlipOnset;
                    while secs < when
                        
                        % Fetch keys
                        [keyIsDown, secs, keyCode] = KbCheck;
                        
                        if keyIsDown
                            % ~~~ ESCAPE key ? ~~~
                            [ exit_flag, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                            if exit_flag
                                break
                            end
                        end
                        
                    end % while
                    if exit_flag
                        break
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    for i = 1 : Parameters.Relax_nDec
                        
                        TEXT.Relax.font_size = font_dec(i);
                        TEXT.Relax.font_size
                        TEXT.Relax.Draw
                        when = StartTime + EP.Data{evt,2} + Parameters.Relax_midDuration + Parameters.Relax_tDec * i - S.PTB.slack;
                        Screen('DrawingFinished', S.PTB.wPtr);
                        lastFlipOnset = Screen('Flip', S.PTB.wPtr, when);
                        
                        RR.AddEvent({event_name lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                        
                    end
                    
                elseif nRelax == Parameters.nTrials
                    
                    % just 1 small ========================================
                    
                    TEXT.Relax.font_size = font_dec(end);
                    TEXT.Relax.Draw
                    when = StartTime + EP.Data{evt,2} - S.PTB.slack;
                    Screen('DrawingFinished', S.PTB.wPtr);
                    lastFlipOnset = Screen('Flip', S.PTB.wPtr, when);
                    Common.SendParPortMessage(event_name);
                    
                    ER.AddEvent({event_name lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                    RR.AddEvent({event_name lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                    
                else % 2 : end-1
                    
                    % Increase ============================================
                    for i = 1 : Parameters.Relax_nInc
                        
                        TEXT.Relax.font_size = font_inc(i);
                        TEXT.Relax.Draw
                        
                        if i == 1
                            when = StartTime + EP.Data{evt+1,2} - S.PTB.slack;
                        else
                            when = StartTime + EP.Data{evt+1,2} + Parameters.Relax_tDec * i - S.PTB.slack;
                        end
                        
                        Screen('DrawingFinished', S.PTB.wPtr);
                        lastFlipOnset = Screen('Flip', S.PTB.wPtr, when);
                        
                        if i == 1
                            Common.SendParPortMessage(event_name);
                            ER.AddEvent({event_name lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                        end
                        
                        RR.AddEvent({event_name lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                        
                    end
                    
                    % Full Size ===========================================
                    
                    TEXT.Relax.font_size = base_font;
                    TEXT.Relax.Draw
                    when = StartTime + EP.Data{evt+1,2} + Parameters.Relax_tDec * Parameters.Relax_nDec - S.PTB.slack;
                    Screen('DrawingFinished', S.PTB.wPtr);
                    lastFlipOnset = Screen('Flip', S.PTB.wPtr, when);
                    
                    RR.AddEvent({event_name lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                    
                    when = StartTime + EP.Data{evt+1,2} + Parameters.Relax_tDec * Parameters.Relax_nDec + Parameters.Relax_midDuration + EP.Get('RelaxJitter',evt) - S.PTB.slack;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    secs = lastFlipOnset;
                    while secs < when
                        
                        % Fetch keys
                        [keyIsDown, secs, keyCode] = KbCheck;
                        
                        if keyIsDown
                            % ~~~ ESCAPE key ? ~~~
                            [ exit_flag, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                            if exit_flag
                                break
                            end
                        end
                        
                    end % while
                    if exit_flag
                        break
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    for i = 1 : Parameters.Relax_nDec
                        
                        TEXT.Relax.font_size = font_dec(i);
                        TEXT.Relax.Draw
                        when = StartTime + EP.Data{evt+1,2} + Parameters.Relax_tDec * Parameters.Relax_nDec + Parameters.Relax_midDuration + Parameters.Relax_tDec * i - S.PTB.slack;
                        Screen('DrawingFinished', S.PTB.wPtr);
                        lastFlipOnset = Screen('Flip', S.PTB.wPtr, when);
                        
                        RR.AddEvent({event_name lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                        
                    end
                    
                end
                
            case 'EndOfStim' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
            otherwise % ---------------------------------------------------
                
                error('unknown envent : %s', event_name)
                
        end % switch
        
        % This flag comes from Common.Interrupt, if ESCAPE is pressed
        if exit_flag
            break
        end
        
    end % for
    
    
    %% End of stimulation
    
    % Close the audio device
    % PsychPortAudio('Close');
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, StartTime, StopTime );
    
    % TaskData.BR = BR;
    % assignin('base','BR', BR)
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
