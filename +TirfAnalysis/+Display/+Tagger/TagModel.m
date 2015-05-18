classdef TagModel < TirfAnalysis.Display.DisplayModel
    % subclass of the display model for trajectory viewing that adds
    % loading and saving of 'tags' which can indicate observed behaviour of
    % single molecule timetraces
    
    properties (Access = protected)
        TagInfo
    end
    
    methods (Access = public)
        % constructor
        function obj = TagModel
            % just uses superclass constructor with no args
            obj.TagInfo = TirfAnalysis.Display.Tagger.TagInformation(...
                obj.MovieResults);
        end
        
        % @Override from DisplayModel
        function success = loadAnalysis(obj)
            success = 0;
            % load the original file
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
                obj.MovieLoaded = 1;
                
                % if it is a single file loaded, then we can check if it has
                % already been tagged
                if ~iscell(file) && isfield(loadFile,'tagInfo')
                    % if already tagged, just load it
                    obj.TagInfo = loadFile.tagInfo;
                else
                    % otherwise create a blank one
                    obj.TagInfo = TirfAnalysis.Display.Tagger.TagInformation(...
                        obj.MovieResults);
                end
            end
            
            if obj.MovieLoaded
                notify(obj,'DisplayNeedsUpdate');
            end
            
        end
        
        function success = saveAnalysis(obj)
            success = 0;
            [file, path] = ...
                uiputfile(obj.COMPILED_FILE,'Save Compiled Files','');
            if ~isempty(file) && all(file~=0)
                
                % cut the extension just to eg: '.fitsCompiled'
                strippedExtension = obj.COMPILED_FILE(2:end-4);
                
                multipleExtensions = ...
                    strfind(file,strippedExtension);
                
                if numel(multipleExtensions) > 1
                    for ext = (numel(multipleExtensions) - 1):-1:1
                        % remove the duplicates
                        file(...
                            multipleExtensions(ext):...
                            multipleExtensions(ext) + ...
                            numel(strippedExtension) - 1) = [];
                    end
                end
                
                savePath = fullfile(path,file);
                movieResult = obj.MovieResults;
                % also save the tag information
                tagInfo = obj.TagInfo;
                save(savePath,'movieResult','tagInfo','-v7.3');
                % save in a R2006b or later format '-v7.3';
                success = 1;
            end
        end
        
        % getters for the tagging
        function tagNames = getTagNames(obj)
            tagNames = obj.TagInfo.getTagNames;
        end
        
        function tagValues = getTagValues(obj)
            tagValues = obj.TagInfo.getTagValue(obj.CurrentParticle);
        end
        
        % setters for the tagging
        function setTagNames(obj,tagNames)
            obj.TagInfo.setTagDescs(tagNames);
            if obj.MovieLoaded
                notify(obj,'DisplayNeedsUpdate');
            end
        end
        
        function setTagValue(obj,tags)
            obj.TagInfo.setTagValue(obj.CurrentParticle,tags);
            if obj.MovieLoaded
                notify(obj,'DisplayNeedsUpdate');
            end
        end
    end
end
