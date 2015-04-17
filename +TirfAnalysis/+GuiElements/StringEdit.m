classdef StringEdit < handle
    % StringEdit is an edit box with a description string alongside it
    % stringEdit = ...
    % TirfAnalysis.GuiElements.StringEdit(figH,pos,string,callback)
    %
    % stringEdit.getValue (returns value as a number)
    % stringEdit.getValueString
    % stringEdit.setValue(value) (where value is a number or a string)
    %
    properties (Access = protected)
        StringH
        EditH
    end
    % default properties for customising look/color
    properties (Constant, Access = protected)
        COL_STR_BGD = [0.20 0.20 0.20]
        COL_STR_TXT = [1.00 1.00 1.00]
        
        COL_EDT_BGD = [0.62 0.71 0.80]
        COL_EDT_TXT = [0.20 0.20 0.20]
        
        TXT_HEIGHT = 0.6
        INF_FRAC = 0.66 % 1/3 is edit box
        GAP_FRAC = 0.05 % 5 % gap between
    end
    
    methods
        % constructor
        function obj = StringEdit(figH,pos,infoString,callback)
            
            if nargin < 4
                callback = '';
            end
            
            fracInf = obj.INF_FRAC;
            fracGap = obj.GAP_FRAC;
            
            stringPos = ...
                [pos(1), pos(2),...
                pos(3)*(fracInf-fracGap), pos(4)];
            editPos = ...
                [pos(1)+ pos(3)*fracInf, pos(2) ,...
                (1-fracInf)*pos(3), pos(4)];
            
            %
            obj.StringH = uicontrol('parent',figH,...
                'Style','text',...
                'String',infoString,...
                'Units','Normalized',...
                'Position',stringPos,...
                'BackgroundColor',obj.COL_STR_BGD,...
                'ForegroundColor',obj.COL_STR_TXT,...
                'FontUnits','Normalized',...
                'FontSize',obj.TXT_HEIGHT,...
                'Visible','on',...
                'HorizontalAlignment','right');
            
            obj.EditH = uicontrol('Style','edit',...
                'Parent',figH,...
                'String','',...
                'Units','normalized',...
                'Position',editPos,...
                'BackgroundColor',obj.COL_EDT_BGD,...
                'ForegroundColor',obj.COL_EDT_TXT,...
                'FontUnits','Normalized',...
                'FontSize',obj.TXT_HEIGHT,...
                'Visible','on',...
                'Callback',callback);
        end
        
        % getters
        function value = getValue(obj)
            value = str2double(get(obj.EditH,'String'));
        end
        function string = getValueString(obj)
            string = get(obj.EditH,'String');
        end
        
        % setter
        function setValue(obj,value)
            if isnumeric(value) || islogical(value)
                set(obj.EditH,'String',num2str(value));
            else
                set(obj.EditH,'String',value);
            end
        end
    end
end