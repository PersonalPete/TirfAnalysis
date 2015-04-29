classdef IntensityTrace < TirfAnalysis.GuiElements.TogglingTrace
    properties (Access = protected, Constant)
        AUTOSCALE = 0        
        Y_LABEL = 'Intensity'
        DFT_YLIM = [0 1000]
    end
    methods (Access = public)
       % constructor
       function obj = IntensityTrace(figH,pos)
           import TirfAnalysis.GuiElements.IntensityTrace
           obj = obj@TirfAnalysis.GuiElements.TogglingTrace(...
               figH,pos,...
               IntensityTrace.LABELS_ALL,...
               IntensityTrace.COLORS_ALL,...
               IntensityTrace.Y_LABEL);
           
           obj.LimitY = obj.DFT_YLIM;
           % set the FRET timetrace limits
           set(obj.AxH,'YLim',obj.LimitY);
       end
    end
end