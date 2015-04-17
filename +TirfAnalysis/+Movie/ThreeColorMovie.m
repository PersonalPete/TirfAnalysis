classdef ThreeColorMovie < handle
    %% ThreeColorMovie wraps a tirf movie and naively segments
    properties (SetAccess = protected)
        TirfMovie % should inherit from AbstractMovie
        GreenLimits
        RedLimits
        NirLimits
    end
    methods (Access = public)
        function obj = ThreeColorMovie(tirfMovie,greenLimits,redLimits,nirLimits)
            % Constructor - limits in the form [xMin, xMax, yMin, yMax];
            obj.TirfMovie = tirfMovie;
            obj.GreenLimits = greenLimits;
            obj.RedLimits = redLimits;
            obj.NirLimits = nirLimits;
        end
        % setters for changing the limits
        function setLimits(obj,greenLimits,redLimits,nirLimits)
            obj.GreenLimits = greenLimits;
            obj.RedLimits = redLimits;
            obj.NirLimits = nirLimits;            
        end % setLimits
        % getters for the properties
        function greenLimits = getGreenLimits(obj)
            greenLimits = obj.GreenLimits;
        end
        function redLimits = getRedLimits(obj)
            redLimits = obj.RedLimits;
        end
        function nirLimits = getNirLimits(obj)
            nirLimits = obj.NirLimits;
        end
        % getters for a particular frame's data
        function greenFrame = getGreenFrame(obj,frameNum)
            greenFrame = ...
                obj.TirfMovie.getData(frameNum,obj.GreenLimits);
        end
        function redFrame = getRedFrame(obj,frameNum)
            redFrame = ...
                obj.TirfMovie.getData(frameNum,obj.RedLimits);
        end
        function nirFrame = getNirFrame(obj,frameNum)
            nirFrame = ...
                obj.TirfMovie.getData(frameNum,obj.NirLimits);
        end
        function movieInfoString = getMovieInfo(obj)
            movieInfoString = obj.TirfMovie.getMovieInfo;
        end
    end
end