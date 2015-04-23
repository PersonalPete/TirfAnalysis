classdef IntensityTrace < TirfAnalysis.GuiElements.TogglingTrace
    properties (Access = protected, Constant)
        AUTOSCALE = 1        
        Y_LABEL = 'Intensity'
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
       end
    end
end