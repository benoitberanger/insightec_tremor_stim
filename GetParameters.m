function [ Parameters ] = GetParameters
% GETPARAMETERS Prepare common parameters
% global S

% if isempty(S)
%     S.Environement = 'MRI';
%     S.Side         = 'Left';
%     S.Task         = 'MRI';
% end


%% Echo in command window

EchoStart(mfilename)


%% Paths

% Parameters.Path.wav = ['wav' filesep];


%% Set parameters

%%%%%%%%%%%
%  Audio  %
%%%%%%%%%%%

% Parameters.Audio.SamplingRate            = 44100; % Hz

% Parameters.Audio.Playback_Mode           = 1; % 1 = playback, 2 = record
% Parameters.Audio.Playback_LowLatencyMode = 1; % {0,1,2,3,4}
% Parameters.Audio.Playback_freq           = Parameters.Audio.SamplingRate ;
% Parameters.Audio.Playback_Channels       = 2; % 1 = mono, 2 = stereo

% Parameters.Audio.Record_Mode             = 2; % 1 = playback, 2 = record
% Parameters.Audio.Record_LowLatencyMode   = 0; % {0,1,2,3,4}
% Parameters.Audio.Record_freq             = Parameters.Audio.SamplingRate;
% Parameters.Audio.Record_Channels         = 1; % 1 = mono, 2 = stereo


%%%%%%%%%%%%%%
%   Screen   %
%%%%%%%%%%%%%%
% Prisma scanner @ CENIR
Parameters.Video.ScreenWidthPx   = 1920;  % Number of horizontal pixel in MRI video system @ CENIR Prisma
Parameters.Video.ScreenHeightPx  = 1080;  % Number of vertical   pixel in MRI video system @ CENIR Prisma
Parameters.Video.ScreenFrequency = 120;   % Refresh rate (in Hertz)
Parameters.Video.SubjectDistance = 1.200; % m
Parameters.Video.ScreenWidthM    = 0.508; % m
Parameters.Video.ScreenHeightM   = 0.286; % m

Parameters.Video.ScreenBackgroundColor = [ 0 0 0 ]; % [R G B] ( from 0 to 255 )

%%%%%%%%%%%%
%   Text   %
%%%%%%%%%%%%
Parameters.Text.SizeRatio   = 0.20; % Size = ScreenWide *ratio
Parameters.Text.Font        = 'Arial';
Parameters.Text.Color       = [255 255 255]; % [R G B] ( from 0 to 255 )
% Parameters.Text.ClickCorlor = [0   255 0  ]; % [R G B] ( from 0 to 255 )

%%%%%%%%%%%%%%%%%%%%%%%%
%   insightec_tremor   %
%%%%%%%%%%%%%%%%%%%%%%%%

% Bip
% Parameters.insightec_tremor.Bip.Freq            = 440;   % Hz
% Parameters.insightec_tremor.Bip.BipDuration     = 0.500; % second
% Parameters.insightec_tremor.Bip.InOutFadeRation = 0.10;  % ration : [0-1]

% Fixation cross
Parameters.insightec_tremor.FixationCross.ScreenRatio    = 0.20;          % ratio : dim   = ScreenWide *ratio_screen
Parameters.insightec_tremor.FixationCross.lineWidthRatio = 0.04;          % ratio : width = dim        *ratio_width
Parameters.insightec_tremor.FixationCross.Color          = [255 255 255]; % [R G B] ( from 0 to 255 )
Parameters.insightec_tremor.FixationCross.PositonXRatio  = 0.5;           % Xpos = PositonXRatio * ScreenWidth
Parameters.insightec_tremor.FixationCross.PositonYRatio  = 0.5;           % Ypos = PositonYRatio * ScreenHight

%#ok<*NBRAK>

% Text : Wainting for scanner
Parameters.insightec_tremor.Text_WaitForScanner.PositonXRatio = 1/2;  % Xpos = PositonXRatio * ScreenWidth
Parameters.insightec_tremor.Text_WaitForScanner.PositonYRatio = 1/2;  % Ypos = PositonYRatio * ScreenHight
Parameters.insightec_tremor.Text_WaitForScanner.FontSize      = 40;
Parameters.insightec_tremor.Text_WaitForScanner.Content = [
    'Le scanner est bientôt prêt, ne ne bougez plus.'
    ];

