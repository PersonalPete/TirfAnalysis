classdef (Abstract) AbstractMovie < handle
    %% AbstractMovie is the abstract base class for the movie wrappers
    properties (SetAccess = protected)
        MovieData
        MovieInfo
    end
    methods (Access = public)
        function nFrames = getNFrames(obj)
            nFrames = size(obj.MovieData,3);
        end
        
        function [nxPix, nyPix] = getNPix(obj)
            nxPix = size(obj.MovieData,2);
            nyPix = size(obj.MovieData,1);
        end
        
        function frameData = getData(obj,frameNum,range,yRange)
            %% get the data for a specific frame, frameNum
            % either getData(frameNum,[xMin, xMax, yMin, yMax]) or
            % getData(frameNum,[xMin xMax],[yMin yMax])
            if nargin < 3 % defaults to the full frame
                [nxPix, nyPix] = obj.getNPix;
                xRange = [1 nxPix];
                yRange = [1 nyPix];
            elseif nargin < 4
                xRange = range(1:2);
                yRange = range(3:4);
            elseif nargin == 4
                xRange = range;
            end
            frameData = obj.MovieData(...
                yRange(1):yRange(2),...
                xRange(1):xRange(2),...
                frameNum);
        end
        
        function movieLim = getMovieLim(obj)
            movieLim = size(obj.MovieData);
        end
        
        function movieInfo = getMovieInfo(obj)
            % Information about the movie (i.e. its filename)
            movieInfo = obj.MovieInfo;
        end       
    end
end