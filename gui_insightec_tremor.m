function varargout = gui_insightec_tremor
% SCHIRANG_GUI is the function that creates (or bring to focus) insightec_tremor GUI.
% Then, main_insightec_tremor is always called to start each task. It is the
% "main" program.

% debug=1 closes previous figure and reopens it, and send the gui handles
% to base workspace.
debug = 0;


%% Open a singleton figure, or gring the actual into focus.

% Is the GUI already open ?
figPtr = findall(0,'Tag',mfilename);

% Force go the directory
task_code_dir = fileparts(which(mfilename));
cd(task_code_dir) 

if ~isempty(figPtr) % Figure exists so brings it to the focus
    
    figure(figPtr);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if debug
        close(figPtr); %#ok<UNRCH>
        gui_insightec_tremor;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
else % Create the figure
    
    clc
    rng('default')
    rng('shuffle')
    
    % Create a figure
    figHandle = figure( ...
        'HandleVisibility', 'off',... % close all does not close the figure
        'MenuBar'         , 'none'                   , ...
        'Toolbar'         , 'none'                   , ...
        'Name'            , mfilename                , ...
        'NumberTitle'     , 'off'                    , ...
        'Units'           , 'Pixels'                 , ...
        'Position'        , [50, 50, 700, 700] , ...
        'Tag'             , mfilename                );
    
    figureBGcolor = [0.9 0.9 0.9]; set(figHandle,'Color',figureBGcolor);
    buttonBGcolor = figureBGcolor - 0.1;
    editBGcolor   = [1.0 1.0 1.0];
    
    % Create GUI handles : pointers to access the graphic objects
    handles               = guihandles(figHandle);
    
    handles.figureBGcolor = figureBGcolor;
    handles.buttonBGcolor = buttonBGcolor;
    handles.editBGcolor   = editBGcolor  ;

    handles.task_code_dir = task_code_dir;
    
    
    %% Panel proportions
    
    panelProp.xposP = 0.05; % xposition of panel normalized : from 0 to 1
    panelProp.wP    = 1 - panelProp.xposP * 2;
    
    panelProp.vect  = ...
        [1 2 2 1 2 ]; % relative proportions of each panel, from bottom to top
    
    panelProp.vectLength    = length(panelProp.vect);
    panelProp.vectTotal     = sum(panelProp.vect);
    panelProp.adjustedTotal = panelProp.vectTotal + 1;
    panelProp.unitWidth     = 1/panelProp.adjustedTotal;
    panelProp.interWidth    = panelProp.unitWidth/panelProp.vectLength;
    
    panelProp.countP = panelProp.vectLength + 1;
    panelProp.yposP  = @(countP) panelProp.unitWidth*sum(panelProp.vect(1:countP-1)) + 0.8*countP*panelProp.interWidth;
    
    
    %% Panel : Subject & Run
    
    p_sr.x = panelProp.xposP;
    p_sr.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_sr.y = panelProp.yposP(panelProp.countP);
    p_sr.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_SubjectRun = uipanel(handles.(mfilename),...
        'Title','Subject & Run',...
        'Units', 'Normalized',...
        'Position',[p_sr.x p_sr.y p_sr.w p_sr.h],...
        'BackgroundColor',figureBGcolor);
    
    p_sr.nbO       = 3; % Number of objects
    p_sr.Ow        = 1/(p_sr.nbO + 1); % Object width
    p_sr.countO    = 0; % Object counter
    p_sr.xposO     = @(countO) p_sr.Ow/(p_sr.nbO+1)*countO + (countO-1)*p_sr.Ow;
    p_sr.yposOmain = 0.1;
    p_sr.hOmain    = 0.6;
    p_sr.yposOhdr  = 0.7;
    p_sr.hOhdr     = 0.2;
    
    
    % ---------------------------------------------------------------------
    % Edit : Subject ID
    
    p_sr.countO = p_sr.countO + 1;
    e_sid.x = p_sr.xposO(p_sr.countO);
    e_sid.y = p_sr.yposOmain ;
    e_sid.w = p_sr.Ow;
    e_sid.h = p_sr.hOmain;
    handles.edit_SubjectID = uicontrol(handles.uipanel_SubjectRun,...
        'Style','edit',...
        'Units', 'Normalized',...
        'Position',[e_sid.x e_sid.y e_sid.w e_sid.h],...
        'BackgroundColor',editBGcolor,...
        'String','',...
        'Callback',@edit_SubjectID_Callback);
    
    
    % ---------------------------------------------------------------------
    % Text : Subject ID
    
    t_sid.x = p_sr.xposO(p_sr.countO);
    t_sid.y = p_sr.yposOhdr ;
    t_sid.w = p_sr.Ow;
    t_sid.h = p_sr.hOhdr;
    handles.text_SubjectID = uicontrol(handles.uipanel_SubjectRun,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_sid.x t_sid.y t_sid.w t_sid.h],...
        'String','Subject ID',...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Check SubjectID data
    
    p_sr.countO = p_sr.countO + 1;
    b_csidd.x = p_sr.xposO(p_sr.countO);
    b_csidd.y = p_sr.yposOmain;
    b_csidd.w = p_sr.Ow;
    b_csidd.h = p_sr.hOmain;
    handles.pushbutton_Check_SubjectID_data = uicontrol(handles.uipanel_SubjectRun,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_csidd.x b_csidd.y b_csidd.w b_csidd.h],...
        'String','Check SubjectID data',...
        'BackgroundColor',buttonBGcolor,...
        'TooltipString','Display in Command Window the content of data/(SubjectID)',...
        'Callback',@(hObject,eventdata)GUI.Pushbutton_Check_SubjectID_data_Callback(handles.edit_SubjectID,eventdata));
    
    
    % ---------------------------------------------------------------------
    % Text : Last file name annoucer
    
    p_sr.countO = p_sr.countO + 1;
    t_lfna.x = p_sr.xposO(p_sr.countO);
    t_lfna.y = p_sr.yposOhdr ;
    t_lfna.w = p_sr.Ow;
    t_lfna.h = p_sr.hOhdr;
    handles.text_LastFileNameAnnouncer = uicontrol(handles.uipanel_SubjectRun,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_lfna.x t_lfna.y t_lfna.w t_lfna.h],...
        'String','Last file name',...
        'BackgroundColor',figureBGcolor,...
        'Visible','Off');
    
    
    % ---------------------------------------------------------------------
    % Text : Last file name
    
    t_lfn.x = p_sr.xposO(p_sr.countO);
    t_lfn.y = p_sr.yposOmain ;
    t_lfn.w = p_sr.Ow;
    t_lfn.h = p_sr.hOmain;
    handles.text_LastFileName = uicontrol(handles.uipanel_SubjectRun,...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_lfn.x t_lfn.y t_lfn.w t_lfn.h],...
        'String','',...
        'BackgroundColor',figureBGcolor,...
        'Visible','Off');
    
    
    %% Panel : Save mode
    
    p_sm.x = panelProp.xposP;
    p_sm.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_sm.y = panelProp.yposP(panelProp.countP);
    p_sm.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_SaveMode = uibuttongroup(handles.(mfilename),...
        'Title','Save mode',...
        'Units', 'Normalized',...
        'Position',[p_sm.x p_sm.y p_sm.w p_sm.h],...
        'BackgroundColor',figureBGcolor);
    
    p_sm.nbO    = 2; % Number of objects
    p_sm.Ow     = 1/(p_sm.nbO + 1); % Object width
    p_sm.countO = 0; % Object counter
    p_sm.xposO  = @(countO) p_sm.Ow/(p_sm.nbO+1)*countO + (countO-1)*p_sm.Ow;
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Save Data
    
    p_sm.countO = p_sm.countO + 1;
    r_sd.x   = p_sm.xposO(p_sm.countO);
    r_sd.y   = 0.1 ;
    r_sd.w   = p_sm.Ow;
    r_sd.h   = 0.8;
    r_sd.tag = 'radiobutton_SaveData';
    handles.(r_sd.tag) = uicontrol(handles.uipanel_SaveMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_sd.x r_sd.y r_sd.w r_sd.h],...
        'String','Save data',...
        'TooltipString','Save data to : ../data/SubjectID/...',...
        'HorizontalAlignment','Center',...
        'Tag',r_sd.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : No save
    
    p_sm.countO = p_sm.countO + 1;
    r_ns.x   = p_sm.xposO(p_sm.countO);
    r_ns.y   = 0.1 ;
    r_ns.w   = p_sm.Ow;
    r_ns.h   = 0.8;
    r_ns.tag = 'radiobutton_NoSave';
    handles.(r_ns.tag) = uicontrol(handles.uipanel_SaveMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_ns.x r_ns.y r_ns.w r_ns.h],...
        'String','No save',...
        'TooltipString','In Acquisition mode, Save mode must be engaged',...
        'HorizontalAlignment','Center',...
        'Tag',r_ns.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    %     %% Panel : Environement
    %
    %     p_env.x = panelProp.xposP;
    %     p_env.w = panelProp.wP;
    %
    %     panelProp.countP = panelProp.countP - 1;
    %     p_env.y = panelProp.yposP(panelProp.countP);
    %     p_env.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    %
    %     handles.uipanel_Environement = uibuttongroup(handles.(mfilename),...
    %         'Title','Environement : key mapping',...
    %         'Units', 'Normalized',...
    %         'Position',[p_env.x p_env.y p_env.w p_env.h],...
    %         'BackgroundColor',figureBGcolor);
    %
    %     p_env.nbO    = 2; % Number of objects
    %     p_env.Ow     = 1/(p_env.nbO + 1); % Object width
    %     p_env.countO = 0; % Object counter
    %     p_env.xposO  = @(countO) p_env.Ow/(p_env.nbO+1)*countO + (countO-1)*p_env.Ow;
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : MRI
    %
    %     p_env.countO = p_env.countO + 1;
    %     r_mri.x   = p_env.xposO(p_env.countO);
    %     r_mri.y   = 0.1 ;
    %     r_mri.w   = p_env.Ow;
    %     r_mri.h   = 0.8;
    %     r_mri.tag = 'radiobutton_MRI';
    %     handles.(r_mri.tag) = uicontrol(handles.uipanel_Environement,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_mri.x r_mri.y r_mri.w r_mri.h],...
    %         'String','MRI : use fORP response box',...
    %         'TooltipString','will use B and Y',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',(r_mri.tag),...
    %         'BackgroundColor',figureBGcolor);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : Practice
    %
    %     p_env.countO = p_env.countO + 1;
    %     r_practice.x   = p_env.xposO(p_env.countO);
    %     r_practice.y   = 0.1 ;
    %     r_practice.w   = p_env.Ow;
    %     r_practice.h   = 0.8;
    %     r_practice.tag = 'radiobutton_Practice';
    %     handles.(r_practice.tag) = uicontrol(handles.uipanel_Environement,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_practice.x r_practice.y r_practice.w r_practice.h],...
    %         'String','no MRI : keyboard L/D/R arrows',...
    %         'TooltipString','will use LeftArrow and RightArrow',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',(r_practice.tag),...
    %         'BackgroundColor',figureBGcolor);
    
    
    %     %% Panel : Left & Right buttons
    %
    %     p_pplr.x = panelProp.xposP;
    %     p_pplr.w = panelProp.wP;
    %
    %     panelProp.countP = panelProp.countP - 1;
    %     p_pplr.y = panelProp.yposP(panelProp.countP);
    %     p_pplr.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    %
    %     handles.uipanel_LeftRight = uibuttongroup(handles.(mfilename),...
    %         'Title','Which side for YES :',...
    %         'Units', 'Normalized',...
    %         'Position',[p_pplr.x p_pplr.y p_pplr.w p_pplr.h],...
    %         'BackgroundColor',figureBGcolor);
    %
    %     p_pplr.nbO    = 2; % Number of objects
    %     p_pplr.Ow     = 1/(p_pplr.nbO + 1); % Object width
    %     p_pplr.countO = 0; % Object counter
    %     p_pplr.xposO  = @(countO) p_pplr.Ow/(p_pplr.nbO+1)*countO + (countO-1)*p_pplr.Ow;
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : Left buttons
    %
    %     p_pplr.countO = p_pplr.countO + 1;
    %     r_left.x   = p_pplr.xposO(p_pplr.countO);
    %     r_left.y   = 0.1 ;
    %     r_left.w   = p_pplr.Ow;
    %     r_left.h   = 0.8;
    %     r_left.tag = 'radiobutton_LeftButtons';
    %     handles.(r_left.tag) = uicontrol(handles.uipanel_LeftRight,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_left.x r_left.y r_left.w r_left.h],...
    %         'String','Left',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_left.tag,...
    %         'BackgroundColor',figureBGcolor,...
    %         'Tooltip','YES will bo on the LEFT side');
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : Right buttons
    %
    %     p_pplr.countO = p_pplr.countO + 1;
    %     r_right.x   = p_pplr.xposO(p_pplr.countO);
    %     r_right.y   = 0.1 ;
    %     r_right.w   = p_pplr.Ow;
    %     r_right.h   = 0.8;
    %     r_right.tag = 'radiobutton_RightButtons';
    %     handles.(r_right.tag) = uicontrol(handles.uipanel_LeftRight,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_right.x r_right.y r_right.w r_right.h],...
    %         'String','Right',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_right.tag,...
    %         'BackgroundColor',figureBGcolor,...
    %         'Tooltip','YES will bo on the RIGHT side');
    
    
    %% Panel : Eyelink mode
    
    el_shift = 0.25;
    
    p_el.x = panelProp.xposP/2 + el_shift;
    p_el.w = panelProp.wP - el_shift + panelProp.xposP/2;
    
    panelProp.countP = panelProp.countP - 1;
    p_el.y = panelProp.yposP(panelProp.countP);
    p_el.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_EyelinkMode = uibuttongroup(handles.(mfilename),...
        'Title','Eyelink mode',...
        'Units', 'Normalized',...
        'Position',[p_el.x p_el.y p_el.w p_el.h],...
        'BackgroundColor',figureBGcolor,...
        'SelectionChangeFcn',@uipanel_EyelinkMode_SelectionChangeFcn);
    
    
    % ---------------------------------------------------------------------
    % Checkbox : Windowed screen
    
    c_ws.x = panelProp.xposP;
    c_ws.w = el_shift - panelProp.xposP/2;
    
    c_ws.y = panelProp.yposP(panelProp.countP)-0.01 ;
    c_ws.h = p_el.h * 0.3;
    
    handles.checkbox_WindowedScreen = uicontrol(handles.(mfilename),...
        'Style','checkbox',...
        'Units', 'Normalized',...
        'Position',[c_ws.x c_ws.y c_ws.w c_ws.h],...
        'String','Windowed screen',...
        'HorizontalAlignment','Center',...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % Listbox : Screens
    
    l_sc.x = panelProp.xposP;
    l_sc.w = el_shift - panelProp.xposP;
    
    l_sc.y = c_ws.y + c_ws.h ;
    l_sc.h = p_el.h * 0.6;
    
    handles.listbox_Screens = uicontrol(handles.(mfilename),...
        'Style','listbox',...
        'Units', 'Normalized',...
        'Position',[l_sc.x l_sc.y l_sc.w l_sc.h],...
        'String',{'a' 'b' 'c'},...
        'TooltipString','Select the display mode   PTB : 0 for extended display (over all screens) , 1 for screen 1 , 2 for screen 2 , etc.',...
        'HorizontalAlignment','Center',...
        'CreateFcn',@GUI.Listbox_Screens_CreateFcn);
    
    
    % ---------------------------------------------------------------------
    % Text : ScreenMode
    
    t_sm.x = panelProp.xposP;
    t_sm.w = el_shift - panelProp.xposP;
    
    t_sm.y = l_sc.y + l_sc.h ;
    t_sm.h = p_el.h * 0.15;
    
    handles.text_ScreenMode = uicontrol(handles.(mfilename),...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_sm.x t_sm.y t_sm.w t_sm.h],...
        'String','Screen mode selection',...
        'TooltipString','Output of Screen(''Screens'')   Use ''Screen Screens?'' in Command window for help',...
        'HorizontalAlignment','Center',...
        'BackgroundColor',figureBGcolor);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    p_el_up.nbO    = 6; % Number of objects
    p_el_up.Ow     = 1/(p_el_up.nbO + 1); % Object width
    p_el_up.countO = 0; % Object counter
    p_el_up.xposO  = @(countO) p_el_up.Ow/(p_el_up.nbO+1)*countO + (countO-1)*p_el_up.Ow;
    p_el_up.y      = 0.6;
    p_el_up.h      = 0.3;
    
    % ---------------------------------------------------------------------
    % RadioButton : Eyelink ON
    
    p_el_up.countO = p_el_up.countO + 1;
    r_elon.x   = p_el_up.xposO(p_el_up.countO);
    r_elon.y   = p_el_up.y ;
    r_elon.w   = p_el_up.Ow;
    r_elon.h   = p_el_up.h;
    r_elon.tag = 'radiobutton_EyelinkOn';
    handles.(r_elon.tag) = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_elon.x r_elon.y r_elon.w r_elon.h],...
        'String','On',...
        'HorizontalAlignment','Center',...
        'Tag',r_elon.tag,...
        'BackgroundColor',figureBGcolor,...
        'Visible','On');
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Eyelink OFF
    
    p_el_up.countO = p_el_up.countO + 1;
    r_eloff.x   = p_el_up.xposO(p_el_up.countO);
    r_eloff.y   = p_el_up.y ;
    r_eloff.w   = p_el_up.Ow;
    r_eloff.h   = p_el_up.h;
    r_eloff.tag = 'radiobutton_EyelinkOff';
    handles.(r_eloff.tag) = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_eloff.x r_eloff.y r_eloff.w r_eloff.h],...
        'String','Off',...
        'HorizontalAlignment','Center',...
        'Tag',r_eloff.tag,...
        'BackgroundColor',figureBGcolor,...
        'Visible','On');
    
    
    % ---------------------------------------------------------------------
    % Checkbox : Parallel port
    
    p_el_up.countO = p_el_up.countO + 1;
    c_pp.x = p_el_up.xposO(p_el_up.countO);
    c_pp.y = p_el_up.y ;
    c_pp.w = p_el_up.Ow*2;
    c_pp.h = p_el_up.h;
    handles.checkbox_ParPort = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','checkbox',...
        'Units', 'Normalized',...
        'Position',[c_pp.x c_pp.y c_pp.w c_pp.h],...
        'String','Parallel port',...
        'HorizontalAlignment','Center',...
        'TooltipString','Send messages via parallel port : useful for Eyelink',...
        'BackgroundColor',figureBGcolor,...
        'Value',1,...
        'Callback',@GUI.Checkbox_ParPort_Callback,...
        'CreateFcn',@GUI.Checkbox_ParPort_Callback);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    p_el_dw.nbO    = 4.5; % Number of objects
    p_el_dw.Ow     = 1/(p_el_dw.nbO + 1); % Object width
    p_el_dw.countO = 0; % Object counter
    p_el_dw.xposO  = @(countO) p_el_dw.Ow/(p_el_dw.nbO+1)*countO + (countO-1)*p_el_dw.Ow;
    p_el_dw.y      = 0.1;
    p_el_dw.h      = 0.4 ;
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink Initialize
    
    p_el_dw.countO = p_el_dw.countO + 1;
    b_init.x = p_el_dw.xposO(p_el_dw.countO);
    b_init.y = p_el_dw.y ;
    b_init.w = p_el_dw.Ow;
    b_init.h = p_el_dw.h;
    handles.pushbutton_Initialize = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_init.x b_init.y b_init.w b_init.h],...
        'String','Initialize',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.Initialize');
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink IsConnected
    
    p_el_dw.countO = p_el_dw.countO + 1;
    b_isco.x = p_el_dw.xposO(p_el_dw.countO);
    b_isco.y = p_el_dw.y ;
    b_isco.w = p_el_dw.Ow;
    b_isco.h = p_el_dw.h;
    handles.pushbutton_IsConnected = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_isco.x b_isco.y b_isco.w b_isco.h],...
        'String','IsConnected',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.IsConnected');
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink Calibration
    
    p_el_dw.countO = p_el_dw.countO + 1;
    b_cal.x   = p_el_dw.xposO(p_el_dw.countO);
    b_cal.y   = p_el_dw.y ;
    b_cal.w   = p_el_dw.Ow;
    b_cal.h   = p_el_dw.h;
    b_cal.tag = 'pushbutton_EyelinkCalibration';
    handles.(b_cal.tag) = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_cal.x b_cal.y b_cal.w b_cal.h],...
        'String','Calibration',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_cal.tag,...
        'Callback',@pushbutton_EyelinkCalibration_Callback);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Download EL files according to the SubjectID
    
    p_el_dw.countO = p_el_dw.countO + 1;
    b_cal.x   = p_el_dw.xposO(p_el_dw.countO);
    b_cal.y   = p_el_dw.y ;
    b_cal.w   = p_el_dw.Ow*1.5;
    b_cal.h   = p_el_dw.h;
    b_cal.tag = 'pushbutton_DownloadELfiles';
    handles.(b_cal.tag) = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_cal.x b_cal.y b_cal.w b_cal.h],...
        'String','Download files',...
        'BackgroundColor',buttonBGcolor*0.9,...
        'Tag',b_cal.tag,...
        'Callback',@pushbutton_DownloadELfiles_Callback);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink force shutdown
    
    b_fsd.x = c_pp.x + c_pp.h;
    b_fsd.y = p_el_up.y ;
    b_fsd.w = p_el_dw.Ow*1.50;
    b_fsd.h = p_el_dw.h;
    handles.pushbutton_ForceShutDown = uicontrol(handles.uipanel_EyelinkMode,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_fsd.x b_fsd.y b_fsd.w b_fsd.h],...
        'String','ForceShutDown',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.ForceShutDown');
    
    %
    %     %% Panel : Image masking
    %
    %     p_mask.x = panelProp.xposP;
    %     p_mask.w = panelProp.wP;
    %
    %     panelProp.countP = panelProp.countP - 1;
    %     p_mask.y = panelProp.yposP(panelProp.countP);
    %     p_mask.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    %
    %     handles.uipanel_Mask = uibuttongroup(handles.(mfilename),...
    %         'Title','Mask images',...
    %         'Units', 'Normalized',...
    %         'Position',[p_mask.x p_mask.y p_mask.w p_mask.h],...
    %         'BackgroundColor',figureBGcolor);
    %
    %     p_mask.nbO    = 3; % Number of objects
    %     p_mask.Ow     = 1/(p_mask.nbO + 1); % Object width
    %     p_mask.countO = 0; % Object counter
    %     p_mask.xposO  = @(countO) p_mask.Ow/(p_mask.nbO+1)*countO + (countO-1)*p_mask.Ow;
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : No masking
    %
    %     p_mask.countO = p_mask.countO + 1;
    %     r_left.x   = p_mask.xposO(p_mask.countO);
    %     r_left.y   = 0.1 ;
    %     r_left.w   = p_mask.Ow;
    %     r_left.h   = 0.8;
    %     r_left.tag = 'radiobutton_NoMask';
    %     handles.(r_left.tag) = uicontrol(handles.uipanel_Mask,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_left.x r_left.y r_left.w r_left.h],...
    %         'String','No masking',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_left.tag,...
    %         'BackgroundColor',figureBGcolor,...
    %         'Tooltip','Real images');
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : Shuffle pixels
    %
    %     p_mask.countO = p_mask.countO + 1;
    %     r_left.x   = p_mask.xposO(p_mask.countO);
    %     r_left.y   = 0.1 ;
    %     r_left.w   = p_mask.Ow;
    %     r_left.h   = 0.8;
    %     r_left.tag = 'radiobutton_ShuffleMask';
    %     handles.(r_left.tag) = uicontrol(handles.uipanel_Mask,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_left.x r_left.y r_left.w r_left.h],...
    %         'String','Shuffle pixels',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_left.tag,...
    %         'BackgroundColor',figureBGcolor,...
    %         'Tooltip','Shuffle pixels');
    %
    %
    %     % ---------------------------------------------------------------------
    %     % RadioButton : Dark images
    %
    %     p_mask.countO = p_mask.countO + 1;
    %     r_left.x   = p_mask.xposO(p_mask.countO);
    %     r_left.y   = 0.1 ;
    %     r_left.w   = p_mask.Ow;
    %     r_left.h   = 0.8;
    %     r_left.tag = 'radiobutton_DarkMask';
    %     handles.(r_left.tag) = uicontrol(handles.uipanel_Mask,...
    %         'Style','radiobutton',...
    %         'Units', 'Normalized',...
    %         'Position',[r_left.x r_left.y r_left.w r_left.h],...
    %         'String','Dark images',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_left.tag,...
    %         'BackgroundColor',figureBGcolor,...
    %         'Tooltip','Divide pixel intensity by 10');
    
    
    %     %% Panel : Pre / Post
    %
    %     p_prepost.x = panelProp.xposP;
    %     p_prepost.w = panelProp.wP/2;
    %
    %     panelProp.countP = panelProp.countP - 1;
    %     p_prepost.y = panelProp.yposP(panelProp.countP);
    %     p_prepost.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    %
    %     handles.uipanel_PrePost = uibuttongroup(handles.(mfilename),...
    %         'Title','Pre / Post',...
    %         'Units', 'Normalized',...
    %         'Position',[p_prepost.x p_prepost.y p_prepost.w p_prepost.h],...
    %         'BackgroundColor',figureBGcolor);
    %
    %     p_prepost = Object_Xpos_Xwidth_dispacher([ 1 1 ],p_prepost);
    %
    %     % ---------------------------------------------------------------------
    %     % Radiobutton : Pre
    %
    %     p_prepost.count = p_prepost.count + 1;
    %     r_Pre.x   = p_prepost.xpos(p_prepost.count);
    %     r_Pre.y   = 0.1;
    %     r_Pre.w   = p_prepost.xwidth(p_prepost.count)/2;
    %     r_Pre.h   = 0.8;
    %     r_Pre.tag = 'radiobutton_Pre';
    %     handles.(r_Pre.tag) = uicontrol(handles.uipanel_PrePost,...
    %         'Style','radio',...
    %         'Units', 'Normalized',...
    %         'Position',[r_Pre.x r_Pre.y r_Pre.w r_Pre.h],...
    %         'String','Pre',...
    %         'TooltipString','pictures for run Pre stimulation ',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_Pre.tag,...
    %         'BackgroundColor',figureBGcolor);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % Radiobutton : Post
    %
    %     p_prepost.count = p_prepost.count + 1;
    %     r_Post.x   = p_prepost.xpos(p_prepost.count) + p_prepost.xwidth(p_prepost.count)/2;
    %     r_Post.y   = 0.1;
    %     r_Post.w   = p_prepost.xwidth(p_prepost.count)/2;
    %     r_Post.h   = 0.8;
    %     r_Post.tag = 'radiobutton_Post';
    %     handles.(r_Post.tag) = uicontrol(handles.uipanel_PrePost,...
    %         'Style','radio',...
    %         'Units', 'Normalized',...
    %         'Position',[r_Post.x r_Post.y r_Post.w r_Post.h],...
    %         'String','Post',...
    %         'TooltipString','pictures for run Post stimulation',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_Post.tag,...
    %         'BackgroundColor',figureBGcolor);
    
    
    %     %% Panel : List A / B
    %
    %     p_listAB.x = panelProp.xposP + panelProp.wP/2;
    %     p_listAB.w = panelProp.wP/2;
    %
    %     p_listAB.y = panelProp.yposP(panelProp.countP);
    %     p_listAB.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    %
    %     handles.uipanel_ListAB = uibuttongroup(handles.(mfilename),...
    %         'Title','List A / B',...
    %         'Units', 'Normalized',...
    %         'Position',[p_listAB.x p_listAB.y p_listAB.w p_listAB.h],...
    %         'BackgroundColor',figureBGcolor);
    %
    %     p_listAB = Object_Xpos_Xwidth_dispacher([ 1 1 ],p_listAB);
    %
    %     % ---------------------------------------------------------------------
    %     % Radiobutton : A
    %
    %     p_listAB.count = p_listAB.count + 1;
    %     r_listA.x   = p_listAB.xpos(p_listAB.count);
    %     r_listA.y   = 0.1;
    %     r_listA.w   = p_listAB.xwidth(p_listAB.count)/2;
    %     r_listA.h   = 0.8;
    %     r_listA.tag = 'radiobutton_ListA';
    %     handles.(r_listA.tag) = uicontrol(handles.uipanel_ListAB,...
    %         'Style','radio',...
    %         'Units', 'Normalized',...
    %         'Position',[r_listA.x r_listA.y r_listA.w r_listA.h],...
    %         'String','A',...
    %         'TooltipString','List A',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_listA.tag,...
    %         'BackgroundColor',figureBGcolor);
    %
    %
    %     % ---------------------------------------------------------------------
    %     % Radiobutton : B
    %
    %     p_listAB.count = p_listAB.count + 1;
    %     r_listB.x   = p_listAB.xpos(p_listAB.count) + p_listAB.xwidth(p_listAB.count)/2;
    %     r_listB.y   = 0.1;
    %     r_listB.w   = p_listAB.xwidth(p_listAB.count)/2;
    %     r_listB.h   = 0.8;
    %     r_listB.tag = 'radiobutton_ListB';
    %     handles.(r_listB.tag) = uicontrol(handles.uipanel_ListAB,...
    %         'Style','radio',...
    %         'Units', 'Normalized',...
    %         'Position',[r_listB.x r_listB.y r_listB.w r_listB.h],...
    %         'String','B',...
    %         'TooltipString','List B',...
    %         'HorizontalAlignment','Center',...
    %         'Tag',r_listB.tag,...
    %         'BackgroundColor',figureBGcolor);
    
    
    %% Panel : Task
    
    p_tk.x = panelProp.xposP;
    p_tk.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_tk.y = panelProp.yposP(panelProp.countP);
    p_tk.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_Task = uibuttongroup(handles.(mfilename),...
        'Title','Task',...
        'Units', 'Normalized',...
        'Position',[p_tk.x p_tk.y p_tk.w p_tk.h],...
        'BackgroundColor',figureBGcolor);
    
    buttun_y = 0.05;
    buttun_h = 0.90;
    
    % ---------------------------------------------------------------------
    % Pushbutton : insightec_tremor
    
    b_task.x   = 0.05;
    b_task.y   = buttun_y;
    b_task.w   = 0.90;
    b_task.h   = buttun_h;
    b_task.tag = 'pushbutton_insightec_tremor';
    handles.(b_task.tag) = uicontrol(handles.uipanel_Task,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_task.x b_task.y b_task.w b_task.h],...
        'String','insightec_tremor',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_task.tag,...
        'Callback',@main_insightec_tremor,...
        'Tooltip','');
    
    
    %% Panel : Operation mode
    
    p_op.x = panelProp.xposP;
    p_op.w = panelProp.wP;
    
    panelProp.countP = panelProp.countP - 1;
    p_op.y = panelProp.yposP(panelProp.countP);
    p_op.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_OperationMode = uibuttongroup(handles.(mfilename),...
        'Title','Operation mode',...
        'Units', 'Normalized',...
        'Position',[p_op.x p_op.y p_op.w p_op.h],...
        'BackgroundColor',figureBGcolor);
    
    p_op.nbO    = 3; % Number of objects
    p_op.Ow     = 1/(p_op.nbO + 1); % Object width
    p_op.countO = 0; % Object counter
    p_op.xposO  = @(countO) p_op.Ow/(p_op.nbO+1)*countO + (countO-1)*p_op.Ow;
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Acquisition
    
    p_op.countO = p_op.countO + 1;
    r_aq.x = p_op.xposO(p_op.countO);
    r_aq.y = 0.1 ;
    r_aq.w = p_op.Ow;
    r_aq.h = 0.8;
    r_aq.tag = 'radiobutton_Acquisition';
    handles.(r_aq.tag) = uicontrol(handles.uipanel_OperationMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_aq.x r_aq.y r_aq.w r_aq.h],...
        'String','Acquisition',...
        'TooltipString','Save data, execute full script',...
        'HorizontalAlignment','Center',...
        'Tag',r_aq.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : FastDebug
    
    p_op.countO = p_op.countO + 1;
    r_fd.x   = p_op.xposO(p_op.countO);
    r_fd.y   = 0.1 ;
    r_fd.w   = p_op.Ow;
    r_fd.h   = 0.8;
    r_fd.tag = 'radiobutton_FastDebug';
    handles.radiobutton_FastDebug = uicontrol(handles.uipanel_OperationMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_fd.x r_fd.y r_fd.w r_fd.h],...
        'String','FastDebug',...
        'TooltipString','Don''t save data, run the scripts very fast',...
        'HorizontalAlignment','Center',...
        'Tag',r_fd.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    % ---------------------------------------------------------------------
    % RadioButton : RealisticDebug
    
    p_op.countO = p_op.countO + 1;
    r_rd.x   = p_op.xposO(p_op.countO);
    r_rd.y   = 0.1 ;
    r_rd.w   = p_op.Ow;
    r_rd.h   = 0.8;
    r_rd.tag = 'radiobutton_RealisticDebug';
    handles.(r_rd.tag) = uicontrol(handles.uipanel_OperationMode,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_rd.x r_rd.y r_rd.w r_rd.h],...
        'String','RealisticDebug',...
        'TooltipString','ODon''t save data, run the scripts ~normal speed',...
        'HorizontalAlignment','Center',...
        'Tag',r_rd.tag,...
        'BackgroundColor',figureBGcolor);
    
    
    %% End of opening
    
    % IMPORTANT
    guidata(figHandle,handles)
    % After creating the figure, dont forget the line
    % guidata(figHandle,handles) . It allows smart retrive like
    % handles=guidata(hObject)
    
    %     % Disable & Hide EYELINK On
    %     set(handles.uipanel_EyelinkMode,'SelectedObject',handles.radiobutton_EyelinkOff)
    %     eventdata.NewValue = handles.radiobutton_EyelinkOff;
    %     uipanel_EyelinkMode_SelectionChangeFcn(handles.uipanel_EyelinkMode, eventdata)
    %     set(handles.radiobutton_EyelinkOn,'Visible','off')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if debug
        assignin('base','handles',handles) %#ok<UNRCH>
        disp(handles)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figPtr = figHandle;
    
    fprintf('\n')
    fprintf('Response buttons (fORRP 932) : \n')
    fprintf('USB \n')
    fprintf('whatever the button, we don''t use them \n')
    fprintf('HID NAR BYGRT \n')
    fprintf('\n')
    
    
