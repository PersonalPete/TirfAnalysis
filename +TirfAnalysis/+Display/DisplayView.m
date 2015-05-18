classdef DisplayView < handle
    properties (Access = protected)
        FigH
        
        Controller
        
        TraceH
        ImagesH
        
        HighlightListener
        
        % buttons for navigating the data
        NextButton
        BackButton
        
        % display for the current particle
        ParticleDisplay
        
        % buttons for loading data sets and saving them
        LoadButton
        SaveButton
        
        InfoDisplay
        
        ZoomButton
        
        ExportButton
        
    end
    
    properties (Access = protected, Constant)
        % positions
        FIG_POS = [0.05 0.05 0.9 0.9]
        
        TRACE_POS = [0.050 0.050 0.8 0.85]
        IMAGES_POS = [0.875 0.050 0.075 0.85]
        
        POS_NEXT = [0.85 0.925 0.10 0.05]
        POS_BACK = [0.70 0.925 0.10 0.05]
        
        POS_PART = [0.80 0.925 0.05 0.05]
        
        POS_LOAD = [0.05 0.925 0.10 0.05]
        POS_SAVE = [0.15 0.925 0.10 0.05]
        
        POS_INFO = [0.25 0.925 0.325 0.035]
        
        POS_ZOOM = [0.6375 0.925 0.050 0.05]
        
        POS_EXPO = [0.575  0.925 0.050 0.05]
        
        % Uicontol colors
        COL_STR_BGD = [0.20 0.20 0.20]
        COL_STR_TXT = [1.00 1.00 1.00]
        
        COL_EDT_BGD = [0.62 0.71 0.80]
        COL_EDT_TXT = [0.20 0.20 0.20]
        
        DFT_COL_BGD = [0.6 0.6 0.6]
        DFT_BUT_COL = [0.24 0.35 0.67]
        DFT_BUT_TXT = [1 1 1]
        
        % uicontrol properties
        TXT_HEIGHT = 0.4
    end
    
    methods (Access = public)
        % constructor
        function obj = DisplayView(controller,callbacks)
            
            if nargin < 1
                controller = [];
            end
            
            obj.Controller = controller;
            
            if nargin < 2
                callbacks = {'','','','',''};
            end
            
            % unwrap the callbacks
            nextParticle = callbacks{1};
            backParticle = callbacks{2};
            
            specificParticle = callbacks{3}; % takes one argument - partNo
            
            loadAnalysis = callbacks{4};
            saveAnalysis = callbacks{5};
            
            obj.FigH = figure('CloseRequestFcn',@(~,~) obj.delete,...
                'Color',obj.DFT_COL_BGD,...
                'Colormap',gray(1e2),...
                'DockControls','off',...
                'Name','Three Color TIRF Trajectory Viewer',...
                'Units','Normalized',...
                'OuterPosition',obj.FIG_POS,...
                'Defaultuicontrolunits','Normalized',...
                'Defaultuicontrolfontunits','Normalized',...
                'DefaultuicontrolFontSize',obj.TXT_HEIGHT,...
                'Toolbar','none',...
                'Menubar','none',...
                'WindowStyle','normal',...
                'Visible','on',...
                'HandleVisibility','Callback',...
                'DefaultAxesHandleVisibility','Callback');
            
            % build the traces display
            obj.TraceH = TirfAnalysis.GuiElements.MultiTrace(obj.FigH,...
                obj.TRACE_POS);
            
            % build the images display
            obj.ImagesH = TirfAnalysis.GuiElements.ParticleFrameDisplay(...
                obj.FigH,obj.IMAGES_POS);
            
            % build the listener than ensures that the highlight on the
            % timetrace follows the displayed frame
            obj.HighlightListener = addlistener(obj.ImagesH,...
                'DisplayFrameChanged',@(~,~)obj.updateHighlight);
            
            % build the buttons for navigating and loading/saving
            obj.NextButton = ...
                obj.buildButton(obj.POS_NEXT,'Next',nextParticle);
            obj.BackButton = ...
                obj.buildButton(obj.POS_BACK,'Back',backParticle);
            
            obj.ParticleDisplay = ...
                obj.buildEdit(obj.POS_PART,specificParticle);
            
            obj.LoadButton = ...
                obj.buildButton(obj.POS_LOAD,'Load',loadAnalysis);
            obj.SaveButton = ...
                obj.buildButton(obj.POS_SAVE,'Save',saveAnalysis);
            
            % The display for the current movie info
            obj.InfoDisplay = ...
                obj.buildDisplay(obj.POS_INFO);
            
            % the zoom toggle button
            obj.ZoomButton = obj.buildToggle(obj.POS_ZOOM,'Zoom',...
                @(src,~) obj.zoomToggle(src));
            
            obj.ExportButton = ...
                TirfAnalysis.GuiElements.ImageExportButton(...
                obj.FigH,obj.POS_EXPO);
        end
        
        function displayParticle(obj,particle)
            obj.TraceH.setData(particle);
            obj.ImagesH.setData(particle);
        end
        
        function displayInfo(obj,infoString)
            set(obj.InfoDisplay,'String',infoString);
        end
        
        function displayParticleNumber(obj,particleNumber)
            set(obj.ParticleDisplay,'string',sprintf('%i',particleNumber));
        end
        
        function delete(obj)
            if isvalid(obj.TraceH)
                delete(obj.TraceH)
            end
            if isvalid(obj.ImagesH)
                delete(obj.ImagesH)
            end
            if ishandle(obj.FigH)
                delete(obj.FigH)
            end
            if ishandle(obj.HighlightListener)
                delete(obj.HighlightListener);
            end
            if isvalid(obj.Controller)
                delete(obj.Controller)
            end
        end
    end
    methods (Access = protected)
        % callback for the highlight monitoring listener
        function updateHighlight(obj)
            % get the current frame time displayed and show it
            obj.TraceH.setHighlight(obj.ImagesH.getDisplayFrameTime);
        end
        
        function buttonH = buildButton(obj,pos,string,callback)
            buttonH = uicontrol('parent',obj.FigH,...
                'Style','pushbutton',...
                'Callback',callback,...
                'Position',pos,...
                'BackgroundColor',obj.DFT_BUT_COL,...
                'ForegroundColor',obj.DFT_BUT_TXT,...
                'FontSize',obj.TXT_HEIGHT,...
                'String',string);
        end
        
        function editH = buildEdit(obj,pos,callback)
            editH = uicontrol('parent',obj.FigH,...
                'Style','Edit',...
                'Callback',...
                @(src,~) obj.setParticleFromUserInput(src,callback),...
                'Position',pos,...
                'BackgroundColor',obj.COL_EDT_BGD,...
                'ForegroundColor',obj.COL_EDT_TXT,...
                'FontSize',obj.TXT_HEIGHT,...
                'String','');
        end
        
        function setParticleFromUserInput(~,src,callback)
            inputString = get(src,'String');
            inputNum = str2double(inputString);
            % check it is valid
            if ~isempty(inputNum) && ~isnan(inputNum)
                inputNum = round(inputNum); % only integer particle numbers
                % call the callback for telling the model to go to a
                % particular particle
                callback(inputNum);
            end
        end
        
        function displayH = buildDisplay(obj,pos)
            displayH = uicontrol('Style','Text',...
                'Position',pos,...
                'BackgroundColor',obj.DFT_COL_BGD,...
                'ForegroundColor',obj.DFT_BUT_TXT,...
                'FontSize',obj.TXT_HEIGHT,...
                'String','');
        end
        
        function toggleH = buildToggle(obj,pos,string,callback)
            toggleH = uicontrol('Style','toggle',...
                'Callback',callback,...
                'Position',pos,...
                'BackgroundColor',obj.DFT_BUT_COL,...
                'ForegroundColor',obj.DFT_BUT_TXT,...
                'FontSize',obj.TXT_HEIGHT,...
                'String',string,...
                'Min',0,...
                'Max',1);
        end
        
        function zoomToggle(obj,src)
            value = get(src,'Value');
            if value
                zoom(obj.FigH,'xon');
            else
                zoom(obj.FigH,'off');
                % rest the view to full trace
                obj.TraceH.resetView();
            end
        end
    end
end
        