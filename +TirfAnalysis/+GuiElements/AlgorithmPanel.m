classdef AlgorithmPanel < TirfAnalysis.GuiElements.AbstractPanel
    % methods
    %
    % [linkRad, nearNeighRad, minEllip, minWid, maxWid]...
    %           = getLinkingInfo
    %
    % setLinkingInfo(obj,...
    %       linkRad, nearNeighRad, minEllip, minWid, maxWid)
    %
    
    properties (Access = protected)
        FixedPosH
%         FixedWidH
        EllipseH
        PosChangeMaxH
        MinFitWidH
        MaxFitWidH
        WindowRadH
    end
    
    methods (Access = public)
        % constructor
        function obj = AlgorithmPanel(figH,position,callback)
            
            if nargin < 3
                callback = '';
            end
            
            % call superclass constructor
            obj = ...
                obj@TirfAnalysis.GuiElements.AbstractPanel(figH,position);
            
            % add the title
            obj.addTitle('ALGORITHM');
            
            % add the edit boxes
            obj.FixedPosH = ...
                obj.addOption(1,{'fixed position'},callback);
%             obj.FixedWidH = ...
%                 obj.addOption(2,{'fixed width'},callback);
            obj.EllipseH = ...
                obj.addOption(2,{'elliptical'},callback);
            obj.PosChangeMaxH = ...
                obj.addOption(3,{'max pos change'},callback);
            obj.MinFitWidH = ...
                obj.addOption(4,{'min fit width'},callback);
            obj.MaxFitWidH = ...
                obj.addOption(5,{'max fit width'},callback);
            obj.WindowRadH = ...
                obj.addOption(6,{'window radius'},callback);
        end
        
        % getter for the current information in the panel
        function [isFixPos, isFixWid, isEllip,...
                maxPosChange, minFitWid, maxFitWid, windowRad]...
                = getAlgorithmInfo(obj)
            isFixPos = obj.FixedPosH.getValue;
            isFixWid = 0; % obj.FixedWidH.getValue;
            isEllip = obj.EllipseH.getValue;
            maxPosChange = obj.PosChangeMaxH.getValue;
            minFitWid = obj.MinFitWidH.getValue;
            maxFitWid = obj.MaxFitWidH.getValue;
            windowRad = obj.WindowRadH.getValue;
        end
        
        function setAlgorithmInfo(obj,...
                isFixPos, isFixWid, isEllip,...
                maxPosChange, minFitWid, maxFitWid,windowRad)
            obj.FixedPosH.setValue(isFixPos);
%             obj.FixedWidH.setValue(isFixWid);
            obj.EllipseH.setValue(isEllip);
            obj.PosChangeMaxH.setValue(maxPosChange);
            obj.MinFitWidH.setValue(minFitWid);
            obj.MaxFitWidH.setValue(maxFitWid);
            obj.WindowRadH.setValue(windowRad);
        end
        
    end
end