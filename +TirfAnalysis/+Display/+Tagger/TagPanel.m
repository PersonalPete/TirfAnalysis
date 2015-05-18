classdef TagPanel < handle
    properties (Access = protected)
        FigH
        TagEdits
        TagToggles
        NumTags
        
        Listeners
        
        AddButton
        DeleteButton
        
        UpdateCallback
    end
    
    properties (Access = private, Constant)
        
        DFT_NUM_TAGS = 2
        MAX_NUM_TAGS = 7
        
        COL_EDT_BGD = [0.62 0.71 0.80]
        COL_EDT_TXT = [0.20 0.20 0.20]
        
        DFT_COL_BGD = [0.6 0.6 0.6]
        
        COL_BUT_BGD = [0.24 0.35 0.67]
        COL_BUT_TXT = [1 1 1]
        
        COL_BUT_ACT = [1 1 1]
        
        TXT_HEIGHT = 0.5
        
        FIG_POS = [0.25 0.3 0.3 0.4]
        
        ADD_POS = [0.1 0.8 0.4 0.1]
        DEL_POS = [0.5 0.8 0.4 0.1]
        
        TOG_X_START = 0.1
        TOG_Y_END = 0.8
        TOG_X_END = 0.9
        TOG_HEIGHT = 0.1
        TOG_SPAC = 0.01
        
        
    end
    
    methods  (Access = public)
        % constructor
        function obj = TagPanel(callback)
            if nargin < 1
                callback = '';
            end
            obj.UpdateCallback = callback;
            
            obj.FigH = figure('CloseRequestFcn','',...
                'Color',obj.DFT_COL_BGD,...
                'Colormap',gray(1e2),...
                'DockControls','off',...
                'Name','Trajectory Tagger',...
                'Units','Normalized',...
                'OuterPosition',obj.FIG_POS,...
                'Defaultuicontrolunits','Normalized',...
                'Defaultuicontrolfontunits','Normalized',...
                'DefaultuicontrolFontSize',obj.TXT_HEIGHT,...
                'Toolbar','none',...
                'Menubar','none',...
                'WindowStyle','normal',...
                'Visible','on',...
                'DefaultAxesHandleVisibility','Callback');
            
            % build the buttons for adding or removing a tag
            obj.NumTags = 0;
            
            for iTag = 1:obj.DFT_NUM_TAGS
                obj.addTag;
            end
            
            obj.AddButton = obj.buildButton(obj.ADD_POS,...
                'Add',@obj.addTagRequested);
            obj.DeleteButton = obj.buildButton(obj.DEL_POS,...
                'Remove',@obj.delTagRequested);
            
            set(obj.FigH,'HandleVisibility','callback');
        end
        
        % set the tag display to match the model
        function setTagDisplay(obj,tagNames,currentTagValues)
            if numel(tagNames) ~= numel(currentTagValues)
                warning('Tag name and value mismatch')
            else
                numTagsNeeded = numel(tagNames);
                if numTagsNeeded < obj.NumTags;
                    % remove tags if we have too many
                    numToRemove = obj.NumTags - numTagsNeeded;
                    for iTagRemove = 1:numToRemove
                        obj.delTag;
                    end
                elseif numTagsNeeded > obj.NumTags;
                    % add tags if we have too few
                    numNeeded = numTagsNeeded - obj.NumTags;
                    for iTagNeeded = 1:numNeeded
                        obj.addTag
                    end
                end
                obj.setTagNames(tagNames);
                obj.setTagValues(currentTagValues);
            end
        end
        
        % destructor
        function delete(obj)
            if ishandle(obj.FigH)
                delete(obj.FigH)
            end
            
            for iTag = 1:numel(obj.Listeners)
                if ishandle(obj.Listeners(iTag));
                    delete(obj.Listeners(iTag));
                end
            end
            
        end
    end
    
    % methods for making the buttons and utility methods for updating
    % displayed data
    methods (Access = protected)
        function buttonH = buildButton(obj,pos,string,callback)
            buttonH = uicontrol('parent',obj.FigH,...
                'Style','pushbutton',...
                'Callback',callback,...
                'Position',pos,...
                'BackgroundColor',obj.COL_BUT_BGD,...
                'ForegroundColor',obj.COL_BUT_TXT,...
                'FontSize',obj.TXT_HEIGHT,...
                'String',string);
        end
        
        function toggleH = buildToggle(obj,pos,string,callback)
            toggleH = uicontrol('parent',obj.FigH,...
                'Style','togglebutton',...
                'Callback',callback,...
                'Position',pos,...
                'BackgroundColor',obj.COL_BUT_BGD,...
                'ForegroundColor',obj.COL_BUT_TXT,...
                'FontSize',obj.TXT_HEIGHT,...
                'Min',0,...
                'Max',1,...
                'Value',0,...
                'String',string);
        end
        
        function editH = buildEdit(obj,pos,callback)
            editH = uicontrol('parent',obj.FigH,...
                'Style','Edit',...
                'Callback',callback,...
                'Position',pos,...
                'BackgroundColor',obj.COL_EDT_BGD,...
                'ForegroundColor',obj.COL_EDT_TXT,...
                'FontSize',obj.TXT_HEIGHT,...
                'String','');
        end
        
        % setting the displayed data (i.e. when loading a dataset, or when
        % changing particle
        function setTagNames(obj,tagNames)
            for iTag = 1:numel(tagNames)
                set(obj.TagEdits(iTag),'String',tagNames{iTag});
            end
        end
        
        function setTagValues(obj,tagValues)
            for iTag = 1:numel(tagValues)
                set(obj.TagToggles(iTag),'Value',tagValues(iTag)>0)
            end
        end
       
    end
    % callbacks
    methods (Access = private)
        % callbacks when asked to add or remove a tag
        function addTagRequested(obj,~,~)
            % add a tag
            obj.addTag;
            % call the notification callback
            obj.tagChanged;
        end
        
        function delTagRequested(obj,~,~)
            % remove a tag
            obj.delTag;
            % call the notification callback
            obj.tagChanged;
        end
        
        % callbacks to actually add or remove the tag
        function addTag(obj)
            if obj.NumTags < obj.MAX_NUM_TAGS
                obj.NumTags = obj.NumTags + 1;
                tagNo = obj.NumTags;
                stringPos = [obj.TOG_X_START, ...
                    obj.TOG_Y_END - obj.NumTags*obj.TOG_HEIGHT,...
                    0.5*(obj.TOG_X_END - obj.TOG_X_START),...
                    obj.TOG_HEIGHT - obj.TOG_SPAC];
                togglePos = [obj.TOG_X_START + ...
                    0.5*(obj.TOG_X_END - obj.TOG_X_START), ...
                    obj.TOG_Y_END - obj.NumTags*obj.TOG_HEIGHT,...
                    0.5*(obj.TOG_X_END - obj.TOG_X_START),...
                    obj.TOG_HEIGHT - obj.TOG_SPAC];
                
                obj.TagEdits(obj.NumTags) = ...
                    obj.buildEdit(stringPos,@(~,~)obj.tagChanged);
                obj.TagToggles(obj.NumTags) = ...
                    obj.buildToggle(togglePos,'',@(~,~)obj.tagChanged);
                if obj.NumTags == 1;
                    obj.Listeners = ...
                        addlistener(obj.TagToggles(obj.NumTags),...
                        'Value','PostSet',...
                        @(~,~)obj.toggleListenerCall(...
                        tagNo));
                else
                    obj.Listeners(obj.NumTags) = ...
                        addlistener(obj.TagToggles(obj.NumTags),...
                        'Value','PostSet',...
                        @(~,~)obj.toggleListenerCall(...
                        tagNo));
                end
            end
        end
        
        function delTag(obj)
            if obj.NumTags > 1
                obj.NumTags = obj.NumTags - 1;
                delete(obj.TagEdits(end));
                delete(obj.TagToggles(end));
                delete(obj.Listeners(end));
                obj.TagEdits(end) = [];
                obj.TagToggles(end) = [];
                obj.Listeners(end) = [];
            end
        end
        
        % callback for when the tag changes (name or value) or a new tag is
        % added
        function tagChanged(obj)
            % get the description strings
            descriptions = get(obj.TagEdits,'String');
            % get the toggle values
            tagValues = get(obj.TagToggles,'Value');
            % force them to be cell arrays
            if ~iscell(descriptions)
                descriptions = {descriptions};
                tagValues = {tagValues};
            end
            tagValues = cell2mat(tagValues);
            tagValues = tagValues(:)';
            obj.UpdateCallback(descriptions,tagValues);
        end
        
        % callback for the listener that changes the button color
        function toggleListenerCall(obj,tagNo)
            
            tagSrc = obj.TagToggles(tagNo);
            
            value = get(tagSrc,'Value');
            if value > 0
                set(tagSrc,'BackgroundColor',obj.COL_BUT_ACT);
            else
                set(tagSrc,'BackgroundColor',obj.COL_BUT_BGD);
            end
        end
    end
end