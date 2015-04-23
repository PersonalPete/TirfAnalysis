classdef RegView < handle
    properties (SetAccess = protected)
        
        Controller % handle to the controller
        
        FigH
        NirImH
        RedImH
        GreenImH
        
        RedRedPointsH
        GreenRedPointsH
        NirRedPointsH
        
        NirLimH
        RedLimH
        GreenLimH
        
        GreenErrorH
        NirErrorH
        
        GreenId
        RedId
        NirId
        
        LoadH
        RunH
        SaveH
        StatH
    end
    properties (Access = protected, Constant)
        DFT_COL_BGD = [0.2 0.2 0.2]
        
        DFT_COL_GREEN = [0.0 0.8 0.0]
        DFT_COL_RED = [0.8 0.0 0.0]
        DFT_COL_NIR = [0.8 0.8 0.5]
        
        DFT_POS = [0.05 0.1 0.9 0.8]
        
        COL_STR_TXT = [0 0 0];
        TXT_HEIGHT = 0.7;
        
        DFT_BUT_COL = [0.24 0.35 0.67]
        DFT_BUT_TXT = [1 1 1]
        
        DFT_COL_RDY  = [1.0 0.5 0.0]
        DFT_COL_CON  = [0.8 0.0 0.0]
        DFT_COL_DONE = [0.0 0.8 0.0]
        
        MARK_SIZ = 10
    end
    methods (Access = public)
        % constructor for the gui
        function obj = RegView(controller,callbacks)
            % unwrap the callbacks
            loadBack = callbacks{1};
            limitsBack = callbacks{2};
            computeBack = callbacks{3};
            saveBack = callbacks{4};
            % and the controller
            obj.Controller = controller;
            
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
            
            % what are the widths
            fixWid = 0.20;
            fixSpa = 0.04;
            xNir = fixSpa;
            xRed = 2*fixSpa + fixWid;
            xGre = 3*fixSpa + 2*fixWid;
            xHis = 4*fixSpa + 3*fixWid;
            
            imStartHei = 0.20;
            imHei = 0.70;
            
            limStartHei = 0.025;
            limHei = 0.10;
            
            histHei = 0.3;
            histStartHei = imHei - histHei + imStartHei;
            
            idStartHei = 0.125;
            idHei = 0.05;
            
            % image displays
            import  TirfAnalysis.GuiElements.ImageDisplay
            obj.NirImH = ...
                ImageDisplay(obj.FigH,[xNir imStartHei fixWid imHei]);
            obj.RedImH = ...
                ImageDisplay(obj.FigH,[xRed imStartHei fixWid imHei]);
            obj.GreenImH = ...
                ImageDisplay(obj.FigH,[xGre imStartHei fixWid imHei]);
            
            % image limits
            import TirfAnalysis.GuiElements.ChannelLimits
            obj.NirLimH = ...
                ChannelLimits(obj.FigH,[xNir limStartHei fixWid limHei]);
            obj.RedLimH= ...
                ChannelLimits(obj.FigH,[xRed limStartHei fixWid limHei]);
            obj.GreenLimH = ...
                ChannelLimits(obj.FigH,[xGre limStartHei fixWid limHei]);
            
            % set the callbacks
            obj.NirLimH.setCallbacks(limitsBack);
            obj.RedLimH.setCallbacks(limitsBack);
            obj.GreenLimH.setCallbacks(limitsBack);
            
            % display for the localisations
            redAx = obj.RedImH.getUnAx;
            obj.RedRedPointsH = line('Parent',redAx,...
                'LineStyle','none',...
                'MarkerEdgeColor',obj.DFT_COL_RED,...
                'Marker','o',...
                'XData',[],...
                'YData',[],...
                'HitTest','off',...
                'MarkerSize',obj.MARK_SIZ);
            
            obj.GreenRedPointsH = line('Parent',redAx,...
                'LineStyle','none',...
                'MarkerEdgeColor',obj.DFT_COL_GREEN,...
                'Marker','+',...
                'XData',[],...
                'YData',[],...
                'HitTest','off',...
                'MarkerSize',obj.MARK_SIZ);
            
            obj.NirRedPointsH = line('Parent',redAx,...
                'LineStyle','none',...
                'MarkerEdgeColor',obj.DFT_COL_NIR,...
                'Marker','x',...
                'XData',[],...
                'YData',[],...
                'HitTest','off',...
                'MarkerSize',obj.MARK_SIZ);
            
            % histograms
            import TirfAnalysis.GuiElements.ErrorHist
            
            obj.GreenErrorH = ...
                ErrorHist(obj.FigH,...
                [xHis histStartHei fixWid histHei],...
                obj.DFT_COL_GREEN);
            obj.NirErrorH = ...
                ErrorHist(obj.FigH,...
                [xHis imStartHei fixWid histHei],...
                obj.DFT_COL_NIR);
            
            % other displays
            
            % identifiers for channels
            obj.NirId = uicontrol('Style','Text',...
                'Parent',obj.FigH,...
                'String','730',...
                'Units','Normalized',...
                'Position',[xNir idStartHei fixWid idHei],...
                'BackgroundColor',obj.DFT_COL_NIR,...
                'ForegroundColor',obj.COL_STR_TXT,...
                'FontUnits','Normalized',...
                'FontSize',obj.TXT_HEIGHT,...
                'Visible','on');
            obj.RedId = uicontrol('Style','Text',...
                'Parent',obj.FigH,...
                'String','640',...
                'Units','Normalized',...
                'Position',[xRed idStartHei fixWid idHei],...
                'BackgroundColor',obj.DFT_COL_RED,...
                'ForegroundColor',obj.COL_STR_TXT,...
                'FontUnits','Normalized',...
                'FontSize',obj.TXT_HEIGHT,...
                'Visible','on');
            
            obj.GreenId = uicontrol('Style','Text',...
                'Parent',obj.FigH,...
                'String','532',...
                'Units','Normalized',...
                'Position',[xGre idStartHei fixWid idHei],...
                'BackgroundColor',obj.DFT_COL_GREEN,...
                'ForegroundColor',obj.COL_STR_TXT,...
                'FontUnits','Normalized',...
                'FontSize',obj.TXT_HEIGHT,...
                'Visible','on');
            
            obj.LoadH = uicontrol('Style','pushbutton',...
                'Callback',loadBack,...
                'Position',[xNir 0.925 fixWid 0.05],...
                'BackgroundColor',obj.DFT_BUT_COL,...
                'ForegroundColor',obj.DFT_BUT_TXT,...
                'FontSize',obj.TXT_HEIGHT/2,...
                'String','Load Movie');
            
            obj.SaveH = uicontrol('Style','pushbutton',...
                'Callback',saveBack,...
                'Position',[xHis 0.925 fixWid 0.05],...
                'BackgroundColor',obj.DFT_BUT_COL,...
                'ForegroundColor',obj.DFT_BUT_TXT,...
                'FontSize',obj.TXT_HEIGHT/2,...
                'String','Save Transform');
            
            obj.RunH = uicontrol('Style','pushbutton',...
                'Callback',computeBack,...
                'Position',[xHis limStartHei fixWid limHei*0.75],...
                'BackgroundColor',obj.DFT_BUT_COL,...
                'ForegroundColor',obj.DFT_BUT_TXT,...
                'FontSize',obj.TXT_HEIGHT/3,...
                'String','Build Transform');
            
            obj.StatH = uicontrol('Style','Text',...
                'Parent',obj.FigH,...
                'String','Configure',...
                'Units','Normalized',...
                'Position',[xHis idStartHei fixWid idHei],...
                'BackgroundColor',obj.DFT_COL_CON,...
                'ForegroundColor',obj.COL_STR_TXT,...
                'FontUnits','Normalized',...
                'FontSize',obj.TXT_HEIGHT,...
                'Visible','on');
            
            % set the main figure handle visibility
            set(obj.FigH,...
                'HandleVisibility','callback');
            
        end
        
        function delete(obj)
            obj.Controller.delete;
            delete(obj.FigH);
        end
        
        function updateIm(obj,greenF, redF, nirF, greenLim, redLim, nirLim)
            % set the displayed frame data
            obj.NirImH.setImData(nirF);
            obj.RedImH.setImData(redF);
            obj.GreenImH.setImData(greenF);
            % set the channel limits on display
            obj.NirLimH.setLims(nirLim)
            obj.RedLimH.setLims(redLim)
            obj.GreenLimH.setLims(greenLim)           
        end
        
        function [greenLim, redLim, nirLim] = getImLim(obj)
            greenLim = obj.GreenLimH.getLims;
            redLim = obj.RedLimH.getLims;
            nirLim = obj.NirLimH.getLims;
        end
        
        function updateTformHists(obj,tform, positionsInRed)
            % update the histogram displays
            obj.GreenErrorH.setData(tform.getGreenDist);
            obj.NirErrorH.setData(tform.getNirDist);
            
            % update the points used for TFORM
            greenPos = positionsInRed{1};
            redPos = positionsInRed{2};
            nirPos = positionsInRed{3};
            
            set(obj.RedRedPointsH,'XData',redPos(:,1),'YData',redPos(:,2));
            set(obj.GreenRedPointsH,'XData',greenPos(:,1),'YData',greenPos(:,2));
            set(obj.NirRedPointsH,'XData',nirPos(:,1),'YData',nirPos(:,2));        
        end
        
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
        end
        
    end
end