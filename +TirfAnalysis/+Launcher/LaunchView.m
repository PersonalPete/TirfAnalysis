classdef LaunchView < handle
    properties (Access = protected)
        Controller
        
        FigH
        
        RegButton
        AnalysisButton
        ViewerButton        
    end
    
    properties (Access = protected, Constant)
        FIG_POS = [0.3 0.400 0.400 0.200]
        
        REG_POS = [0.05 0.3 0.25 0.4]
        ANA_POS = [0.375 0.3 0.25 0.4]
        VIW_POS = [0.70 0.3 0.25 0.4]
        
        DFT_COL_BGD = [0.2 0.2 0.2]
        DFT_BUT_COL = [0.24 0.35 0.67]
        DFT_BUT_TXT = [1 1 1]
        
        % uicontrol properties
        TXT_HEIGHT = 0.2
    end
    
    methods (Access = public)
        % constructor
        function obj = LaunchView(controller,callbacks)
            if nargin < 2
                controller = [];
                callbacks = {'','',''};
            end
            obj.Controller = controller;
            
            launchReg = callbacks{1};
            launchAnalysis = callbacks{2};
            launchViewer = callbacks{3};
            
            obj.FigH = figure('CloseRequestFcn',@(~,~) obj.delete,...
                'Color',obj.DFT_COL_BGD,...
                'Colormap',gray(1e2),...
                'DockControls','off',...
                'Name','Three Color TIRF Suite',...
                'Units','Normalized',...
                'OuterPosition',obj.FIG_POS,...
                'Defaultuicontrolunits','Normalized',...
                'Defaultuicontrolfontunits','Normalized',...
                'DefaultuicontrolFontSize',obj.TXT_HEIGHT,...
                'Toolbar','none',...
                'Menubar','none',...
                'WindowStyle','normal',...
                'Visible','on',...
                'DefaultAxesHandleVisibility','Callback');
            
            obj.RegButton = obj.buildButton(obj.REG_POS,...
                'Register Images',launchReg);
            obj.AnalysisButton = obj.buildButton(obj.ANA_POS,...
                'Analyse Movies',launchAnalysis);
            obj.ViewerButton = obj.buildButton(obj.VIW_POS,...
                'View Trajectories',launchViewer);
           
            set(obj.FigH,'HandleVisibility','Callback');
            
        end
        
        % for making sure we can see it
        function setVisible(obj)
            set(obj.FigH,'Position',obj.FIG_POS,...
                'Visible','on');
            uistack(obj.FigH,'top');
        end
        
        function delete(obj)
            if isvalid(obj.Controller)
                delete(obj.Controller);
            end
            if ishandle(obj.FigH)
                delete(obj.FigH)
            end
        end
        
    end
    
    methods (Access = protected)
        function buttonH = buildButton(obj,pos,string,callback)
            buttonH = uicontrol('Style','pushbutton',...
                'Callback',callback,...
                'Position',pos,...
                'BackgroundColor',obj.DFT_BUT_COL,...
                'ForegroundColor',obj.DFT_BUT_TXT,...
                'FontSize',obj.TXT_HEIGHT,...
                'String',string);
        end
    end
end