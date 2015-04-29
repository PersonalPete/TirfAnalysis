classdef ImageDisplayNoScaling < TirfAnalysis.GuiElements.ImageDisplay
    
    methods (Access = public)
        % constructor
        function obj = ImageDisplayNoScaling(figH,position)
            % call the superclass constructor
            if nargin == 0
                superArgs = {};
            else
                superArgs = {figH; position};
            end
            obj = obj@TirfAnalysis.GuiElements.ImageDisplay(superArgs);
        end
        
        % @Override setImData
        function setImData(obj,imData)
            set(obj.UnImage,'CData',imData);
            % set the default viewing limits
            obj.MaxX = max(size(imData,2),1);
            obj.MaxY = max(size(imData,1),1);
            set(obj.UnAxes,'Xlim',[0 obj.MaxX],...
                'YLim',[0 obj.MaxY]);
            
            % no scaling behaviour here
            
        end
       
        % scaling can be done with:
        % @Override setImData
        function setColorLim(obj,cMin,cMax) 
            set(obj.UnAxes,'Clim',[cMin cMax]);
        end
        
    end
end