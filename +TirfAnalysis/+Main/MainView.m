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
        
        % button that tells the model to run
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
        
        % positions of things within the figure
        
        POS_IM = [0.025 0.25 0.950 0.725]
        
        POS_DET = [0.025 0.025 0.145 0.20]
        POS_LIN = [0.175 0.025 0.145 0.20]
        POS_ALG = [0.325 0.025 0.145 0.20]
        
        POS_LOAD_TFORM = [0.500 0.160 0.125 0.040]
        POS_LOAD_MOVIE = [0.500 0.100 0.125 0.040]
        POS_UPDA_DISPL = [0.500 0.040 0.125 0.040]
        
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
            
            % make the main figure
            obj.FigH = figure('CloseRequestFcn',@(~,~) obj.delete,...
                'Color',obj.DFT_COL_BGD,...
                'Colormap',gray(1e2),...
                'DockControls','off',...
                'Name','Image Registration',...
                'Units','Normalized',...
                'OuterPosition',obj.DFT_POS,...
                'Defaultuicontrolunits','Normalized',...
                'Defaultuicontrolfontunits','Normalized',...
                'DefaultuicontrolFontSize',obj.TXT_HEIGHT,...
                'Toolbar','none',...
                'Menubar','none',...
                'WindowStyle','normal',...
                'Visible','on');
            
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
            
        end
        
        % setter for analysis settings
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
            
            
            obj.AlgorithmH.setAlgorithmInfo(...
                isFixPos, isFixWid, isEllip,...
                maxPosChange, minFitWid, maxFitWid);
            
        end
        
        function [nFrames,kernel,radFac,greThresh,redThresh,nirThresh,...
                linkRad,nearNeighRad,minEllip,minWid,maxWid,linkFun,...
                isFixPos,isFixWid,isEllip,maxPosChange,minFitWid,...
                maxFitWid] = ...
                getDisplaySettings(obj)
            
            [nFrames,kernel,radFac,greThresh,redThresh,nirThresh] = ...
                obj.DetectionH.getDetectionInfo;
            
            [linkRad, nearNeighRad, minEllip, minWid, maxWid, linkFun]...
                = obj.LinkingH.getLinkingInfo;
            
            [isFixPos, isFixWid, isEllip,...
                maxPosChange, minFitWid, maxFitWid]...
                = obj.AlgorithmH.getAlgorithmInfo;
        end
        
        % setter for image data
        function setDisplayImage(obj,analysisMovie)
            obj.DispImH.updateDisplay(analysisMovie)
        end
        
        function delete(obj)
            delete(obj.FigH);
            delete(obj.Controller);
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
    