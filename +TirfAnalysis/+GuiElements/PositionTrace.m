classdef PositionTrace < TirfAnalysis.GuiElements.TogglingTrace
    properties (Access = protected, Constant)
        AUTOSCALE = 0
        Y_LABEL = 'Position (px)'
        DFT_YLIM = [0 4]
    end
    methods (Access = public)
        % constructor
        function obj = PositionTrace(figH,pos)
            import TirfAnalysis.GuiElements.PositionTrace
            obj = obj@TirfAnalysis.GuiElements.TogglingTrace(...
                figH,pos,...
                PositionTrace.LABELS_ALL,...
                PositionTrace.COLORS_ALL,...
                PositionTrace.Y_LABEL,...
                PositionTrace.X_LABEL);
            
            obj.LimitY = obj.DFT_YLIM;
            % set the timetrace limits
            set(obj.AxH,'YLim',obj.LimitY);
        end
        
    end
end