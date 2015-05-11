classdef TagInformation < handle
    % class that wraps the primitive information tags for all particles in
    % a movieResult
    properties (Access = protected)
        TagFieldNames % a cell array of strings
        TagData % Nparticles x Ntags logical array
    end
    
    properties (Access = private, Constant)
        DFT_NUM_TAGS = 3
        DFT_TAG_NAME = {'','',''}
    end
    
    methods (Access = public)
        % constructor
        function obj = TagInformation(movieResults,descriptions)
            if nargin < 1
                numParticles = 1;
            else
                numParticles = movieResults.getNumParticles();
            end
            if nargin < 2
                descriptions = obj.DFT_TAG_NAME;
                numTags = obj.DFT_NUM_TAGS;
            else
                numTags = numel(descriptions);
            end 
            obj.TagData = zeros(numParticles,numTags);
            obj.setTagDescs(descriptions);
         end
        
        % set tag values for a particular particle
        function setTagValue(obj,particleNo,tags)
            % check we have been given something with a sensible size
            if particleNo <= size(obj.TagData,1) && ...
                    all(size(tags) == [1, size(obj.TagData,2)])
                % set this particular particles tags
                obj.TagData(particleNo,:) = tags;
            else
                warning('Invalid particle number, or number of tags');
            end
        end
        
        % adjust number of tags and their names
        function setTagDescs(obj,descriptions)
            % descriptions is a cell array of strings, one for each tag
            obj.TagFieldNames = descriptions;
            
            % resize the tag data - deleting data if we are reducing the
            % number of tags
            oldNumTags = size(obj.TagData,2);
            newNumTags = numel(descriptions);
            
            if oldNumTags > newNumTags
                obj.TagData = obj.TagData(:,1:newNumTags);
            elseif oldNumTags < newNumTags
                obj.TagData = ...
                    [obj.TagData,...
                    zeros(size(obj.TagData,1),newNumTags - oldNumTags)];
            end
        end
        
        % getters
        function tagData = getTagData(obj)
            tagData = obj.TagData;
        end
        
        function tagDescriptions = getTagNames(obj,tagNo)
            if nargin < 2;
                tagDescriptions = obj.TagFieldNames;
            else
                tagDescriptions = obj.TagFieldNames{tagNo};
            end
        end
        
        % getter for a particlar tag/particle combination
        function tagValue = getTagValue(obj,particleNo,tagNo)
            % if only the particle number is given, return all tags
            if nargin < 3
                if particleNo > size(obj.TagData,1)
                    tagValue = zeros(1,numel(obj.TagFieldNames));
                    warning('Particle not found, returning FALSE');
                else
                    tagValue = obj.TagData(particleNo,:);
                end
            else
                % convert a string to a index
                if ischar(tagNo)
                    tagNo = find(strcmp(tagNo,obj.TagFieldNames),1,'first');
                end
                if isempty(tagNo) || tagNo > numel(obj.TagFieldNames) || ...
                        particleNo > size(obj.TagData,1)
                    tagValue = 0;
                    warning('Particle or tag not found, returning FALSE')
                else
                    tagValue = obj.TagData(particleNo,tagNo);
                end
            end
        end
    end
end
            