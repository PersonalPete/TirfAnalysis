classdef ParticleFrameDisplay < handle
    properties(Access = protected)
        FigH
        ImageDisplays
        ImageDescriptions
        
        ForwardH
        BackH
        
        FastForwardH
        FastBackH
        
        LowerLimH
        UpperLimH
        
        DisplayTime
        
        % the info currently display(able) in the images
        CurrentData
        ChannelLengths
        CurrentFrame
        DisplayTimes
    end
    
    events
        DisplayFrameChanged
    end
    
    properties (Access = protected, Constant)
        NUM_IM = 6
        NUM_BUT = 4
        
        FRAC_BUTTON = 0.5
        
        FRAC_DESC = 0.1
        
        TXT_SIZE = 0.6
        
        ID_TXT_SIZE = 0.8
        
        DFT_BUT_COL = [0.24 0.35 0.67]
        DFT_BUT_TXT = [1 1 1]
        
        COL_STR_TXT = [1.0 1.0 1.0]
        
        COL_EDT_BGD = [0.62 0.71 0.80]
        COL_EDT_TXT = [0.20 0.20 0.20]
        
        DESC = {...
            'DD',...
            'DT',...
            'DA',...
            'TT',...
            'TA',...
            'AA'}
        
        DESC_COL = {...
            [0.0 0.9 0.0],...
            [0.9 0.7 0.0],...
            [0.0 0.4 0.0],...
            [0.9 0.0 0.0],...
            [0.4 0.0 0.0],...
            [0.8 0.8 0.5]}
        
        DFT_CLIM = [100 150]
      
        FAST_FRAME_SCROLL = 30
        
        REPEAT_PAUSE = 0.1
    end
    
    methods (Access = public)
        % constructor
        function obj = ParticleFrameDisplay(figH,pos)
            
            
            posDisplays = pos;
            obj.FigH = figH;
            
            % build the image display objects
            posStep = posDisplays(4)/(obj.NUM_IM + obj.FRAC_BUTTON);
            posButStep = posStep*obj.FRAC_BUTTON;
            posDisplays(2) = posDisplays(2) + posButStep;
            
            % count backwards for the sake of memory allocation
            for iImage = obj.NUM_IM:-1:1
                posIm = [posDisplays(1),...
                    (posDisplays(2)+(iImage-1)*posStep), posDisplays(3),...
                    posStep*(1-obj.FRAC_DESC)];
                
                posDesc = posIm;
                posDesc(2) = posDesc(2) + posStep*(1-obj.FRAC_DESC);
                posDesc(4) = posStep*obj.FRAC_DESC;
                
                imageDisplays(iImage) = ...
                    TirfAnalysis.GuiElements.ImageDisplayNoScaling(...
                    figH,posIm);
                
                imageDesc(iImage) = ...
                    obj.makeDesc(posDesc,...
                    obj.DESC{obj.NUM_IM - iImage + 1},...
                    obj.DESC_COL{obj.NUM_IM - iImage + 1});
                    
                imageDisplays(iImage).setColorLim(...
                    obj.DFT_CLIM(1),obj.DFT_CLIM(2));
            end
            
            obj.ImageDisplays = imageDisplays;
            obj.ImageDescriptions = imageDesc;
            
            % make the buttons for changing the displayed time
            
            butStepX = pos(3)/obj.NUM_BUT;
            
            posFastBack = [pos(1) + 0*butStepX, pos(2) + posButStep/2,...
                butStepX, posButStep/2];
            posBack = [pos(1) + 1*butStepX, pos(2) + posButStep/2,...
                butStepX, posButStep/2];
            posForward = [pos(1) + 2*butStepX, pos(2) + posButStep/2,...
                butStepX, posButStep/2];
            posFastForward = [pos(1) + 3*butStepX, pos(2) + posButStep/2,...
                butStepX, posButStep/2];
            
            obj.ForwardH = obj.addButton(posForward,'>',...
                @(src,~) obj.changeFrame(src,1));
            obj.BackH = obj.addButton(posBack,'<',...
                @(src,~) obj.changeFrame(src,-1));
            obj.FastForwardH = obj.addButton(posFastForward,'>>',...
                @(src,~) obj.changeFrame(src,obj.FAST_FRAME_SCROLL));
            obj.FastBackH = obj.addButton(posFastBack,'<<',...
                @(src,~) obj.changeFrame(src,-obj.FAST_FRAME_SCROLL));
            
            % make the controls for changing the image limits
            
            posLower = [pos(1) + 0*butStepX, pos(2),...
                4*butStepX/3, posButStep/2];
            posUpper = [pos(1) + (8/3)*butStepX, pos(2),...
                4*butStepX/3, posButStep/2];
            
            obj.LowerLimH = obj.addEdit(posLower,@(~,~) obj.updateClim);
            set(obj.LowerLimH,'string',sprintf('%i',obj.DFT_CLIM(1)));
            obj.UpperLimH = obj.addEdit(posUpper,@(~,~) obj.updateClim);
            set(obj.UpperLimH,'string',sprintf('%i',obj.DFT_CLIM(2)));
            
            posTime = [pos(1) + (4/3)*butStepX, pos(2),...
                4*butStepX/3, posButStep/3];
            
            obj.DisplayTime = obj.addText(posTime);            
        end
        
        % put a new particle's data in the displays
        function setData(obj,particle)
            currentData = {...
                particle.getDdImageData;...
                particle.getDtImageData;...
                particle.getDaImageData;...
                particle.getTtImageData;...
                particle.getTaImageData;...
                particle.getAaImageData};
                
            timeFcns = {@particle.getGreenFrameTime,...
                @particle.getGreenFrameTime,...
                @particle.getGreenFrameTime,...
                @particle.getRedFrameTime,...
                @particle.getRedFrameTime,...
                @particle.getNirFrameTime};
            
            % work out the number of frames in each channel
            channelTimes = cell(size(currentData));
            channelLengths = zeros(size(currentData));
            for iData = 1:numel(currentData)
                timeFcn = timeFcns{iData};
                channelTimes{iData} = timeFcn();
                channelLengths(iData) = size(currentData{iData},3);
            end
            
            [~, longestChannel] = max(channelLengths);

            displayTimes = channelTimes{longestChannel};

            obj.CurrentData = currentData;
            obj.ChannelLengths = channelLengths;
            obj.CurrentFrame = 2;
            obj.DisplayTimes = displayTimes;
            
            % update the displays
            obj.updateDisplay;
        end
        
        % checking what frame time is shown on the displays
        function currentFrameTime = getDisplayFrameTime(obj)
            currentFrameTime = obj.DisplayTimes(obj.CurrentFrame);
        end
        
    end
    
    methods (Access = protected)
        % add a button to the gui
        function buttonH = addButton(obj,pos,string,callback)
            buttonH = uicontrol('parent',obj.FigH,...
                'style','pushbutton',...
                'units','normalized',...
                'position',pos,...
                'FontUnits','normalized',...
                'FontSize',obj.TXT_SIZE,...
                'BackgroundColor',obj.DFT_BUT_COL,...
                'ForegroundColor',obj.DFT_BUT_TXT,...
                'String',string,...
                'Callback',callback,...
                'Min',0,...
                'Max',1);
        end
        % add an edit handle
        function editH = addEdit(obj,pos,callback)
            editH = uicontrol('Parent',obj.FigH,...
                'style','edit',...
                'Units','normalized',...
                'position',pos,...
                'fontunits','normalized',...
                'fontsize',obj.TXT_SIZE,...
                'string','',...
                'BackgroundColor',obj.COL_EDT_BGD,...
                'ForegroundColor',obj.COL_EDT_TXT,...
                'callback',callback);
        end
        
        % add a string
        function textH = addText(obj,pos)
            textH = uicontrol('Style','Text',...
                'Parent',obj.FigH,...
                'String','',...
                'Units','Normalized',...
                'Position',pos,...
                'BackgroundColor',get(obj.FigH,'Color'),...
                'ForegroundColor',obj.COL_STR_TXT,...
                'FontUnits','Normalized',...
                'FontSize',obj.TXT_SIZE * (2/3),...
                'Visible','on');      
        end
        
        % build the channel description
        function descH = makeDesc(obj,pos,string,color)
            descH = uicontrol('Style','Text',...
                'Parent',obj.FigH,...
                'String',string,...
                'Units','Normalized',...
                'Position',pos,...
                'BackgroundColor',color,...
                'ForegroundColor',obj.COL_STR_TXT,...
                'FontUnits','Normalized',...
                'FontSize',obj.ID_TXT_SIZE,...
                'Visible','on');        
        end

        % for updating the displayed color limits
        function updateClim(obj)
            upperLim = str2double(get(obj.UpperLimH,'String'));
            lowerLim = str2double(get(obj.LowerLimH,'String'));
            
            if ~(isnan(upperLim) || isnan(lowerLim)) && upperLim > lowerLim
                for iIm = 1:obj.NUM_IM
                    obj.ImageDisplays(iIm).setColorLim(lowerLim,upperLim);
                end
            end
        end
        
        function changeFrame(obj,~,numFrames)
            maxFrame = numel(obj.DisplayTimes);
            
            newFrame = obj.CurrentFrame + numFrames;
            
            % make sure it is between 1 and maxFrame
            newFrame = max(newFrame,1);
            newFrame = min(newFrame,maxFrame);
            
            obj.CurrentFrame = newFrame;
            
            obj.updateDisplay;
            
        end
        
        % update the time display string
        function updateTimeDisplay(obj)
            time = obj.DisplayTimes(obj.CurrentFrame);
            set(obj.DisplayTime,'string',sprintf('%.2f s',time));
        end
        
        % update the displayed data (i.e. the frame displayed changed)
        function updateDisplay(obj)
            currentFrame = obj.CurrentFrame;
            for iChannel = 1:obj.NUM_IM
                channelData = obj.CurrentData{iChannel};
                imageDisplay = obj.ImageDisplays(obj.NUM_IM - iChannel + 1);
                if isempty(channelData)
                    imageDisplay.setImData([]);
                else
                    channelFrame = max(currentFrame,1);
                    channelFrame = ...
                        min(channelFrame,obj.ChannelLengths(iChannel));
                    imageDisplay.setImData(channelData(:,:,channelFrame));
                end
                
            end
            
            obj.updateTimeDisplay;
            
            obj.updateClim;
            notify(obj,'DisplayFrameChanged');
        end
        
    end
end