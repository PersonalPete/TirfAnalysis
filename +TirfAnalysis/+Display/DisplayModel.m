classdef DisplayModel < handle
    % DisplayModel holds the data for the visualisation of analysis results
    properties (Access = protected)
        MovieResults % this is a compiled movie result for multiple movies
        CurrentParticle
        MovieLoaded
    end
    
    properties (Access = protected, Constant)
        ANALYSIS_FILE = '*.fit3Result.mat'
        COMPILED_FILE = '*.fit3Compiled.mat'
    end
    
    events
        DisplayNeedsUpdate
    end
    
    methods (Access = public)
        % constructor
        function obj = DisplayModel()
            obj.MovieResults = TirfAnalysis.Results.MovieResult();
            obj.CurrentParticle = 1;
            obj.MovieLoaded = 0;
        end
        
        % loading and saving analysis data
        function success = loadAnalysis(obj)
            success = 0;
            [file, path] = uigetfile(...
                [obj.ANALYSIS_FILE ';' obj.COMPILED_FILE],...
                'Load Analysis','Multiselect','on');
            if iscell(file) || (~isempty(file) && ~all(file == 0))
                if iscell(file)
                    movieResults = cell(size(file));
                    for iFile = 1:length(file)
                        loadFile = load(fullfile(path,file{iFile}));
                        movieResults{iFile} = loadFile.movieResult;
                    end
                else
                    loadFile = load(fullfile(path,file));
                    movieResults = loadFile.movieResult;
                end
                obj.MovieResults = ...
                    TirfAnalysis.Results.MovieResultCompiled(movieResults);
                obj.CurrentParticle = 1;
                success = 1;
            end
            notify(obj,'DisplayNeedsUpdate');
        end
        
        function success = saveAnalysis(obj)
            success = 0;
            [file, path] = ...
                uiputfile(obj.COMPILED_FILE,'Save Compiled Files','');
            if ~isempty(file) && all(file~=0)
                savePath = fullfile(path,file);
                movieResult = obj.MovieResults;
                save(savePath,'movieResult','-v7.3');
                % save in a R2006b or later format '-v7.3';
                success = 1;
                obj.MovieLoaded = 1;
            end
        end
        
        % changing the particle
        function nextParticle(obj)
            % work out the largest particle number we could ask for
            maxParticle = obj.MovieResults.getNumParticles();
            % make sure we don't exceed this
            obj.CurrentParticle = min(obj.CurrentParticle + 1,maxParticle);
            % notify any displays that are listening that they need to
            % update
            if obj.MovieLoaded
                notify(obj,'DisplayNeedsUpdate');
            end
        end
        
        function previousParticle(obj)
            obj.CurrentParticle = max(1,obj.CurrentParticle - 1);
            if obj.MovieLoaded
                notify(obj,'DisplayNeedsUpdate');
            end
        end
        
        function specificParticle(obj,particleNumber)
            maxParticle = obj.MovieResults.getNumParticles();
            obj.CurrentParticle = min(particleNumber,maxParticle);
            obj.CurrentParticle = round(max(obj.CurrentParticle,1));
            if obj.MovieLoaded
                notify(obj,'DisplayNeedsUpdate');
            end
        end
        
        % getters for retreiving model state
        function currentParticleNumber = getCurrentParticleNumber(obj)
            currentParticleNumber = obj.CurrentParticle;
        end
        
        function currentParticle = getCurrentParticle(obj)
            currentParticle = ...
                obj.MovieResults.getParticle(obj.CurrentParticle);
        end
        
        function currentFileName = getCurrentFileName(obj)
            currentFileName = obj.MovieResults.getMovieNameForParticle(...
                obj.CurrentParticle);
        end
    end
end

