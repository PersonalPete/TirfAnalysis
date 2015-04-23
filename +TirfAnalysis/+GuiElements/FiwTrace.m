classdef FiwTrace < TirfAnalysis.GuiElements.TogglingTrace
    properties (Access = protected, Constant)
        AUTOSCALE = 0        
        Y_LABEL = 'FIW (px)'
        DFT_YLIM = [0.8 2]
    end
    methods (Access = public)
       % constructor
       function obj = FiwTrace(figH,pos)
           import TirfAnalysis.GuiElements.FiwTrace
           obj = obj@TirfAnalysis.GuiElements.TogglingTrace(...
               figH,pos,...
               FiwTrace.LABELS_ALL,...
               FiwTrace.COLORS_ALL,...
               FiwTrace.Y_LABEL);
           
           obj.LimitY = obj.DFT_YLIM;
           % set the FIW timetrace limits
           set(obj.AxH,'YLim',obj.LimitY);
       end
    end
end