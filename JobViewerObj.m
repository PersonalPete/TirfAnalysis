classdef JobViewerObj < handle
    properties
        Sigma
        NPoints
        SavePath
    end
    methods
        function obj = JobViewerObj(sigma,nPoints,savePath)
            if nargin < 3
                return;
            end
            obj.Sigma = sigma;
            obj.NPoints = nPoints;
            obj.SavePath = savePath;
        end
        function [randomData, savePath] = generateRandom(obj)
            randomData = obj.Sigma * randn(obj.NPoints);
            savePath = obj.SavePath;
            % save(obj.SavePath,'randomData');
        end
    end
end
           