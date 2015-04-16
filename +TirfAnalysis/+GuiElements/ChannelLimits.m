classdef ChannelLimits < handle
    % class which builds the channel limits setting buttons
    properties (Access = protected)
        StringX
        StringMinX
        StringMaxX
        
        StringY
        StringMinY
        StringMaxY
        
        EditMinX
        EditMaxX
        
        EditMinY
        EditMaxY
    end
    properties (Access = protected, Constant)
        COL_STR_BGD = [0.20 0.20 0.20]
        COL_STR_TXT = [1.00 1.00 1.00]
        
        COL_EDT_BGD = [0.62 0.71 0.80]
        COL_EDT_TXT = [0.20 0.20 0.20]
        
        TXT_HEIGHT = 0.5
    end
    methods (Access = public)
        function obj = ChannelLimits(figH,position)
            % work out the positions for the boxes
            posMinX = position(1);
            posMinY = position(2);
            posStepX = position(3)/5;
            posStepY = position(4)/2;
            posWidX = position(3)/6;
            posWidY = position(4)/3;
            
            posX = ...
                [posMinX posMinY+posStepY posWidX posWidY];
            posY = ...
                [posMinX posMinY posWidX posWidY];
            
            posStringMinX = ...
                [posMinX+posStepX posMinY+posStepY posWidX posWidY];
            posStringMaxX = ...
                [posMinX+3*posStepX posMinY+posStepY posWidX posWidY];
            posStringMinY = ...
                [posMinX+posStepX posMinY posWidX posWidY];
            posStringMaxY = ...
                [posMinX+3*posStepX posMinY posWidX posWidY];
            
            posEditMinX = ...
                [posMinX+2*posStepX posMinY+posStepY posWidX posWidY];
            posEditMaxX = ...
                [posMinX+4*posStepX posMinY+posStepY posWidX posWidY];
            posEditMinY = ...
                [posMinX+2*posStepX posMinY posWidX posWidY];
            posEditMaxY = ...
                [posMinX+4*posStepX posMinY posWidX posWidY];
            
            obj.StringX = obj.buildString(figH,'x',posX);
            obj.StringMinX = obj.buildString(figH,'min',posStringMinX);
            obj.StringMaxX = obj.buildString(figH,'max',posStringMaxX);
            
            obj.StringY = obj.buildString(figH,'y',posY);
            obj.StringMinY = obj.buildString(figH,'min',posStringMinY);
            obj.StringMaxY = obj.buildString(figH,'max',posStringMaxY);
            
            obj.EditMinX = obj.buildEdit(figH,posEditMinX);
            obj.EditMaxX = obj.buildEdit(figH,posEditMaxX);
            
            obj.EditMinY = obj.buildEdit(figH,posEditMinY);
            obj.EditMaxY = obj.buildEdit(figH,posEditMaxY);
            
        end
        function [xMin, xMax, yMin, yMax] = getMinMax(obj)
            xMin = max(0,round(str2double(get(obj.EditMinX,'String'))));
            xMax = max(0,round(str2double(get(obj.EditMaxX,'String'))));
            yMin = max(0,round(str2double(get(obj.EditMinY,'String'))));
            yMax = max(0,round(str2double(get(obj.EditMaxY,'String'))));
            
            % validation
            if xMin > xMax
                xTmp = xMax;
                xMax = xMin;
                xMin = xTmp;
            end
            if yMin > yMax
                yTmp = yMax;
                yMax = yMin;
                yMin = yTmp;
            end
            
            if xMin == xMax
                xMax = xMin + 1;
            end
            if yMin == yMax
                yMax = yMin +1;
            end
        end
        
        function setLims(obj,limits)
            set(obj.EditMinX,'String',sprintf('%i',limits(1)));
            set(obj.EditMaxX,'String',sprintf('%i',limits(2)));
            set(obj.EditMinY,'String',sprintf('%i',limits(3)));
            set(obj.EditMaxY,'String',sprintf('%i',limits(4)));
        end
        
        function limits = getLims(obj)
            limits(1) = str2double(get(obj.EditMinX,'String'));
            limits(2) = str2double(get(obj.EditMaxX,'String'));
            limits(3) = str2double(get(obj.EditMinY,'String'));
            limits(4) = str2double(get(obj.EditMaxY,'String'));
        end
        
        function setCallbacks(obj,callback)
            % sets the callback that executes after data validation
            function combinedCallback(obj,callback,src,evt)
                obj.validateInput(src);
                callback(src,evt);
            end
            set([obj.EditMinX, obj.EditMaxX, obj.EditMinY, obj.EditMaxY],...
                'Callback',...
                @(src,evt) combinedCallback(obj,callback,src,evt));
        end
    end
    methods (Access = protected)
        function stringBox = buildString(obj,figH,dispString,position)
            stringBox = uicontrol('Style','Text',...
                'Parent',figH,...
                'String',dispString,...
                'Units','Normalized',...
                'Position',position,...
                'BackgroundColor',obj.COL_STR_BGD,...
                'ForegroundColor',obj.COL_STR_TXT,...
                'FontUnits','Normalized',...
                'FontSize',obj.TXT_HEIGHT,...
                'Visible','on');
        end
        function editBox = buildEdit(obj,figH,position)
            editBox = uicontrol('Style','edit',...
                'Parent',figH,...
                'String','',...
                'Units','normalized',...
                'Position',position,...
                'BackgroundColor',obj.COL_EDT_BGD,...
                'ForegroundColor',obj.COL_EDT_TXT,...
                'FontUnits','Normalized',...
                'FontSize',obj.TXT_HEIGHT,...
                'Visible','on',...
                'Callback',@obj.validateInput);
        end
        function validateInput(~,src,~)
            % for making sure we enter an integer
            doubleVal = str2double(get(src,'String'));
            if isnan(doubleVal)
                set(src,'String','0');
            else
                intVal = round(doubleVal);
                intVal = max(intVal,1);
                set(src,'String',sprintf('%i',intVal));
            end
        end
    end % protected methods
end
