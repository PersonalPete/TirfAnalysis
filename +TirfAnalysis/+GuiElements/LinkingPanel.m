classdef LinkingPanel < TirfAnalysis.GuiElements.AbstractPanel
    % methods
    %
    % [linkRad, nearNeighRad, minEllip, minWid, maxWid]...
    %           = getLinkingInfo
    %
    % setLinkingInfo(obj,...
    %       linkRad, nearNeighRad, minEllip, minWid, maxWid)
    %
    
    properties (Access = protected)
        LinkRadH
        NearNeighH
        MinEllipH
        MinWidH
        MaxWidH
        
        FunEditH
        
        COL_EDT_BGD = [0.62 0.71 0.80]
        COL_EDT_TXT = [0.20 0.20 0.20]
        
        EDT_TXT_HEIGHT = 0.6
        
    end
    
    methods (Access = public)
        % constructor
        function obj = LinkingPanel(figH,position,callback)
            
            if nargin < 3
                callback = '';
            end
            
            % call superclass constructor
            obj = ...
                obj@TirfAnalysis.GuiElements.AbstractPanel(figH,position);
            
            % add the title
            obj.addTitle('LINK/FILTER');
            
            % add the edit boxes
            obj.LinkRadH = ...
                obj.addOption(1,{'linking radius'},callback);
            obj.NearNeighH = ...
                obj.addOption(2,{'neighbour limit radius'},callback);
            obj.MinEllipH = ...
                obj.addOption(3,{'min axis ratio'},callback);
            obj.MinWidH = ...
                obj.addOption(4,{'min width'},callback);
            obj.MaxWidH = ...
                obj.addOption(5,{'max width'},callback);
            
            obj.FunEditH = ...
                obj.addFunEditBox(6,callback);
            
        end
        
        % getter for the current information in the panel
        function [linkRad, nearNeighRad, minEllip, minWid, maxWid, fun]...
                = getLinkingInfo(obj)
            linkRad = obj.LinkRadH.getValue;
            nearNeighRad = obj.NearNeighH.getValue;
            minEllip = obj.MinEllipH.getValue;
            minWid = obj.MinWidH.getValue;
            maxWid = obj.MaxWidH.getValue;
            fun = obj.getFun;
        end
        
        function setLinkingInfo(obj,...
                linkRad, nearNeighRad, minEllip, minWid, maxWid,fun)
            obj.LinkRadH.setValue(linkRad);
            obj.NearNeighH.setValue(nearNeighRad);
            obj.MinEllipH.setValue(minEllip);
            obj.MinWidH.setValue(minWid);
            obj.MaxWidH.setValue(maxWid);
            obj.setFun(fun)
        end
        
        function setFun(obj,fun)
            % fun is a function handle we need to translate to a string so
            % we can display it to the user
            
            string = func2str(fun);
            string = upper(string(21:end));
            
            set(obj.FunEditH,'String',string);
            
        end
        
        function fun = getFun(obj)
            % this returns the user specified linking function
            
            funString = get(obj.FunEditH,'String');
            funString = upper(funString);
            
            funString = ['@(DD,DT,DA,TT,TA,AA) ' funString];
            
            try
                % if the user specified function isn't ok
                fun = str2func(funString);
            catch
                % linking is set to none
                fun = @(DD,DT,DA,TT,TA,AA) 0;
            end
        end
        
    end
    
    methods (Access = protected)
        function funEdit = addFunEditBox(obj,posNo,callback)
            
            pos = [...
                obj.XMin,...
                obj.YMin + (obj.N_ROW - 1 - posNo) * obj.Space,...
                obj.XWid,...
                obj.Height];
            
            funEdit = uicontrol('Style','Edit',...
                'Parent',obj.FigH,...
                'Units','Normalized',...
                'FontUnits','Normalized',...
                'Position',pos,...
                'FontSize',obj.EDT_TXT_HEIGHT,...
                'BackgroundColor',obj.COL_EDT_BGD,...
                'ForegroundColor',obj.COL_EDT_TXT,...
                'Callback',callback);
            
            
        end
    end
end