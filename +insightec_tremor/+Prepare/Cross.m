function [ cross ] = Cross
global S

dim    = round(S.PTB.wRect(4)*S.Parameters.insightec_tremor.FixationCross.ScreenRatio);
width  = round(dim * S.Parameters.insightec_tremor.FixationCross.lineWidthRatio);
color  = S.Parameters.insightec_tremor.FixationCross.Color;
center = [...
    S.Parameters.insightec_tremor.FixationCross.PositonYRatio*S.PTB.wRect(3) ... % arbitrary, will be updated in the script
    S.Parameters.insightec_tremor.FixationCross.PositonYRatio*S.PTB.wRect(4) ... 
    ];

center = round(center);

cross = FixationCross(...
    dim   ,... % dimension in pixels
    width ,... % width     in pixels
    color ,... % color     [R G B] 0-255
    center );  % center    in pixels

cross.LinkToWindowPtr( S.PTB.wPtr )

cross.AssertReady % just to check

end % function