% Text : Instructions
Parameters.insightec_tremor.Text_Instructions.PositonXRatio = 1/2;  % Xpos = PositonXRatio * ScreenWidth
Parameters.insightec_tremor.Text_Instructions.PositonYRatio = 1/2;  % Ypos = PositonYRatio * ScreenHight
Parameters.insightec_tremor.Text_Instructions.FontSize      = 40;
Parameters.insightec_tremor.Text_Instructions.Content = [
    'La tâche va commencer.\n'...
    'Lorsque vous verrez REPOS, reposez votre main sur le côté.\n'...
    'Lorsque vous verrez POSTURE, levez votre main dans la positon convenue.'...
    ];

% Text : Relax
Parameters.insightec_tremor.Text_Relax.PositonXRatio = 1/2;  % Xpos = PositonXRatio * ScreenWidth
Parameters.insightec_tremor.Text_Relax.PositonYRatio = 1/2;  % Ypos = PositonYRatio * ScreenHight
Parameters.insightec_tremor.Text_Relax.FontSize      = 80;   % will increased on the fly
Parameters.insightec_tremor.Text_Relax.Content = [
    'REPOS'
    ];

% Text : Posture
Parameters.insightec_tremor.Text_Posture.PositonXRatio = 1/2;  % Xpos = PositonXRatio * ScreenWidth
Parameters.insightec_tremor.Text_Posture.PositonYRatio = 1/2;  % Ypos = PositonYRatio * ScreenHight
Parameters.insightec_tremor.Text_Posture.FontSize      = 80;
Parameters.insightec_tremor.Text_Posture.Content = [
    'POSTURE'
    ];

% Text : End of task
Parameters.insightec_tremor.Text_EndText.PositonXRatio = 1/2;  % Xpos = PositonXRatio * ScreenWidth
Parameters.insightec_tremor.Text_EndText.PositonYRatio = 1/2;  % Ypos = PositonYRatio * ScreenHight
Parameters.insightec_tremor.Text_EndText.FontSize      = 40;
Parameters.insightec_tremor.Text_EndText.Content = [
    'Fin de la tâche.\n'...
    'Restez immobile, nous allons vous aider à sortir du scanner.'
    ];


%%%%%%%%%%%%%%
%  Keybinds  %
%%%%%%%%%%%%%%

KbName('UnifyKeyNames');

Parameters.Keybinds.TTL_t_ASCII          = KbName('t'); % MRI trigger has to be the first defined key
Parameters.Keybinds.Stop_Escape_ASCII    = KbName('ESCAPE');

% switch S.Task
%     
%     case 'insightec_tremor'
%         
%         switch S.Environement
%             
%             case 'MRI'
%                 
%                 Parameters.Fingers.Left  = KbName('e'); % Index finger
%                 Parameters.Fingers.Right = KbName('b'); % Index finger
% 
%             case 'Practice'
%                 
%                 Parameters.Fingers.Left     = KbName('LeftArrow' );
%                 Parameters.Fingers.Right    = KbName('RightArrow');
%                 
%         end
%         
%         Parameters.Fingers.Names = {'Left' 'Right'};
%         
%     case {'insightec_tremor' 'TryLikertScale' }
%         
%         switch S.Environement
%             
%             case 'MRI'
%                 
%                 switch S.Side
%                     case 'Left'
%                         Parameters.Fingers.Right    = KbName('e'); % Index finger
%                         Parameters.Fingers.Validate = KbName('z'); % Middle finger
%                         Parameters.Fingers.Left     = KbName('n'); % Ring finger
%                     case 'Right'
%                         Parameters.Fingers.Left     = KbName('b'); % Index finger
%                         Parameters.Fingers.Validate = KbName('y'); % Middle finger
%                         Parameters.Fingers.Right    = KbName('g'); % Ring finger
%                 end
% 
%             case 'Practice'
%                 
%                 Parameters.Fingers.Left     = KbName('LeftArrow' );
%                 Parameters.Fingers.Validate = KbName('DownArrow' );
%                 Parameters.Fingers.Right    = KbName('RightArrow');
%                 
%         end
%         
%         Parameters.Fingers.Names = {'Left' 'Validate' 'Right'};
% 
% end


%% Echo in command window

EchoStop(mfilename)


end % function

