classdef FitsMovie < TirfAnalysis.Movie.AbstractMovie
%% FitsMovie is the concrete movie class for reading in and accessing data
% make it only load on request rather than caching the whole movie on
% instantiation


properties (Access = protected)
    FileInfo
end

% from a FITS file
    methods (Access = public)
        function obj = FitsMovie(filename)
            obj.MovieInfo = filename;
            
            fileinfo = fitsinfo(filename);
            obj.MovieData = fileinfo.PrimaryData.Size;
            obj.FileInfo = fileinfo;
            
            % obj.MovieData = fitsread(filename);
        end
        
        % @Override from AbstractMovie
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
            
            % need to interpret frameNum
            if islogical(frameNum)
                frameIdx = 1:length(frameNum);
                frameNum = frameIdx(frameNum);
            end
                       
            if numel(frameNum) > 1 
                spacing = frameNum(2) - frameNum(1);
                frameNum = [frameNum(1), spacing, frameNum(end)];
            end
            
            if isempty(frameNum)
                frameData = zeros(yRange(2) - yRange(1) + 1,...
                    xRange(2) - xRange(1) + 1,...
                    0);
            else
            
                frameData = fitsread(obj.MovieInfo,...
                    'Info',obj.FileInfo,...
                    'PixelRegion',{yRange,xRange,frameNum});
            end
        end 
        % @Override from AbstractMovie
        function nFrames = getNFrames(obj)
            nFrames = obj.MovieData(3);
        end
        % @Override from AbstractMovie
        function [nxPix, nyPix] = getNPix(obj)
            nxPix = obj.MovieData(2);
            nyPix = obj.MovieData(1);
        end
        
        % @Override from AbstractMovie 
        function movieLim = getMovieLim(obj)
            movieLim = obj.MovieData;
        end
        
    end
    
    
    
end