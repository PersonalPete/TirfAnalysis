classdef ThreeColorBeadsMovie < TirfAnalysis.Movie.ThreeColorMovie
    %% ThreeColorMovie wraps a tirf movie and naively segments
    methods (Access = public)
        function obj = ThreeColorBeadsMovie(tirfMovie,greenLimits,redLimits,nirLimits)
            % Constructor - limits in the form [xMin, xMax, yMin, yMax];
            % Just use the superclass constructor
            obj = obj@TirfAnalysis.Movie.ThreeColorMovie(...
                tirfMovie,greenLimits,redLimits,nirLimits);
        end
        % getters for a particular frame's data 
        % include a no args syntax for getting the average over all
        % frames
        % @Override from parent
        function greenFrame = getGreenFrame(obj,frameNum)

            if nargin < 2
                greenFrame = ...
                    mean(...
                    obj.TirfMovie.getData(...
                    1:obj.TirfMovie.getNFrames,...
                    obj.GreenLimits),...
                    3);
            else
                greenFrame = obj.TirfMovie.getData(frameNum,obj.GreenLimits);
            end
        end
        % @Override from parent
        function redFrame = getRedFrame(obj,frameNum)
            if nargin < 2
                redFrame = ...
                    mean(...
                    obj.TirfMovie.getData(...
                    1:obj.TirfMovie.getNFrames,...
                    obj.RedLimits),...
                    3);
            else
                redFrame = obj.TirfMovie.getData(frameNum,obj.NirLimits);
            end
        end
        % @Override from parent
        function nirFrame = getNirFrame(obj,frameNum)
            if nargin < 2
                nirFrame = ...
                    mean(...
                    obj.TirfMovie.getData(...
                    1:obj.TirfMovie.getNFrames,...
                    obj.NirLimits),...
                    3);
            else
                nirFrame = obj.TirfMovie.getData(frameNum,obj.NirLimits);
            end
        end
    end
end