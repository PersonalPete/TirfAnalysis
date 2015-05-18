classdef IntensityTrace < TirfAnalysis.GuiElements.TogglingTrace
    properties (Access = protected)
        AutoH % autoscale toggle
    end
    
    
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
           
           % add the autoscale control
           autoPos = obj.LimPos;
           autoPos(2) = pos(2) + 3 * pos(4) / 4;
           autoPos(4) = pos(4) / 4;
           
           obj.AutoH = uicontrol('Parent',obj.FigH,...
                'style','togglebutton',...
                'Units','normalized',...
                'position',autoPos,...
                'fontunits','normalized',...
                'fontsize',obj.TXT_SIZE/2,...
                'string','AUTO',...
                'BackgroundColor',obj.DFT_BUT_COL,...
                'ForegroundColor',obj.DFT_BUT_TXT,...
                'Min',0,...
                'Max',1,...
                'Value',1,...
                'callback','');
           
       end
        
       % @Override TogglingTrace
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
            if obj.AUTOSCALE || get(obj.AutoH,'Value')
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
       
    end
    
    
    

end