end

if nargout > 0
    
    varargout{1} = guidata(figPtr);
    
end


end % function


%% GUI Functions

% -------------------------------------------------------------------------
function edit_SubjectID_Callback(hObject, ~)

MinNrChar = 3;

id_str = get(hObject,'String');

if length(id_str) < MinNrChar
    set(hObject,'String','')
    error('SubjectID must be at least %d chars', MinNrChar)
end

fprintf('SubjectID OK : %s \n', id_str)

end % function


% -------------------------------------------------------------------------
function uipanel_EyelinkMode_SelectionChangeFcn(hObject, eventdata)
handles = guidata(hObject);

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radiobutton_EyelinkOff'
        set(handles.pushbutton_EyelinkCalibration,'Visible','off')
        set(handles.pushbutton_IsConnected       ,'Visible','off')
        set(handles.pushbutton_ForceShutDown     ,'Visible','off')
        set(handles.pushbutton_Initialize        ,'Visible','off')
        set(handles.pushbutton_DownloadELfiles   ,'Visible','off')
    case 'radiobutton_EyelinkOn'
        set(handles.pushbutton_EyelinkCalibration,'Visible','on')
        set(handles.pushbutton_IsConnected       ,'Visible','on')
        set(handles.pushbutton_ForceShutDown     ,'Visible','on')
        set(handles.pushbutton_Initialize        ,'Visible','on')
        set(handles.pushbutton_DownloadELfiles   ,'Visible','on')
