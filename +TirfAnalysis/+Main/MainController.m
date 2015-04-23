classdef MainController < handle
    properties (SetAccess = protected)
        Model
        View
        ModelSettingsChangedListener
        RunningStatusListener
    end
    
    methods (Access = public)
        % constructor
        function obj = MainController()
            % make the model
            obj.Model = TirfAnalysis.Main.MainModel();
            
            % make the view
            
            % set the callbacks (i.e. what to call when user interacts with
            % gui)
            
            % loadTransform
            callbacks{1} = @(~,~)obj.Model.loadTransform; 
            % loadMovie
            callbacks{2} = @(~,~)obj.loadMovieWrapper;
            % inputChanged (i.e. what to call when  edit box value changes)
            callbacks{3} = @(~,~)obj.viewSettingsChanged; 
            % updateDisplay (button pushed)
            callbacks{4} = @(~,~)obj.updateViewImages;
            % run model
            callbacks{5} = @(~,~)obj.runModelWrapper;
            % load settings
            callbacks{6} = @(~,~)obj.Model.loadSettings;
            % save settings
            callbacks{7} = @(~,~)obj.Model.saveCurrentSettings;
            % update job status
            callbacks{8} = @(~,~)obj.Model.checkJobStatus;
            
            
            % call the view constructor
            obj.View = TirfAnalysis.Main.MainView(obj,callbacks);
            
            % make the listener for model setting changes
            obj.ModelSettingsChangedListener = ...
                event.listener(obj.Model,'ViewNeedsUpdate',...
                @(~,~)obj.updateDisplaySettings);
            
            
            obj.RunningStatusListener = ...
                event.listener(obj.Model,'JobStatusChanged',...
                @(~,~)obj.updateRunStatus);
            
            % initialise the view
            obj.updateDisplaySettings;
            
        end
        
        function runModelWrapper(obj)
            obj.View.updateStatus(-2)
            success = obj.Model.runAnalysis;
            if success
                obj.View.updateStatus(1); % done
            else
                obj.View.updateStatus(-1); % configure
            end
        end
        
        function loadMovieWrapper(obj)
            obj.View.updateStatus(-2); % busy
            obj.Model.loadDisplayMovie;
            obj.View.updateStatus(0); % done
        end
       
        function updateViewImages(obj)
            obj.View.updateStatus(-2); % busy
            [success, analysisMovie] = obj.Model.generateLinkMovie;            
            if success
                obj.View.setDisplayImage(analysisMovie);
            else
                % what to do if we can't produce an analysisMovie
                % i.e. maybe we haven't loaded a movie or Tform yet
                obj.View.updateStatus(-1); % configure
            end
            obj.View.updateStatus(1);
        end
        
        function updateDisplaySettings(obj)
            % function that updates the displayed settings to match the
            % model's current state
            obj.View.updateStatus(-2); % busy
            obj.View.setDisplaySettings(obj.Model.getAnalysisSettings);
            obj.View.updateStatus(0);
        end
        
        function updateRunStatus(obj)
            [nPend,nRun,nFin,nFail] ...
                = obj.Model.getJobStatus;
            obj.View.setRunningStatus(nPend,nRun,nFin,nFail);
        end
        
        function viewSettingsChanged(obj)
            [nFrames,kernel,radFac,greThresh,redThresh,nirThresh,...
                linkRad,nearNeighRad,minEllip,minWid,maxWid,linkFun,...
                isFixPos,isFixWid,isEllip,maxPosChange,minFitWid,...
                maxFitWid,windowRad] = ...
                obj.View.getDisplaySettings;
                
                % detection
                obj.Model.setDetectionParameters(...
                    nFrames,kernel,[greThresh,redThresh,nirThresh],radFac);
                % linking
                obj.Model.setLinkingRadius(linkRad);
                obj.Model.setFiltering(...
                    minEllip,[minWid,maxWid],nearNeighRad);
                obj.Model.setChannelLinking(linkFun);
                % algorithm
                obj.Model.setAlgorithm(isFixPos,isFixWid,isEllip);
                obj.Model.setAlgorithmLimits(...
                    maxPosChange,[minFitWid,maxFitWid]);          
                obj.Model.setWindowRad(windowRad);
        end
        
        function delete(obj)
            delete(obj.Model);
        end
    end
    
end