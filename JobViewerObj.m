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
    
    methods (Static)
        function [randomData,savePath,loadData] = ...
                generateRandomStatic(sigma,nPoints,savePath)
            jvO = JobViewerObj(sigma,nPoints,savePath);
            [randomData, savePath] = jvO.generateRandom;
            
            % test whether we can load stuff
            loadData = load(fullfile('F:\Current Work\New Microscope\ImageAnalysis\TestBed\TirfAnalysis','NIRdet.set3.mat'));
            rng('shuffle');
            pause(20*rand);
            save(savePath,'randomData');
        end
    end
end
           