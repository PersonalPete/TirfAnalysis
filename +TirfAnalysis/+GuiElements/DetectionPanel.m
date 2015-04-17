classdef DetectionPanel < TirfAnalysis.GuiElements.AbstractPanel
    % methods
    % 
    % [nFrames,kernel,radFac,...
    %            greThresh,redThresh,nirThresh] = getDetectionInfo
    %
    % setLinkingInfo(obj,...
    %            nFrames,kernel,radFac,...
    %            greThresh,redThresh,nirThresh)
    %
    %
    properties (Access = protected)
        NFramesH
        KernelH
        RadFacH
        GreenThreshH
        RedThreshH
        NirThreshH
    end
    
    methods (Access = public)
        % constructor
        function obj = DetectionPanel(figH,position,callback)
            
            if nargin < 3
                callback = '';
            end
            
            % call superclass constructor
            obj = ...
                obj@TirfAnalysis.GuiElements.AbstractPanel(figH,position);
            
            % add the title
            obj.addTitle('DETECTION');
            
            % add the edit boxes
            obj.NFramesH = ...
                obj.addOption(1,{'# frames average'},callback);
            obj.KernelH = ...
                obj.addOption(2,{'smoothing kernel'},callback);
            obj.RadFacH = ...
                obj.addOption(3,{'compare radius'},callback);
            obj.GreenThreshH = ...
                obj.addOption(4,{'green threshold'},callback);
            obj.RedThreshH = ...
                obj.addOption(5,{'red threshold'},callback);
            obj.NirThreshH = ...
                obj.addOption(6,{'NIR threshold'},callback);
            
        end
        
        % getter for the current information in the panel
        function [nFrames,kernel,radFac,...
                greThresh,redThresh,nirThresh] = getDetectionInfo(obj)
            nFrames = obj.NFramesH.getValue;
            kernel = obj.KernelH.getValue;
            radFac = obj.RadFacH.getValue;
            greThresh = obj.GreenThreshH.getValue;
            redThresh = obj.RedThreshH.getValue;
            nirThresh = obj.NirThreshH.getValue;
        end
        function setDetectionInfo(obj,...
                nFrames,kernel,radFac,...
                greThresh,redThresh,nirThresh)
            obj.NFramesH.setValue(nFrames);
            obj.KernelH.setValue(kernel);
            obj.RadFacH.setValue(radFac);
            obj.GreenThreshH.setValue(greThresh);
            obj.RedThreshH.setValue(redThresh);
            obj.NirThreshH.setValue(nirThresh);
        end
        
    end
end