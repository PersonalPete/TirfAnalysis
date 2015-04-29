classdef MovieResult % A value class
    properties (Access = protected)
        Particles
        AnalysisSettings
        MovieMetadata
        MovieFileName;
    end
    
    methods (Access = public)
        % constructor
        function obj = MovieResult(...
                particles,analysisSettings,movieMetadata,movieFileName)
            if nargin < 4
                obj.Particles = TirfAnalysis.Results.Particle();
                obj.AnalysisSettings = TirfAnalysis.Main.AnalysisSettings();
                obj.MovieMetadata.frTime = [];
                obj.MovieMetadata.alexSequence = [];
                obj.MovieFileName = {};
            else
                obj.Particles = particles;
                obj.AnalysisSettings = analysisSettings;
                obj.MovieMetadata = movieMetadata;
                obj.MovieFileName = movieFileName;
                
            end
        end
        % getters
        function particle = getParticle(obj,numParticle)
            if nargin < 2
                particle = obj.Particles;
            else
                particle = obj.Particles(numParticle);
            end
        end
        function analysisSettings = getAnalysisSettings(obj,n)
            if nargin > 1 && n ~= 1
                warning('This is not a compiled result, only one movie');
            end
            analysisSettings = obj.AnalysisSettings;
        end
        function movieMetadata = getMovieMetadata(obj,n)
            if nargin > 1 && n ~= 1
                warning('This is not a compiled result, only one movie');
            end
            movieMetadata = obj.MovieMetadata;
        end
        function movieFileName = getMovieFileName(obj,n)
            if nargin > 1 && n ~= 1
                warning('This is not a compiled result, only one movie');
            end
            movieFileName = obj.MovieFileName;
        end
        
        % derived/computed properties
        function numParticles = getNumParticles(obj)
            numParticles = numel(obj.Particles);
        end
        
        % this one is for the subclass with multiple movies, for this
        % class, if present n = 1.
        function numInMovie = getNumInMovie(obj,n)
            if nargin > 1 && n ~= 1
                warning('This is not a compiled result, only one movie');
            end
            numInMovie = obj.getNumParticles;
        end
        
        function movieFileName = getMovieNameForParticle(obj,particleNo)
            movieFileName = obj.getMovieFileName(...
                find(particleNo <= cumsum(obj.getNumInMovie),1,'first'));
        end
        
    end
end