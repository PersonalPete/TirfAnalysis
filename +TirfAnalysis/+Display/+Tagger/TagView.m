classdef TagView < TirfAnalysis.Display.DisplayView
    
    properties (Access = protected)
        TagFigH
    end
    
    
    methods (Access = public)
        % constructor
        function obj = TagView(controller,callbacks)
            % call superclass constructor
            obj = obj@TirfAnalysis.Display.DisplayView(controller,...
                callbacks);
            % hookup the close function to this classes destructor
            set(obj.FigH,'CloseRequestFcn',@(~,~) obj.delete);
            
            % add the tag button figure panel
            tagsChanged = callbacks{6}; % this callback needs to accept 
                                        % two arguments, tagNames and 
                                        % tagValues
            
            obj.TagFigH = ...
                TirfAnalysis.Display.Tagger.TagPanel(tagsChanged);
            
        end
        
        % for updating the tag display to match the model
        function updateTagDisplay(obj,tagNames,currentTagValues)
            obj.TagFigH.setTagDisplay(tagNames,currentTagValues);
        end
        
        % destructor
        function delete(obj)
            if isvalid(obj.TagFigH)
                delete(obj.TagFigH);
            end
        end
        
    end
    
end