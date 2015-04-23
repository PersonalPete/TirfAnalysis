classdef (Abstract) TogglingTrace < handle
    % base class for timetraces
    properties (Access = protected)
        FigH
        AxH
        % below are arrays of handles to objects on the figure
        TogglesH % visibility toggles
        LinesH % lines on this axis
        
        ButPos
        NumTraces
        
        % only used if AUTOSCALE = true
        LimitY = [0 1]
    end
    
    properties (Access = protected, Constant)
        AX_TXT_COL = [0.0 0.0 0.0]
        TXT_SIZE = 0.6
        FRAC_BUT = 0.05 % the fraction of the area that is left for buttons
        LINE_WIDTH = 2

        BUT_COL = [1.0 1.0 1.0]
        
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
            butPos(1) = pos(1) + (1-obj.FRAC_BUT)*pos(3); 
            butPos(4) = pos(4)/numBut;
            obj.ButPos = butPos;
            
            axPos = pos;
            axPos(3) = (1-obj.FRAC_BUT)*pos(3);
            
            % build the axis
            obj.AxH = axes('parent',obj.FigH,...
                'Units','Normalized',...
                'Position',axPos,...
                'xcolor',obj.AX_TXT_COL,...
                'ycolor',obj.AX_TXT_COL,...
                'Box','on');
            
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
        end
        
        function setData(obj,data)
            % data is a cell of nx2 doubles i.e. x,y data in rows
            % it is plotted on the axes in order
            xDataMax = 1;
            yDataMax = 1;
            for iLine = 1:numel(data)
                xData = data{iLine}(:,1);
                yData = data{iLine}(:,2);
                set(obj.LinesH(iLine),'XData',xData,'YData',yData);
                xDataMax = max(max(xData),xDataMax);
                yDataMax = max(max(yData),yDataMax);
            end
            set(obj.AxH,'XLim',[0 xDataMax]);
            if obj.AUTOSCALE
                set(obj.AxH,'YLim',[0 yDataMax]);
            else
                set(obj.AxH,'YLim',obj.LimitY);
            end
        end
        
        % get the underlying axes object (so we can link it etc...)
        function unAx = getUnAx(obj)
            unAx = obj.AxH;
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
                'BackgroundColor',obj.BUT_COL,...
                'ForegroundColor',color,...
                'Min',0,...
                'Max',1,...
                'Value',1,...
                'callback',@(src,~)obj.toggleFcn(src,idx,color));
        end
        % function for toggling visibility of lines
        function toggleFcn(obj,src,idx,color)
            value = get(src,'Value');
            if value
                % we need visible on
                set(src,'BackgroundColor',obj.BUT_COL,...
                    'ForegroundColor',color);
                set(obj.LinesH(idx),'Visible','on');
            else
                % invert the button colors
                set(src,'BackgroundColor',color,...
                    'ForegroundColor',obj.BUT_COL);
                set(obj.LinesH(idx),'Visible','off');
            end
        end
    end
end
      