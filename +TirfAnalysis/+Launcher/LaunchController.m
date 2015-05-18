classdef (Sealed) LaunchController < handle
    properties (Access = private)
        View
        
        
        RegCon
        AnaCon
        ViwCon
    end
    
    methods (Access = private)
        % private constructor
        function obj = LaunchController
            callbacks{1} = @(~,~) obj.launchRegCon; % registration
            callbacks{2} = @(~,~) obj.launchAnaCon; % analysis
            callbacks{3} = @(~,~) obj.launchViwCon; % viewer
            
            % build the view
            obj.View = TirfAnalysis.Launcher.LaunchView(obj,callbacks);
        end
        
        % launchers for the other GUIs
        function launchRegCon(obj)
            if isempty(obj.RegCon) || ~isvalid(obj.RegCon)
                obj.RegCon = TirfAnalysis.Reg.RegController;
            end
        end
        function launchAnaCon(obj)
            if isempty(obj.AnaCon) || ~isvalid(obj.AnaCon)
                obj.AnaCon = TirfAnalysis.Main.MainController;
            end
        end
        function launchViwCon(obj)
            if isempty(obj.ViwCon) || ~isvalid(obj.ViwCon)
                % obj.ViwCon = TirfAnalysis.Display.DisplayController;
                obj.ViwCon = TirfAnalysis.Display.Tagger.TagController;
            end
        end
        
        % make the window visible and active
        function setVisible(obj)
            obj.View.setVisible;
        end
        
    end
    
    methods (Access = public)
        function delete(~)
            % don't delete the other controllers, since they are deleted by
            % pushing the x in the corner of each of their views
        end
    end
    
    methods (Static, Access = public)
        function singleController = getInstance
            persistent localLaunchController
            % if it doesn't already exist
            if isempty(localLaunchController) || ...
                    ~isvalid(localLaunchController)
                localLaunchController = ...
                    TirfAnalysis.Launcher.LaunchController();
            end
            singleController = localLaunchController;
            % make sure it is in an obvious position
            localLaunchController.setVisible;
        end
    end
end