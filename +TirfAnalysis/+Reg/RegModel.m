classdef RegModel < handle
    properties (SetAccess = protected)
        BeadsMovie = []
        MovieLim
        Defaults
        GreenLimits
        RedLimits
        NirLimits
        CurrentTformInfo3
    end
    properties (Constant = true)
        DFT_PATH = '+TirfAnalysis\+Defaults\Current.mat'
    end
    events
        TransformNeedsUpdating
    end
    methods (Access = public)
        function obj = RegModel()
            % constructor
            obj.Defaults = load(obj.DFT_PATH);
            obj.GreenLimits = obj.Defaults.greenLim;
            obj.RedLimits = obj.Defaults.redLim;
            obj.NirLimits = obj.Defaults.nirLim;
        end % constructor
        
        function success = loadMovie(obj,moviePath)
            try
                % load the fits file
                fitsMovie = TirfAnalysis.Movie.FitsMovie(moviePath);
                movieLim = fitsMovie.getMovieLim;
                obj.MovieLim = movieLim;
                % check if our channels (loaded perhaps from default) are
                % out-of-bounds for the supplied image
                if obj.GreenLimits(2) > movieLim(2) 
                    obj.GreenLimits(2) = movieLim(2);                    
                end
                if obj.GreenLimits(4) > movieLim(1)
                    obj.GreenLimits(4) = movieLim(1);
                end
                if obj.RedLimits(2) > movieLim(2) 
                    obj.RedLimits(2) = movieLim(2);
                end
                if obj.RedLimits(4) > movieLim(1)
                    obj.RedLimits(4) = movieLim(1);
                end
                if  obj.NirLimits(2) > movieLim(2) 
                    obj.NirLimits(2) = movieLim(2);
                end
                if  obj.NirLimits(4) > movieLim(1)
                    obj.NirLimits(4) = movieLim(1);
                end
                % attach the channel limits information
                obj.BeadsMovie = ...
                    TirfAnalysis.Movie.ThreeColorBeadsMovie(...
                    fitsMovie,...
                    obj.GreenLimits,...
                    obj.RedLimits,...
                    obj.NirLimits);
                
                success = 1;
                notify(obj,'TransformNeedsUpdating');
            catch
                success = 0;
            end
        end % function loadMovie
        
        function setLimits(obj,greenLim,redLim,nirLim)
            
            % change the image limits
            obj.GreenLimits = greenLim;
            obj.RedLimits = redLim;
            obj.NirLimits = nirLim;
            
            if ~isempty(obj.BeadsMovie) % i.e. don't do it if we haven't
                % yet loaded a movie
                movieLim = obj.MovieLim;
                % check if our channels (loaded perhaps from default) are
                % out-of-bounds for the supplied image
                if obj.GreenLimits(2) > movieLim(2) 
                    obj.GreenLimits(2) = movieLim(2);                    
                end
                if obj.GreenLimits(4) > movieLim(1)
                    obj.GreenLimits(4) = movieLim(1);
                end
                if obj.RedLimits(2) > movieLim(2) 
                    obj.RedLimits(2) = movieLim(2);
                end
                if obj.RedLimits(4) > movieLim(1)
                    obj.RedLimits(4) = movieLim(1);
                end
                if  obj.NirLimits(2) > movieLim(2) 
                    obj.NirLimits(2) = movieLim(2);
                end
                if  obj.NirLimits(4) > movieLim(1)
                    obj.NirLimits(4) = movieLim(1);
                end
                
                % and set them on the three color movie
                obj.BeadsMovie.setLimits(...
                    obj.GreenLimits,...
                    obj.RedLimits,...
                    obj.NirLimits);
            end
            notify(obj,'TransformNeedsUpdating');
        end % function setLimits
        
        function [greenF, redF, nirF, greenLim, redLim, nirLim] = getInfo(obj)
            % query the current imagedata and imageLimits
            if ~isempty(obj.BeadsMovie)
                greenF = obj.BeadsMovie.getGreenFrame;
                redF = obj.BeadsMovie.getRedFrame;
                nirF = obj.BeadsMovie.getNirFrame;
            else
                greenF = [];
                redF = [];
                nirF = [];
            end
            greenLim = obj.GreenLimits;
            redLim = obj.RedLimits;
            nirLim = obj.NirLimits;
        end
        
        function [success, tform, positionsInRed] = calculateTransform(obj)
             try
                [tform, positionsInRed] = ...
                    TirfAnalysis.Reg.Detection.threeColorTransform(...
                    obj.BeadsMovie);
                obj.CurrentTformInfo3 = tform;
                success = 1;
             catch
                tform = [];
                positionsInRed = [];
                success = 0;
             end
            
        end % function calculateTransform
        
        function tform = getCurrentTform(obj)
            tform = obj.CurrentTformInfo3;
        end
        function success = saveTransform(obj,savePath)
            tformInfo3 = obj.CurrentTformInfo3;
            success = 0;
            if ~isempty(tformInfo3)
                try
                    save(savePath,'tformInfo3');
                    success = 1;
                catch
                    % something went wrong saving
                end
            end
        end % function saveTransform
    end
end
