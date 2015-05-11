classdef ImageExportButton < handle
    properties (Access = protected)
        FigH
        
        ExportButton
    end
    
    properties (Access = protected, Constant)
        EXTENSIONS = {'*.eps';'*.png'}
        
        DFT_BUT_COL = [0.24 0.35 0.67]
        DFT_BUT_TXT = [1 1 1]
        
        TXT_HEIGHT = 0.4
    end
    
    methods (Access = public)
        % constructor
        function obj = ImageExportButton(figH,pos)
            if nargin > 1
            obj.FigH = figH;
            obj.ExportButton = obj.buildButton(pos,'Export',...
                @(~,~) obj.saveFunction);
            end
        end
        
        % destructore
        function delete(obj)
            if ishandle(obj.ExportButton)
                delete(obj.ExportButton)
            end
        end
    end
    
    methods (Access = protected)
        % build the button
        function buttonH = buildButton(obj,pos,string,callback)
            buttonH = uicontrol('Style','pushbutton',...
                'Callback',callback,...
                'FontUnits','Normalized',...
                'Units','Normalized',...
                'Position',pos,...
                'BackgroundColor',obj.DFT_BUT_COL,...
                'ForegroundColor',obj.DFT_BUT_TXT,...
                'FontSize',obj.TXT_HEIGHT,...
                'String',string);
        end
        
        % callback for saving
        function saveFunction(obj)
            [file, path, filterspec] = uiputfile(obj.EXTENSIONS,'Export Figure');
            
            if ~isempty(file) && ~all(file == 0) && filterspec ~= 3 
                savePath = fullfile(path,file);
                % set the colormap to defaut
%                 cmap = get(obj.FigH,'colormap');
%                 set(obj.FigH,'colormap','default');
                % save the figure
                saveas(obj.FigH,savePath,'epsc');
                % reset the colormap
%                 set(obj.FigH,'colormap',cmap);
            end
        end
    end
        
        
end