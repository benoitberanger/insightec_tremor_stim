function [ TEXT ] = Text
global S

color = S.Parameters.Text.Color;

% Find Text objects to create
fn = fieldnames(  S.Parameters.insightec_tremor );
txt_obj_idx = contains(fn, 'Text_');
param_names = fn(txt_obj_idx);
short_names = regexp(param_names,'_','split');

for i = 1 : length(param_names)
    Xptb      = S.Parameters.insightec_tremor.(param_names{i}).PositonXRatio * S.PTB.wRect(3);
    Yptb      = S.Parameters.insightec_tremor.(param_names{i}).PositonYRatio * S.PTB.wRect(4);
    font_size = S.Parameters.insightec_tremor.(param_names{i}).FontSize;
    content   = S.Parameters.insightec_tremor.(param_names{i}).Content;
    TextObj   = Text( color, content, font_size, Xptb, Yptb );
    TextObj.LinkToWindowPtr( S.PTB.wPtr )
    TextObj.AssertReady % just to check
    TEXT.(short_names{i}{2}) = TextObj;
end

end % function
