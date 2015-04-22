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
            obj.Particles = particles;
            obj.AnalysisSettings = analysisSettings;
            obj.MovieMetadata = movieMetadata;
            obj.MovieFileName = movieFileName;
        end
        % getters
        function particle = getParticle(obj,numParticle)
            particle = obj.Particles(numParticle);
        end  
        function analysisSettings = getAnalysisSettings(obj)
            analysisSettings = obj.AnalysisSettings;
        end
        function movieMetadata = getMoviemetadata(obj)
            movieMetadata = obj.MovieMetadata;
        end
        function movieFileName = getMovieFileName(obj)
            movieFileName = obj.MovieFileName;
        end
        
        % derived/computed properties
        function numParticles = getNumParticles(obj)
            numParticles = numel(obj.Particles);
        end
        
    end
end