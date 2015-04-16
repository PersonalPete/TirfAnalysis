classdef ErrorHist < handle
    properties (Access = protected)
        RawData
        UnAx
        UnLine
    end
    properties (Access = protected, Constant)
        DFT_COL_LIN = [0.6 0.6 0.6]
        
        DFT_XMAX = 2
        DFT_COL_TXT = [1.0 1.0 1.0]
        DFT_COL_BGD = [0.2 0.2 0.2]
        DFT_BINS = 0.05:0.1:9.95
        DFT_LIN_WID = 2
    end
    methods (Access = public)
        function obj = ErrorHist(figH,position,lineCol)
            % constructor - NB position is the outerposition
            if nargin < 3
                lineCol = obj.DFT_COL_LIN;
            end
            
            obj.UnAx = axes('Parent',figH,...
                'Units','Normalized',...
                'OuterPosition',position,...
                'YColor',obj.DFT_COL_TXT,...
                'XColor',obj.DFT_COL_TXT,...
                'XLim',[0 obj.DFT_XMAX],...
                'Color',obj.DFT_COL_BGD);
            
            xlabel(obj.UnAx,'Position Error (px)');
            ylabel(obj.UnAx,'Number');
            
            obj.UnLine = line('Parent',obj.UnAx,...
                'XData',[],...
                'Ydata',[],...
                'Color',lineCol,...
                'LineStyle','-',...
                'Marker','none',...
                'LineWidth',obj.DFT_LIN_WID);
        end
        function setData(obj,data)
            % sets the histogram data and draws it
            obj.RawData = data;
            histData = hist(data,obj.DFT_BINS);
            
            [stX, stY] = stairs(obj.DFT_BINS,histData);
            stX = stX - 0.5*(obj.DFT_BINS(2) - obj.DFT_BINS(1));
            
            set(obj.UnLine,'XData',stX,'YData',stY);
            set(obj.UnAx,'YLim',[0 max(stY)*1.2]);
        end
        function unAx = getUnAx(obj)
            % gets the UNderlying AXes object
            unAx = obj.UnAx;
        end
    end
end
