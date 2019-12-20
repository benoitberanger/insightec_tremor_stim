classdef Text < baseObject
    %TEXT Class to print text in PTB
    
    %% Properties
    
    properties
        
        % Parameters
        
        color
        
        content
        
        font_size
        
        Xptb
        Yptb
        
        % Internal variables
        
        rect
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = Text( color, content, font_size, Xptb, Yptb )
            % self = Text( color, content, font_size, Xptb, Yptb )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                self.color     = color;
                self.content   = sprintf(content);
                self.font_size = font_size;
                self.Xptb      = Xptb;
                self.Yptb      = Yptb;
                
                % ================== Callback =============================
                
                self.UpdatePosition
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
