classdef (Abstract) TogglingTrace < handle
    % base class for timetraces
    properties (Access = protected)
        FigH
        AxH
        % below are arrays of handles to objects on the figure
        TogglesH % visibility toggles
        LinesH % lines on this axis
        LimH % structure with the limits handles
        
        HighlightLineH % line to highlight
        
        LimListener % listener for axis limits change
        
        ButPos
        LimPos
        NumTraces
        
        % ylimits to default to
        LimitY = [0 1]
    end
    
    properties (Access = protected, Constant)
        AX_TXT_COL = [0.0 0.0 0.0]
        TXT_SIZE = 0.4
        FRAC_BUT = 0.05 % the fraction of the area that is left for buttons
        FRAC_LIM = 0.05
        LINE_WIDTH = 1
        
        
        
        BUT_COL = [1.0 1.0 1.0]
        
        COL_EDT_BGD = [0.62 0.71 0.80]
        COL_EDT_TXT = [0.20 0.20 0.20]
        
        DFT_BUT_COL = [0.24 0.35 0.67]
        DFT_BUT_TXT = [1 1 1]
        
        LABELS_ALL = {'DD','DT','DA','TT','TA','AA'}
        COLORS_ALL = {...
            [0.0 0.9 0.0],...
            [0.9 0.7 0.0],...
            [0.0 0.4 0.0],...
            [0.9 0.0 0.0],...
            [0.4 0.0 0.0],...
            [0.8 0.8 0.5]}
        
        LABELS_FRET = {'DT','DA','TA'}
        COLORS_FRET = {...
            [0.9 0.7 0.0],...
            [0.0 0.4 0.0],...
            [0.4 0.0 0.0]}
        
        X_LABEL = 'Time (s)'
        
        HIGHLIGHT_COL = [1.0 0.1 0.1]
        HIGHLIGHT_WID = 2
    end
    properties (Abstract, Access = protected, Constant)
        AUTOSCALE
    end
    
    methods (Access = public)
        % constructor
        function obj = ...
                TogglingTrace(figH, pos, labels, colors, yString, xString)
            % colors and labels are cell arrays of colors and description
            % strings (e.g. 'DD')
            
            obj.FigH = figH;
            
            % work out the positions of stuff
            numBut = min([numel(labels),numel(colors)]);
            
            obj.NumTraces = numBut;
            
            butPos = pos;
            butPos(3) = pos(3)*obj.FRAC_BUT;
            butPos(1) = pos(1) + (1-obj.FRAC_BUT-obj.FRAC_LIM)*pos(3);
            butPos(4) = pos(4)/numBut;
            obj.ButPos = butPos;
            
            limPos = pos;
            limPos(3) = pos(3)*obj.FRAC_LIM;
            limPos(1) = pos(1) + (1-obj.FRAC_LIM)*pos(3);
            limPos(4) = pos(4)/6;
            obj.LimPos = limPos;
            
            axPos = pos;
            axPos(3) = (1-obj.FRAC_BUT-obj.FRAC_LIM)*pos(3);
            
            % build the axis
            obj.AxH = axes('parent',obj.FigH,...
                'Units','Normalized',...
                'Position',axPos,...
                'xcolor',obj.AX_TXT_COL,...
                'ycolor',obj.AX_TXT_COL,...
                'Box','on',...
                'HandleVisibility','callback');
            
            ylabel(obj.AxH,yString);
            
            if nargin < 6
                % get rid of the x labels
                set(obj.AxH,'XTickLabel','');
            else
                xlabel(obj.AxH,xString);
            end
            
            obj.LinesH = zeros(numBut,1);
            obj.TogglesH = zeros(numBut,1);
            
            % loop over the lines/buttons and build them
            for iBut = 1:numBut
                % build the line
                obj.LinesH(iBut) = ...
                    obj.buildLine(colors{iBut});
                % build the toggle button
                obj.TogglesH(iBut) = ...
                    obj.buildButton(iBut,labels{iBut},colors{iBut});
            end
            
            % y-limit control
            obj.LimH = obj.buildLimitControls;
            
            
            obj.HighlightLineH = obj.buildHighlight;    
            
            obj.LimListener = addlistener(obj.AxH,'YLim','PostSet',...
                @(~,~)obj.updateDispLim);

        end
        
        % takes in a cell array of nx2 doubles and updates the lines
        % DOES NOT UPDATE THE AXIS LIMITS TO MATCH IN THE X-DIRECTION
        function setData(obj,data)
            % data is a cell of nx2 doubles i.e. x,y data in rows
            % it is plotted on the axes in order
            xDataMax = 1;
            yDataMax = 1;
            for iLine = 1:numel(data)
                if isempty(data{iLine})
                    xData = [];
                    yData = [];
                else
                    xData = data{iLine}(:,2);
                    yData = data{iLine}(:,1);
                end
                set(obj.LinesH(iLine),'XData',xData,'YData',yData);
                if ~isempty(xData) && ~isempty(yData)
                    xDataMax = max(max(xData),xDataMax);
                    yDataMax = max(max(yData),yDataMax);
                end
            end
