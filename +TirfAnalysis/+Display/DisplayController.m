classdef DisplayController < handle
    properties (Access = protected)
        Model
        View
        UpdateListener
    end
    
    methods (Access = public)
        % constructor
        function obj = DisplayController()
            % build the model
            obj.Model = TirfAnalysis.Display.DisplayModel();
            
            % make the callbacks
            callbacks{1} = @(~,~) obj.Model.nextParticle;
            callbacks{2} = @(~,~) obj.Model.previousParticle;
            
            callbacks{3} = @(partNo) obj.Model.specificParticle(partNo);
            
            callbacks{4} = @(~,~) obj.Model.loadAnalysis;
            callbacks{5} = @(~,~) obj.Model.saveAnalysis;
            
            obj.View = TirfAnalysis.Display.DisplayView(obj,callbacks);
            
            obj.UpdateListener = addlistener(obj.Model,...
                'DisplayNeedsUpdate',@(~,~) obj.updateDisplayToMatchModel);
            
        end
    
        
        
        function delete(obj)
            if isvalid(obj.Model)
                delete(obj.Model)
            end
            
            if ishandle(obj.UpdateListener)
                delete(obj.UpdateListener);
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
        end
    end
end