end

end % function


% -------------------------------------------------------------------------
function pushbutton_EyelinkCalibration_Callback(hObject, ~)
handles = guidata(hObject);

% Screen mode selection
AvalableDisplays = get(handles.listbox_Screens,'String');
SelectedDisplay  = get(handles.listbox_Screens,'Value' );
wPtr             = str2double( AvalableDisplays(SelectedDisplay) );

Eyelink.OpenCalibration(wPtr);

end % function


% -------------------------------------------------------------------------
function pushbutton_DownloadELfiles_Callback(hObject, ~)
handles = guidata(hObject);

SubjectID = fetch_SubjectID(handles);
DataPath  = fullfile(fileparts(pwd), 'data', SubjectID);
el_file   = fullfile(DataPath, 'eyelink_files_to_download.txt');

if ~exist(el_file,'file')
    error('File does not exists : %s', el_file)
end

Eyelink.downloadELfiles(DataPath)

end % function


% % -------------------------------------------------------------------------
% function obj = Object_Xpos_Xwidth_dispatcher( vect , obj )
% 
% obj.vect  = vect; % relative proportions of each panel, from left to right
% 
% obj.vectLength    = length(obj.vect);
% obj.vectTotal     = sum(obj.vect);
% obj.adjustedTotal = obj.vectTotal + 1;
% obj.unitWidth     = 1/obj.adjustedTotal;
% obj.interWidth    = obj.unitWidth/obj.vectLength;
% 
% obj.count  = 0;
% obj.xpos   = @(count) obj.unitWidth*sum(obj.vect(1:(count-1))) + 0.8*count*obj.interWidth;
% obj.xwidth = @(count) obj.vect(count)*obj.unitWidth;
% 
% end % function


% -------------------------------------------------------------------------
function SubjectID = fetch_SubjectID(handles)

SubjectID = get(handles.edit_SubjectID,'String');
if isempty(SubjectID)
    error('SubjectID:Empty','SubjectID is empty')
end

end
