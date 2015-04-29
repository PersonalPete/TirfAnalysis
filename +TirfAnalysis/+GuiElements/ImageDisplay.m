classdef ImageDisplay < handle
    % ImageDisplay is a wrapper for an axes object which is designed for
    % displaying a TIRF microscope image
    % methods
    % obj = ImageDisplay(figH, position)
    % setImData(obj,imData)
    % setColorLim(obj,cMin,cMax)
    %
    properties (Access = protected)
        % 'Un' is UNderlying
        UnFig
        UnAxes
        UnImage
        
        MaxX = 1
        MaxY = 1
        
        CMin = 0 % is the pixel value of the darkest pixel
        CMax = 1 % is the pixel value of the lightest pixel
    end
    properties (Constant, Access = protected)
        C_SCALE = 0.5
        C_DELTA_MIN = 20 % minimum color range
    end
    methods (Access = public)
        function obj = ImageDisplay(figH, position)
            % no arg syntax first
            if nargin == 0 || isempty(figH)
                obj.UnFig = [];
                obj.UnAxes = [];
                obj.UnImage = [];                
            else
                if iscell(figH)
                    position = figH{2};
                    figH = figH{1};
                end
            obj.UnFig = figH;
            obj.UnAxes = axes('Parent',figH,...
                'color','none',...
                'DataAspectRatio',[1 1 1],...
                'Units','Normalized',...
                'Position',position,...
                'XTick',[],...
                'YTick',[],...
                'Xlim',[0 obj.MaxX],...
                'Ylim',[0 obj.MaxY],...
                'CLim',[obj.CMin obj.CMax],...
                'HitTest','on',...
                'visible','on',...
                'Xcolor',get(figH,'color'),...
                'ycolor',get(figH,'color'));
            
            obj.UnImage = image('Parent',obj.UnAxes,...
                'CDataMapping','scaled',...
                'CData',0,...
                'ButtonDownFcn',@(~,~) obj.zoomHandler);
            % CData is the actual image data
            end
        end
        function setImData(obj,imData)
            set(obj.UnImage,'CData',imData);
            % set the default viewing limits
            obj.MaxX = max(size(imData,2),1);
            obj.MaxY = max(size(imData,1),1);
            set(obj.UnAxes,'Xlim',[0 obj.MaxX],...
                'YLim',[0 obj.MaxY]);
            obj.CMin = min(imData(:));
            obj.CMax = max(imData(:));
            
            if isempty(obj.CMin) || isempty(obj.CMax)
                obj.CMin = 0;
                obj.CMax = 1;
            end
            if ~isnan(obj.CMax) && ~isnan(obj.CMin) && obj.CMax > obj.CMin
                set(obj.UnAxes,'CLim',...
                    [obj.CMin ...
                    max((obj.CMax-obj.CMin)*obj.C_SCALE + obj.CMin,...
                    obj.C_DELTA_MIN + obj.CMin)]);
            end
        end
        function setColorLim(obj,cMin,cMax)
            % cMin and cMax are fractions of overall range
            if cMax < cMin
                cMax = cMin + 2*eps(cMin);
            end
            cRange = obj.CMax - obj.CMin;
            set(obj.UnAxes,'Clim',cMin + cRange*[cMin cMax]);
        end
        function unAx = getUnAx(obj)
            unAx = obj.UnAxes;
        end
    end % methods public
    
    methods (Access = protected)
        function zoomHandler(obj)
            % we can get at the last point clicked using the CurrentPoint
            % property of UnAxes
            
            selectionType = get(obj.UnFig,'SelectionType');
            
            if strcmp(selectionType,'open')
                % we have a double click, which means zoom in
                currentPoint = get(obj.UnAxes,'CurrentPoint');
                currentX = currentPoint(2,1);
                currentY = currentPoint(2,2);
                currentXlim = get(obj.UnAxes,'XLim');
                deltaX = currentXlim(2) - currentXlim(1);
                currentYlim = get(obj.UnAxes,'YLim');
                deltaY = currentYlim(2) - currentYlim(1);
                
                posMinX = 0 + deltaX/4;
                posMaxX = obj.MaxX - deltaX/4;
                currentX = min(currentX,posMaxX);
                currentX = max(currentX,posMinX);
                
                posMinY = 0 + deltaY/4;
                posMaxY = obj.MaxY - deltaX/4;
                currentY = min(currentY,posMaxY);
                currentY = max(currentY,posMinY);
                
                minX = currentX - deltaX/4;
                maxX = currentX + deltaX/4;
                minY = currentY - deltaY/4;
                maxY = currentY + deltaY/4;
                
                set(obj.UnAxes,'XLim',[minX, maxX],...
                    'YLim',[minY, maxY]);
            elseif strcmp(selectionType,'alt')
                % we have a right click, which means reset zoom
                set(obj.UnAxes,'Xlim',[0 obj.MaxX],...
                    'YLim',[0 obj.MaxY]);
            end
        end % zoomHandler
    end
end
