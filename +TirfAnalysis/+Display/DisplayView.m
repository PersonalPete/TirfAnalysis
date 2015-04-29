classdef DisplayView < handle
    properties (Access = protected)
        FigH
        
        TraceH
        ImagesH
        
        HighlightListener
    end
    
    properties (Access = protected, Constant)
        FIG_POS = [0.05 0.05 0.9 0.9]
        
        TRACE_POS = [0.050 0.050 0.8 0.8]
        IMAGES_POS = [0.875 0.050 0.075 0.8]
        
        DFT_COL_BGD = [0.6 0.6 0.6]
        
                
        TXT_HEIGHT = 0.4
    end
    
    methods (Access = public)
        % constructor
        function obj = DisplayView(callbacks)
            obj.FigH = figure('CloseRequestFcn',@(~,~) obj.delete,...
                'Color',obj.DFT_COL_BGD,...
                'Colormap',gray(1e2),...
                'DockControls','off',...
                'Name','Three Color TIRF Analysis',...
                'Units','Normalized',...
                'OuterPosition',obj.FIG_POS,...
                'Defaultuicontrolunits','Normalized',...
                'Defaultuicontrolfontunits','Normalized',...
                'DefaultuicontrolFontSize',obj.TXT_HEIGHT,...
                'Toolbar','none',...
                'Menubar','none',...
                'WindowStyle','normal',...
                'Visible','on');
            
            obj.TraceH = TirfAnalysis.GuiElements.MultiTrace(obj.FigH,...
                obj.TRACE_POS);
            
            obj.ImagesH = TirfAnalysis.GuiElements.ParticleFrameDisplay(...
                obj.FigH,obj.IMAGES_POS);
            
            obj.HighlightListener = addlistener(obj.ImagesH,...
                'DisplayFrameChanged',@(~,~)obj.updateHighlight);
        end
        
        function displayParticle(obj,particle)
            obj.TraceH.setData(particle);
            obj.ImagesH.setData(particle);
        end
        
        function delete(obj)
            if ishandle(obj.TraceH)
                delete(obj.TraceH)
            end
            if ishandle(obj.ImagesH)
                delete(obj.ImagesH)
            end
            if ishandle(obj.FigH)
                delete(obj.FigH)
            end
            if ishandle(obj.HighlightListener)
                delete(obj.HighlightListener);
            end
        end
    end
    methods (Access = protected)
        % callback for the highlight monitoring listener
        function updateHighlight(obj)
            % get the current frame time displayed and show it
            obj.TraceH.setHighlight(obj.ImagesH.getDisplayFrameTime);
        end
    end
end
        