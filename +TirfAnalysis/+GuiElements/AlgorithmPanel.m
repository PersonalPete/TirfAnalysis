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
        FixedWidH
        EllipseH
        PosChangeMaxH
        MinFitWidH
        MaxFitWidH
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
            obj.FixedWidH = ...
                obj.addOption(2,{'fixed width'},callback);
            obj.EllipseH = ...
                obj.addOption(3,{'elliptical'},callback);
            obj.PosChangeMaxH = ...
                obj.addOption(4,{'max pos change'},callback);
            obj.MinFitWidH = ...
                obj.addOption(5,{'max fit width'},callback);
            obj.MaxFitWidH = ...
                obj.addOption(6,{'max fit width'},callback);
        end
        
        % getter for the current information in the panel
        function [isFixPos, isFixWid, isEllip,...
                maxPosChange, minFitWid, maxFitWid]...
                = getAlgorithmInfo(obj)
            isFixPos = obj.FixedPosH.getValue;
            isFixWid = obj.FixedWidH.getValue;
            isEllip = obj.EllipseH.getValue;
            maxPosChange = obj.PosChangeMaxH.getValue;
            minFitWid = obj.MinFitWidH.getValue;
            maxFitWid = obj.MaxFitWidH.getValue;
        end
        
        function setAlgorithmInfo(obj,...
                isFixPos, isFixWid, isEllip,...
                maxPosChange, minFitWid, maxFitWid)
            obj.FixedPosH.setValue(isFixPos);
            obj.FixedWidH.setValue(isFixWid);
            obj.EllipseH.setValue(isEllip);
            obj.PosChangeMaxH.setValue(maxPosChange);
            obj.MinFitWidH.setValue(minFitWid);
            obj.MaxFitWidH.setValue(maxFitWid);
        end
        
    end
end