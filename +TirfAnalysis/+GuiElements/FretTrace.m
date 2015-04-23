classdef FretTrace < TirfAnalysis.GuiElements.TogglingTrace
    properties (Access = protected, Constant)
        AUTOSCALE = 0        
        Y_LABEL = 'FRET'
        DFT_YLIM = [0 1]
    end
    methods (Access = public)
       % constructor
       function obj = FretTrace(figH,pos)
           import TirfAnalysis.GuiElements.FretTrace
           obj = obj@TirfAnalysis.GuiElements.TogglingTrace(...
               figH,pos,...
               FretTrace.LABELS_FRET,...
               FretTrace.COLORS_FRET,...
               FretTrace.Y_LABEL);
           
           obj.LimitY = obj.DFT_YLIM;
           % set the FRET timetrace limits
           set(obj.AxH,'YLim',obj.LimitY);
       end
       
       % could possibly add a method for setting a y-limit here...
       
    end
end