function Draw( self, content )

if nargin > 1
    self.content = content;
end

Screen('TextSize' , self.wPtr, self.font_size);

%[nx, ny, textbounds, wordbounds] = DrawFormattedText(win, tstring [, sx][, sy][, color][, wrapat][, flipHorizontal][, flipVertical][, vSpacing][, righttoleft][, winRect])
% DrawFormattedText(self.wPtr, self.content, 'center', 'center', self.color, [], [], [], [], [], self.rect);
DrawFormattedText(self.wPtr, self.content, 'center', 'center', self.color);

end % function
