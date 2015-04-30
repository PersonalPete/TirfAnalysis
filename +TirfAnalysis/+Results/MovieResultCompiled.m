classdef MovieResultCompiled < TirfAnalysis.Results.MovieResult
    properties (Access = protected)
        NumInEachMovie
    end
    
    methods (Access = public)
        % constructor
        function obj = MovieResultCompiled(movieResults)
            % loop over movies and extract from them
            % convert to a cell array if we weren't passed one
            if ~iscell(movieResults)
                movieResults = num2cell(movieResults);
            end            
            % loop over cells and identify if they are compiled or not
            movieResultCell{numel(movieResults)} = ...
                TirfAnalysis.Results.MovieResult();
            numOriginalMovies = 0;
            for iMovieResult = 1:numel(movieResults)
                % work out which particles are in each movie
                lastDex = ...
                    cumsum(movieResults{iMovieResult}.getNumInMovie);
                firstDex = [1, (lastDex(1:end-1) + 1)];
                for jMovie = 1:length(lastDex)
                    numOriginalMovies = numOriginalMovies + 1;
                    movieResultCell{numOriginalMovies} = ...
                        TirfAnalysis.Results.MovieResult(...
                        movieResults{iMovieResult}.getParticle(...
                        firstDex(jMovie):lastDex(jMovie)),...
                        movieResults{iMovieResult}.getAnalysisSettings(...
                        jMovie),...
                        movieResults{iMovieResult}.getMovieMetadata(...
                        jMovie),...
                        movieResults{iMovieResult}.getMovieFileName(...
                        jMovie));
                end
            end
            
            movieResultCell = movieResultCell(1:numOriginalMovies);
            
            numMovies = numel(movieResultCell);
            for iMovie = 1:numMovies
                numPartInMovie = movieResultCell{iMovie}.getNumParticles;
                obj.NumInEachMovie(iMovie) = numPartInMovie;
            end
            
            lastDex = cumsum(obj.NumInEachMovie);
            firstDex = [1, (lastDex(1:end-1) + 1)];
            
            obj.Particles(lastDex(numMovies)) = ...
                TirfAnalysis.Results.Particle();
            
            for iMovie = 1:numMovies
                obj.Particles(firstDex(iMovie):lastDex(iMovie)) = ...
                    movieResultCell{iMovie}.getParticle();
                obj.AnalysisSettings(iMovie) = ...
                    movieResultCell{iMovie}.getAnalysisSettings;
                obj.MovieMetadata(iMovie) = ...
                    movieResultCell{iMovie}.getMovieMetadata;
                obj.MovieFileName{iMovie} = ...
                    movieResultCell{iMovie}.getMovieFileName;
            end
        end
        
        % @Override TirfAnalysis.Results.MovieResult
        function analysisSettings = getAnalysisSettings(obj,n)
            if nargin < 2
                analysisSettings = obj.AnalysisSettings(1);
            else
                analysisSettings = obj.AnalysisSettings(n);
            end
        end
        % @Override TirfAnalysis.Results.MovieResult
        function movieMetadata = getMovieMetadata(obj,n)
            if nargin < 2
                movieMetadata = obj.MovieMetadata(1);
            else
                movieMetadata = obj.MovieMetadata(n);
            end
        end
        % @Override TirfAnalysis.Results.MovieResult
        function movieFileName = getMovieFileName(obj,n)
            if nargin < 2
                movieFileName = obj.MovieFileName{1};
            else
                movieFileName = obj.MovieFileName{n};
            end
        end
        % @Override TirfAnalysis.Results.MovieResult
        function numInMovie = getNumInMovie(obj,n)
            if nargin < 2
                numInMovie = obj.NumInEachMovie;
            else
                numInMovie = obj.NumInEachMovie(n);
            end
        end
        
        function nMovies = getNumMovies(obj)
            nMovies = numel(obj.NumInEachMovie);
        end
        
    end
end