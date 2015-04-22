classdef (Abstract) AbstractPanel < handle
    properties (Access = protected)
        FigH
        
        XMin
        XWid
        YMin
        
        Height
        Space
    end
    
    properties (Constant, Access = protected)
        DFT_COL_BGD = [1.0 1.0 1.0]
        DFT_COL_TXT = [0.2 0.2 0.2]
        TXT_HEIGHT = 0.8
        
        DFT_SPACE_FAC = 1
        
        N_ROW = 7
        
    end
    
    methods (Access = public)
        % constructor
        function obj = AbstractPanel(figH,position)
            
            obj.FigH = figH;
            
            obj.Height = position(4)/(obj.N_ROW + obj.DFT_SPACE_FAC);
            obj.Space = obj.Height + ...
                (obj.DFT_SPACE_FAC * obj.Height / (obj.N_ROW - 1));
            
            obj.XMin = position(1);
            obj.XWid = position(3);
            obj.YMin = position(2);
        end
    end
    
    methods (Access = protected)
        
        function titleHandle = addTitle(obj,titleString)
            titleHandle = uicontrol('parent',obj.FigH,...
                'Units','Normalized',...
                'FontUnits','Normalized',...
                'position',[...
                obj.XMin,...
                obj.YMin + (obj.N_ROW - 1) * obj.Space,...
                obj.XWid,...
                obj.Height],...
                'Style','text',...
                'FontSize',obj.TXT_HEIGHT,...
                'String',titleString,...
                'ForegroundColor',obj.DFT_COL_TXT,...
                'BackgroundColor',obj.DFT_COL_BGD);
        end
        
        function stringEdit = addOption(obj,posNo,description,callback)
            
            % posNo specifies where to place the option in the list -
            % i.e. 1 is top, 2 is below it...
            
            stringEdit = TirfAnalysis.GuiElements.StringEdit(...
                obj.FigH,...
                [...
                obj.XMin,...
                obj.YMin + (obj.N_ROW - 1 - posNo) * obj.Space,...
                obj.XWid,...
                obj.Height],...
                description,...
                callback);
        end
    end
end
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            