classdef TformInfo3
    %% TformInfo3 is a value class that contains 3-color registration info
    % [outPoints, yOutPoints] = transformG2R(obj,points,yPoints)
    % [outPoints, yOutPoints] = transformN2R(obj,points,yPoints)
    % [outPoints, yOutPoints] = transformR2G(obj,points,yPoints)
    % [outPoints, yOutPoints] = transformR2N(obj,points,yPoints)
    properties (SetAccess = protected)
        GreenRedT
        NirRedT
        GreenLimits
        RedLimits
        NirLimits
        
        % these two are just measures of the goodness-of-fit
        % they are the distance to the nearest 'bead' in the green/NIR
        % channels for each bead in the red channel
        GreenDist
        NirDist
    end
    methods (Access = public)
        function obj = TformInfo3(arg1,arg2,arg3,arg4,arg5,arg6,arg7)
            if nargin == 0
                arg1 = eye(3);
                arg2 = eye(3);
                arg3 = [0 1 0 1];
                arg4 = [0 1 0 1];
                arg5 = [0 1 0 1];
                arg6 = [];
                arg7 = [];
            end
            
            if nargin < 7
                arg7 = [];
            end
            if nargin < 6
                arg6 = [];
            end
            
            % constructor
            obj.GreenRedT = arg1;
            obj.NirRedT = arg2;
            obj.GreenLimits = arg3;
            obj.RedLimits = arg4;
            obj.NirLimits = arg5;
            obj.GreenDist = arg6;
            obj.NirDist = arg7;
        end
        
        % forward transforms
        function [outPoints, yOutPoints] = transformG2R(obj,points,yPoints)
            % perform the transform
            % allows two syntaxes:
            % points = obj.transformG2R(queryPoints)
            % [xPoints, yPoints] = ...
            %    obj.transformG2R(xQueryPoints,yQueryPoints)
            if isempty(points)
                outPoints = [];
                yOutPoints = [];
            else
                if nargin == 2
                    xPoints = points(:,1);
                    yPoints = points(:,2);
                    [xOutPoints, yOutPoints] = ...
                        obj.GreenRedT.transformPointsForward(xPoints,yPoints);
                    outPoints = [xOutPoints,yOutPoints];
                    yOutPoints = [];
                elseif nargin == 3
                    xPoints = points;
                    [outPoints, yOutPoints] = ...
                        obj.GreenRedT.transformPointsForward(xPoints,yPoints);
                end
            end
        end
        function [outPoints, yOutPoints] = transformN2R(obj,points,yPoints)
            % perform the transform
            % allows two syntaxes:
            % points = obj.transformG2R(queryPoints)
            % [xPoints, yPoints] = ...
            %    obj.transformG2R(xQueryPoints,yQueryPoints)
            if isempty(points)
                outPoints = [];
                yOutPoints = [];
            else
                if nargin == 2
                    xPoints = points(:,1);
                    yPoints = points(:,2);
                    [xOutPoints, yOutPoints] = ...
                        obj.NirRedT.transformPointsForward(xPoints,yPoints);
                    outPoints = [xOutPoints,yOutPoints];
                    yOutPoints = [];
                elseif nargin == 3
                    xPoints = points;
                    [outPoints, yOutPoints] = ...
                        obj.GreenRedT.transformPointsForward(xPoints,yPoints);
                end
            end
        end
        
        % reverse transforms
        function [outPoints, yOutPoints] = transformR2G(obj,points,yPoints)
            % perform the transform
            % allows two syntaxes:
            % points = obj.transformG2R(queryPoints)
            % [xPoints, yPoints] = ...
            %    obj.transformG2R(xQueryPoints,yQueryPoints)
            if isempty(points)
                outPoints = [];
                yOutPoints = [];
            else
                if nargin == 2
                    xPoints = points(:,1);
                    yPoints = points(:,2);
                    [xOutPoints, yOutPoints] = ...
                        obj.GreenRedT.transformPointsInverse(xPoints,yPoints);
                    outPoints = [xOutPoints,yOutPoints];
                    yOutPoints = [];
                elseif nargin == 3
                    xPoints = points;
                    [outPoints, yOutPoints] = ...
                        obj.GreenRedT.transformPointsInverse(xPoints,yPoints);
                end
            end
        end
        function [outPoints, yOutPoints] = transformR2N(obj,points,yPoints)
            if isempty(points)
                outPoints = [];
                yOutPoints = [];
            else
                % perform the transform
                % allows two syntaxes:
                % points = obj.transformG2R(queryPoints)
                % [xPoints, yPoints] = ...
                %    obj.transformG2R(xQueryPoints,yQueryPoints)
                if nargin == 2
                    xPoints = points(:,1);
                    yPoints = points(:,2);
                    [xOutPoints, yOutPoints] = ...
                        obj.NirRedT.transformPointsInverse(xPoints,yPoints);
                    outPoints = [xOutPoints,yOutPoints];
                    yOutPoints = [];
                elseif nargin == 3
                    xPoints = points;
                    [outPoints, yOutPoints] = ...
                        obj.NirRedT.transformPointsInverse(xPoints,yPoints);
                end
            end
        end
        
        % getters for the frame limits
        function greenLimits = getGreenLimits(obj)
            greenLimits = obj.GreenLimits;
        end
        function redLimits = getRedLimits(obj)
            redLimits = obj.RedLimits;
        end
        function nirLimits = getNirLimits(obj)
            nirLimits = obj.NirLimits;
        end
        
        % getters for the goodness-of-fit information
        function greenDist = getGreenDist(obj)
            greenDist = obj.GreenDist;
        end
        function nirDist = getNirDist(obj)
            nirDist = obj.NirDist;
        end
        
    end % methods
end