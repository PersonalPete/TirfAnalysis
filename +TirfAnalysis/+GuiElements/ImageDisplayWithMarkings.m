classdef ImageDisplayWithMarkings < TirfAnalysis.GuiElements.ImageDisplay
    % ImageDisplayWithMarkings is a child of ImageDisplay that adds the
    % option to plot crosses or circles over the image (to show
    % localisations or linkings)
    properties (Access = protected)
        UnCircLine
        UnCrosLine
    end
    
    properties (Constant, Access = protected)
        DFT_COL = [0.9 0.0 0.0] % red
        DFT_MAR_SIZ = 8 % marker size
    end
    
    methods (Access = public)
        % constructor
        function obj = ImageDisplayWithMarkings(figH,position,color)
            % call the superclass constructor
            obj = obj@TirfAnalysis.GuiElements.ImageDisplay(figH,position);
            
            if nargin < 3
                color = obj.DFT_COL;
            end
            
            obj.UnCircLine = line('Parent',obj.UnAxes,...
                'Marker','o',...
                'LineStyle','none',...
                'MarkerSize',obj.DFT_MAR_SIZ,...
                'MarkerEdgeColor',color,...
                'XData',[],'YData',[],...
                'HitTest','off');
            obj.UnCrosLine = line('Parent',obj.UnAxes,...
                'Marker','+',...
                'LineStyle','none',...
                'MarkerSize',obj.DFT_MAR_SIZ,...
                'MarkerEdgeColor',color,...
                'XData',[],'YData',[],...
                'HitTest','off');
        end
        
        function setMarkData(obj,circData,crosData)
            % circData (and crosData) is a Nx2 array of x-y positions
            if isempty(circData)
                set(obj.UnCircLine,'XData',[],...
                    'Ydata',[]);
            else
                set(obj.UnCircLine,'XData',circData(:,1),...
                    'Ydata',circData(:,2));
            end
            if isempty(crosData)
                set(obj.UnCrosLine,'XData',[],...
                    'YData',[]);
            else
                set(obj.UnCrosLine,'XData',crosData(:,1),...
                    'YData',crosData(:,2));
            end
        end
    end
end