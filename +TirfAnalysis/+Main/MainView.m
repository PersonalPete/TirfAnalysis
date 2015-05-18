classdef MainView < handle
    properties (Access = protected)
        FigH
        DispImH % handle to the object containing the image displays
        
        % edit box panels
        DetectionH
        LinkingH
        AlgorithmH
        
        % big buttons
        TformLoadH
        MovieLoadH
        DisplayH
        SetLoadH
        SetSaveH
        % Status indicator
        StatH
        
        % panel for running
        RunH
        
        Controller % Just so we can delete the controller when the fig close
        
    end
    
    properties (Access = protected, Constant)
        DFT_COL_BGD = [0.2 0.2 0.2]
        
        DFT_COL_GREEN = [0.0 0.8 0.0]
        DFT_COL_RED = [0.8 0.0 0.0]
        DFT_COL_NIR = [0.8 0.8 0.5]
        
        DFT_POS = [0.025 0.025 0.95 0.95]
        
        COL_STR_TXT = [0 0 0];
        
        TXT_HEIGHT = 0.4
        
        DFT_BUT_COL = [0.24 0.35 0.67]
        DFT_BUT_TXT = [1 1 1]
        
        DFT_COL_RDY  = [1.0 0.5 0.0]
        DFT_COL_CON  = [0.8 0.0 0.0]
        DFT_COL_DONE = [0.0 0.8 0.0]
        
        SIZ_STAT_TXT = 0.75;
        
        % positions of things within the figure
        
        POS_IM = [0.025 0.2375 0.950 0.75]
        
        POS_DET = [0.025 0.025 0.145 0.20]
        POS_LIN = [0.175 0.025 0.145 0.20]
        POS_ALG = [0.325 0.025 0.145 0.20]
        
        POS_LOAD_TFORM = [0.500 0.125 0.100 0.040]
        POS_LOAD_MOVIE = [0.600 0.125 0.100 0.040]
        POS_UPDA_DISPL = [0.500 0.025 0.200 0.040]
        
        POS_LOAD_SET = [0.500 0.075 0.100 0.040]
        POS_SAVE_SET = [0.600 0.075 0.100 0.040]
        
        POS_STAT = [0.500 0.185 0.200 0.040]
        
        RUN_PANEL_POS = [0.725 0.025 0.25 0.18]
    end
    
    methods (Access = public)
        % constructor
        function obj = MainView(controller,callbacks)
            
            obj.Controller = controller;
            
            % unwrap the callbacks
            loadTform = callbacks{1};
            loadMovie = callbacks{2};
            inputChanged = callbacks{3}; % i.e. some parameter has changed
            updateDisplay = callbacks{4};
            
            runModel = callbacks{5};
            
            loadSettings = callbacks{6};
            saveSettings = callbacks{7};
            
            checkStatus = callbacks{8};
            
            % make the main figure
            obj.FigH = figure('CloseRequestFcn',@(~,~) obj.delete,...
                'Color',obj.DFT_COL_BGD,...
                'Colormap',gray(1e2),...
                'DockControls','off',...
                'Name','Three Color TIRF Analysis',...
                'Units','Normalized',...
                'OuterPosition',obj.DFT_POS,...
                'Defaultuicontrolunits','Normalized',...
                'Defaultuicontrolfontunits','Normalized',...
                'DefaultuicontrolFontSize',obj.TXT_HEIGHT,...
                'Toolbar','none',...
                'Menubar','none',...
                'WindowStyle','normal',...
                'Visible','on',...
                'HandleVisibility','Callback',...
                'DefaultAxesHandleVisibility','Callback');
            
            % import the GUI Elements
            
            import TirfAnalysis.GuiElements.*
            
            % make the display for the images
            obj.DispImH = ...
                MultiChannelImageDisplay(...
                obj.FigH,...
                obj.POS_IM);
            
            obj.DetectionH = ...
                DetectionPanel(obj.FigH,obj.POS_DET,inputChanged);
            obj.LinkingH = ...
                LinkingPanel(obj.FigH,obj.POS_LIN,inputChanged);
            obj.AlgorithmH = ...
                AlgorithmPanel(obj.FigH,obj.POS_ALG,inputChanged);
            
            % make the buttons
            
            obj.TformLoadH = ...
                obj.buildButton(obj.POS_LOAD_TFORM,'Load Transform',...
                loadTform);
            obj.MovieLoadH = ...
                obj.buildButton(obj.POS_LOAD_MOVIE,'Load Movie',...
                loadMovie);
            obj.DisplayH = ...
                obj.buildButton(obj.POS_UPDA_DISPL,'Update Display',...
                updateDisplay);
            
            obj.SetLoadH = ...
                obj.buildButton(obj.POS_LOAD_SET,'Load Settings',...
                loadSettings);
            obj.SetSaveH = ...
                obj.buildButton(obj.POS_SAVE_SET,'Save Settings',...
                saveSettings);
            
            % make the status indicator
            
            obj.StatH = ...
                uicontrol('Parent',obj.FigH,...
                'Style','text',...
                'Position',obj.POS_STAT,...
                'FontSize',obj.SIZ_STAT_TXT,...
                'String','Ready',...
                'BackgroundColor',obj.DFT_COL_RDY,...
                'ForegroundColor',obj.COL_STR_TXT);
            
            % make the running panel
            obj.RunH = TirfAnalysis.GuiElements.RunInfo(obj.FigH,...
                obj.RUN_PANEL_POS,runModel,checkStatus);
            
            % set the handle visibility
            set(obj.FigH,...
                'HandleVisibility','callback');
            
        end
        
        % setter for analysis settings
        function updateStatus(obj,stat)
            if stat == 1
                set(obj.StatH,'BackgroundColor',obj.DFT_COL_DONE,...
                    'String','Done');
            elseif stat == -1 % configuration not complete
                set(obj.StatH,'BackgroundColor',obj.DFT_COL_CON,...
                    'String','Configure');
            elseif stat == -2 % busy
                set(obj.StatH,'BackgroundColor',obj.DFT_COL_CON,...
                    'String','Busy');
            else% i.e. stat == 0
                set(obj.StatH,'BackgroundColor',obj.DFT_COL_RDY,...
                    'String','Ready');
            end
            drawnow;
        end
        
        function setDisplaySettings(obj,analysisSettings)
            
            % detection settings
            nFrames = analysisSettings.getNFrames;
            kernel = analysisSettings.getSmoothKernel;
            radFac = analysisSettings.getBgdRadiusFac;
            
            peakThresh = analysisSettings.getPeakThresh;
            
            greThresh = peakThresh(1);
            redThresh = peakThresh(2);
            nirThresh = peakThresh(3);
            
            obj.DetectionH.setDetectionInfo(...
                nFrames,kernel,radFac,...
                greThresh,redThresh,nirThresh)
            
            % linking settings
            linkRad = analysisSettings.getLinkRadius;
            nearNeighRad = analysisSettings.getNearNeighLim;
            minEllip = analysisSettings.getFilteringEllip;
            
            linkWid = analysisSettings.getFilteringWid;
            
            linkFun = analysisSettings.getLinkBoolFun;
            
            minWid = min(linkWid);
            maxWid = max(linkWid);
            
            obj.LinkingH.setLinkingInfo(...
                linkRad, nearNeighRad, minEllip, minWid, maxWid, linkFun);
            
            
            
            % algorithm settings
            isFixPos = analysisSettings.isFixedPos;
            isFixWid = analysisSettings.isFixedWid;
            isEllip = analysisSettings.isEllipse;
            maxPosChange = analysisSettings.getPosLim;
            
            fitWid = analysisSettings.getWidLim;
            
            minFitWid = min(fitWid);
            maxFitWid = max(fitWid);
            
            windowRad = analysisSettings.getWindowRad;
            
            obj.AlgorithmH.setAlgorithmInfo(...
                isFixPos, isFixWid, isEllip,...
                maxPosChange, minFitWid, maxFitWid,windowRad);
                       
        end
        
        function [nFrames,kernel,radFac,greThresh,redThresh,nirThresh,...
                linkRad,nearNeighRad,minEllip,minWid,maxWid,linkFun,...
                isFixPos,isFixWid,isEllip,maxPosChange,minFitWid,...
                maxFitWid,windowRad] = ...
                getDisplaySettings(obj)
            
            [nFrames,kernel,radFac,greThresh,redThresh,nirThresh] = ...
                obj.DetectionH.getDetectionInfo;
            
            [linkRad, nearNeighRad, minEllip, minWid, maxWid, linkFun]...
                = obj.LinkingH.getLinkingInfo;
            
            [isFixPos, isFixWid, isEllip,...
                maxPosChange, minFitWid, maxFitWid,windowRad]...
                = obj.AlgorithmH.getAlgorithmInfo;
        end
        
        % setter for image data
        function setDisplayImage(obj,analysisMovie)
            obj.DispImH.updateDisplay(analysisMovie)
        end
        
        function setRunningStatus(obj,nPend,nRun,nFin,nFail)
            obj.RunH.setDisplay(nPend,nRun,nFin,nFail);
        end
        
        function delete(obj)
            delete(obj.FigH);
            if isvalid(obj.Controller)
                delete(obj.Controller);
            end
        end
    end
    
    methods (Access = protected)
        % convenience function
        function butH = buildButton(obj,pos,string,callback)
            butH = uicontrol('Parent',obj.FigH,...
                'Style','pushbutton',...
                'Units','Normalized',...
                'BackgroundColor',obj.DFT_BUT_COL,...
                'ForegroundColor',obj.DFT_BUT_TXT,...
                'Position',pos,...
                'String',string,...
                'callback',callback);
        end
    end
end
    