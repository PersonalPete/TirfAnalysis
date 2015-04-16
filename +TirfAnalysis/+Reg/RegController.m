classdef RegController < handle
    properties (Access = protected)
        Model
        View
        Listener
    end
    
    methods (Access = public)
        function obj = RegController()
            % constructor
            % make the model
            obj.Model = TirfAnalysis.Reg.RegModel();
            
            % make the view
            % set the callbacks
            callbacks{1} = @obj.loadFits;
            callbacks{2} = @obj.setLimits;
            callbacks{3} = @obj.runModel;
            callbacks{4} = @obj.saveTform;
            % create the view
            obj.View = TirfAnalysis.Reg.RegView(obj,callbacks);
            
            % update the view to match the model
            obj.updateViewToModel;
            obj.View.updateStatus(-1); % configure
            
            obj.Listener = event.listener(obj.Model,'TransformNeedsUpdating',...
                @obj.updateViewToModel);
        end
        function loadFits(obj,~,~)
            % for the load button on the view
            [file,path] = uigetfile('*.fits;*.FITS','Load Calibration Movie');
            if ~isempty(file) && all(file~=0)
                loadPath = fullfile(path,file);
                success = obj.Model.loadMovie(loadPath);
                if ~success                    
                    obj.View.updateStatus(-1);
                end
            end
        end
        
        function setLimits(obj,~,~)
            % callback for when the limits change on the view
            [greenLim, redLim, nirLim] = obj.View.getImLim;
            obj.Model.setLimits(greenLim,redLim,nirLim);
        end
        
        function runModel(obj,~,~)
            % once the inputs are ready, then run the model
            obj.View.updateStatus(-2); drawnow;% busy
            [success, tform, positionsInRed] = ...
                obj.Model.calculateTransform;
            
            if success
                obj.View.updateStatus(1); % done
                obj.View.updateTformHists(tform, positionsInRed)
            else
                obj.View.updateStatus(-1); % configure
            end
        end
        
        function saveTform(obj,~,~)
            % save the 3 color transform
            [file, path] = uiputfile('*.tform3.mat','Save Transform','');
            if ~isempty(file) && all(file~=0)
                savePath = fullfile(path,file);
                success = obj.Model.saveTransform(savePath);
                if ~success
                    obj.View.updateStatus(-1);
                end
            end
        end
        
        function updateViewToModel(obj,~,~)
            % function for the listener
            % if the model parameters change, then update the view to match
            % them
            [greenF, redF, nirF, greenLim, redLim, nirLim] = ...
                obj.Model.getInfo;
            obj.View.updateIm(greenF, redF, nirF, greenLim, redLim, nirLim);
            obj.View.updateStatus(0); % set the view to 'ready'
        end
            
            
        function delete(obj)
            % just to make sure everything gets deleted
            try
                delete(obj.Listener);
            catch
                fprintf('\nError deleting RegController listener\n');
            end
        end
    end
end
            
            
            
            
            
            