%             set(obj.AxH,'XLim',[0 xDataMax]);
            if obj.AUTOSCALE
                try
                    set(obj.AxH,'YLim',[0 yDataMax*1.1]);
                catch
                    % couldn't autoscale
                end
            else
               % set(obj.AxH,'YLim',obj.LimitY);
            end
            
            % hide the highlight on this new trace
            set(obj.HighlightLineH,'Visible','off');
            
        end
        
        function setXlim(obj,xlimits)
            set(obj.AxH,'xlim',xlimits);
        end
        
        
        % get the underlying axes object (so we can link it etc...)
        function unAx = getUnAx(obj)
            unAx = obj.AxH;
        end
        
        % set the highlight position
        function setHighlight(obj,timeX)
            set(obj.HighlightLineH,'XData',[timeX, timeX],'Visible','on');
        end
        
        function delete(obj)
            if ishandle(obj.AxH)
                delete(obj.AxH)
            end
            for iButton = 1:obj.NumTraces
                if ishandle(obj.TogglesH(iButton))
                    delete(obj.TogglesH(iButton));
                end
            end
        end
        
        
        
    end
    
    methods (Access = protected)
        function lineH = buildLine(obj,color)
            lineH = line('Parent',obj.AxH,...
                'LineStyle','-',...
                'Marker','none',...
                'LineWidth',obj.LINE_WIDTH,...
                'XData',[],...
                'YData',[],...
                'Visible','on',...
                'color',color);
        end
        
        % construct the highlight line
        function lineH = buildHighlight(obj)
            lineH = obj.buildLine(obj.HIGHLIGHT_COL);
            
            set(lineH,'XData',[0 0],'YData',get(obj.AxH,'YLim'));
            set(lineH,'LineWidth',obj.HIGHLIGHT_WID,'Visible','off');
            
        end
        
        function buttonH = buildButton(obj,idx,label,color)
            pos = obj.ButPos;
            pos(2) = pos(2) + (obj.NumTraces - idx) * pos(4);
            
            buttonH = uicontrol('Parent',obj.FigH,...
                'style','togglebutton',...
                'Units','normalized',...
                'position',pos,...
                'fontunits','normalized',...
                'fontsize',obj.TXT_SIZE,...
                'string',label,...
                'BackgroundColor',color,...
                'ForegroundColor',obj.BUT_COL,...
                'Min',0,...
                'Max',1,...
                'Value',1,...
                'callback',@(src,~)obj.toggleFcn(src,idx,color));
        end
        % function for toggling visibility of lines
        function toggleFcn(obj,src,idx,color)
            value = get(src,'Value');
            if value
                % we need visible on and the color set
                set(src,'BackgroundColor',color,...
                    'ForegroundColor',obj.BUT_COL);
                set(obj.LinesH(idx),'Visible','on');
            else
                % invert the button colors
                set(src,'BackgroundColor',obj.BUT_COL,...
                    'ForegroundColor',color);
                set(obj.LinesH(idx),'Visible','off');
            end
        end
        
        function controlH = buildLimitControls(obj)
            
            figCol = get(obj.FigH,'color');
            
            textPos = obj.LimPos;
            textPos(2) = textPos(2) + 2*textPos(4);
            
            upperPos = obj.LimPos;
            upperPos(2) = upperPos(2) + 1*upperPos(4);
            
            lowerPos = obj.LimPos;
            
            textH = uicontrol('Parent',obj.FigH,...
                'style','text',...
                'Units','normalized',...
                'position',textPos,...
                'fontunits','normalized',...
                'fontsize',obj.TXT_SIZE,...
                'string','Limits',...
                'BackgroundColor',figCol,...
                'ForegroundColor',obj.AX_TXT_COL,...
                'callback','');
            
            upperH = uicontrol('Parent',obj.FigH,...
                'style','edit',...
                'Units','normalized',...
                'position',upperPos,...
                'fontunits','normalized',...
                'fontsize',obj.TXT_SIZE,...
                'string','',...
                'BackgroundColor',obj.COL_EDT_BGD,...
                'ForegroundColor',obj.COL_EDT_TXT,...
                'callback',@(~,~)obj.updateTraceLim);
            
            lowerH = uicontrol('Parent',obj.FigH,...
                'style','edit',...
                'Units','normalized',...
                'position',lowerPos,...
                'fontunits','normalized',...
                'fontsize',obj.TXT_SIZE,...
                'string','',...
                'BackgroundColor',obj.COL_EDT_BGD,...
                'ForegroundColor',obj.COL_EDT_TXT,...
                'callback',@(~,~)obj.updateTraceLim);
            
            controlH.textH = textH;
            controlH.upperH = upperH;
            controlH.lowerH = lowerH;
        end
        
        % set the limits on the trace to match the user input
        function updateTraceLim(obj)
            % make sure the limits input are sensible
            upperLim = str2double(get(obj.LimH.upperH,'String'));
            lowerLim = str2double(get(obj.LimH.lowerH,'String'));
            
            if ~(isnan(upperLim) || isnan(lowerLim)) && upperLim > lowerLim
                yLimits = [lowerLim upperLim];
                set(obj.AxH,'YLim',yLimits);
            end
            
        end
        
        % function for the ylimit change listener
        function updateDispLim(obj)
            yLimits = get(obj.AxH,'ylim');
            
            yMin = min(yLimits);
            yMax = max(yLimits);
            
            % upper limit value
            set(obj.LimH.upperH,'String',sprintf('%.1f',yMax));
            % lower limit value
            set(obj.LimH.lowerH,'String',sprintf('%.1f',yMin));
            
            % highlight line
            set(obj.HighlightLineH,'YData',yLimits);
        end
        
    end
end
