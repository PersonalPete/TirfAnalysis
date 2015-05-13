classdef TagController < handle
    % NB doesn't inherit from DisplayController...
    
    properties (Access = protected)
        Model
        View
        TagView
        UpdateListener
    end
    
    methods (Access = public)
        % constructor
        function obj = TagController
            % use the model that accepts the tagger here
            obj.Model = TirfAnalysis.Display.Tagger.TagModel();
            
            % make the callbacks
            callbacks{1} = @(~,~) obj.Model.nextParticle;
            callbacks{2} = @(~,~) obj.Model.previousParticle;
            
            callbacks{3} = @(partNo) obj.Model.specificParticle(partNo);
            
            callbacks{4} = @(~,~) obj.Model.loadAnalysis;
            callbacks{5} = @(~,~) obj.Model.saveAnalysis;
            
            % build the main window
            obj.View = TirfAnalysis.Display.DisplayView(obj,callbacks);
            
            % build the tagger window
            obj.TagView = ...
                TirfAnalysis.Display.Tagger.TagPanel(...
                @(tagNames,tagValues) ...
                obj.setTagModelToMatchDisplay(tagNames,tagValues));
            
            obj.UpdateListener = addlistener(obj.Model,...
                'DisplayNeedsUpdate',@(~,~) obj.updateDisplayToMatchModel);
        end
        
         function delete(obj)
            if isvalid(obj.Model)
                delete(obj.Model);
            end
            
            if ishandle(obj.UpdateListener)
                delete(obj.UpdateListener);
            end
             
            if isvalid(obj.TagView)
                delete(obj.TagView);
            end
        end
        
    end
    
    methods (Access = protected)
        % updater for the listener
        function updateDisplayToMatchModel(obj)
            obj.View.displayParticle(obj.Model.getCurrentParticle);
            obj.View.displayInfo(obj.Model.getCurrentFileName);
            obj.View.displayParticleNumber(...
                obj.Model.getCurrentParticleNumber);
            
            % the updater for the tag information
            obj.TagView.setTagDisplay(...
                obj.Model.getTagNames,obj.Model.getTagValues);
            
        end
        % set the tag information in the model
        function setTagModelToMatchDisplay(obj,tagNames,tagValues)
            obj.Model.setTagNames(tagNames);
            obj.Model.setTagValue(tagValues);
        end
    end
end