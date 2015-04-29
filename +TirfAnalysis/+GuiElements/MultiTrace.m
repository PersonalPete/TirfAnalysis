classdef MultiTrace < handle
    properties (Access = protected)
        
        FigH
        
        IntenTrace
        FretTrace
        FiwTrace
        PosTrace
        
        LimitListeners
        
        OriginalLimX = [0 1]
    end
    
    properties (Access = protected, Constant)
        POS_AVG = 10
    end
    
    methods (Access = public)
        % constructor
        function obj = MultiTrace(figH,pos)

            obj.FigH = figH;
            
            posStep = pos(4)/4;
            
            intenPos = [pos(1), pos(2) + 3*posStep, pos(3), posStep];
            fretPos = [pos(1), pos(2) + 2*posStep, pos(3), posStep];
            fiwPos = [pos(1), pos(2) + 1*posStep, pos(3), posStep];
            posPos = [pos(1), pos(2) + 0*posStep, pos(3), posStep];
            
            obj.IntenTrace = ...
                TirfAnalysis.GuiElements.IntensityTrace(figH,intenPos);
            obj.FretTrace = ...
                TirfAnalysis.GuiElements.FretTrace(figH,fretPos);
            obj.FiwTrace = ...
                TirfAnalysis.GuiElements.FiwTrace(figH,fiwPos);
            obj.PosTrace = ...
                TirfAnalysis.GuiElements.PositionTrace(figH,posPos);
            
            unAx = [obj.PosTrace.getUnAx, obj.FretTrace.getUnAx,...
                obj.FiwTrace.getUnAx, obj.IntenTrace.getUnAx];
            
            
            
            for iAx = numel(unAx):-1:1
                limitListeners(iAx) = ...
                    addlistener(handle(unAx(iAx)),'XLim','PostSet',...
                    @(~,~) set(unAx,'XLim',get(unAx(iAx),'XLim')));
            end
            
            obj.LimitListeners = limitListeners;
            
        end
       
        % update the displayed data
        function setData(obj,particle)
            % intensity
            obj.IntenTrace.setData(obj.parseIntensity(particle));
            % fret
            obj.FretTrace.setData(obj.parseFret(particle));
            % width
            obj.FiwTrace.setData(obj.parseWidth(particle));
            % position
            obj.PosTrace.setData(obj.parsePosition(particle));
            
            % update the x limits
            xlimits = [0, particle.getMaxTime];
           
            obj.OriginalLimX = xlimits;
            
            obj.IntenTrace.setXlim(xlimits);
            obj.FretTrace.setXlim(xlimits);
            obj.FiwTrace.setXlim(xlimits);
            obj.PosTrace.setXlim(xlimits);
            
        end
        
        
        function setHighlight(obj,timeX)
            obj.IntenTrace.setHighlight(timeX);
            obj.FretTrace.setHighlight(timeX);
            obj.FiwTrace.setHighlight(timeX);
            obj.PosTrace.setHighlight(timeX);
        end
        
        % resets the x limits to the full data set
        function resetView(obj)
            xlimits = obj.OriginalLimX;
            
            obj.IntenTrace.setXlim(xlimits);
            obj.FretTrace.setXlim(xlimits);
            obj.FiwTrace.setXlim(xlimits);
            obj.PosTrace.setXlim(xlimits);
            
        end
        
        function delete(obj)
            if ishandle(obj.IntenTrace)
                delete(obj.IntenTrace);
            end
            if ishandle(obj.FretTrace)
                delete(obj.FretTrace);
            end
            if ishandle(obj.FiwTrace)
                delete(obj.FiwTrace);
            end
            if ishandle(obj.PosTrace)
                delete(obj.PosTrace);
            end
            % delete listers
            for iListener = 1:numel(obj.LimitListeners)
                if ishandle(obj.LimitListeners(iListener))
                    delete(obj.LimitListeners(iListener));
                end
                    
            end
            
        end
    end
    
    methods (Access = protected)
        % parse the particle data
        function intensityData = parseIntensity(~,particle)
            [dd, ddTime] = particle.getDd;
            [dt, dtTime] = particle.getDt;
            [da, daTime] = particle.getDa;
            [tt, ttTime] = particle.getTt;
            [ta, taTime] = particle.getTa;
            [aa, aaTime] = particle.getAa;
            
            intensityData = {...
                [dd, ddTime],...
                [dt, dtTime],...
                [da, daTime],...
                [tt, ttTime],...
                [ta, taTime],...
                [aa, aaTime]};
        end
        function fretData = parseFret(~,particle)
            [dd, ddTime] = particle.getDd;
            [dt, ~] = particle.getDt;
            [da, ~] = particle.getDa;
            [tt, ttTime] = particle.getTt;
            [ta, ~] = particle.getTa;
            
            dtFret = dt./(dt+dd);
            daFret = da./(da+dd);
            taFret = ta./(ta+tt);
            
            fretData = {...
                [dtFret, ddTime],...
                [daFret, ddTime],...
                [taFret, ttTime]};
        end
        function widthData = parseWidth(~,particle)
            [ddWidth, ddTime] = particle.getDdWidth;
            [dtWidth, dtTime] = particle.getDtWidth;
            [daWidth, daTime] = particle.getDaWidth;
            [ttWidth, ttTime] = particle.getTtWidth;
            [taWidth, taTime] = particle.getTaWidth;
            [aaWidth, aaTime] = particle.getAaWidth;
            
            widthData = {...
                [ddWidth, ddTime],...
                [dtWidth, dtTime],...
                [daWidth, daTime],...
                [ttWidth, ttTime],...
                [taWidth, taTime],...
                [aaWidth, aaTime]};
        end
        function intensityData = parsePosition(obj,particle)
            % the below controls what we are acutally plotting with
            % position time traces
            % currently, DD, TT and AA are the positions relative to the
            % starting position
            % and DT, DA, and TA are the distances between the DD and TT,
            % the DD and AA, and the TT and TA positions
            
            [ddPos, ddTime] = particle.getDistance('DD',obj.POS_AVG);
            [dtPos, dtTime] = particle.getDistance('DD','TT');
            [daPos, daTime] = particle.getDistance('DD','AA');
            [ttPos, ttTime] = particle.getDistance('TT',obj.POS_AVG);
            [taPos, taTime] = particle.getDistance('TT','AA');
            [aaPos, aaTime] = particle.getDistance('AA',obj.POS_AVG);
            
            intensityData = {...
                [ddPos, ddTime],...
                [dtPos, dtTime],...
                [daPos, daTime],...
                [ttPos, ttTime],...
                [taPos, taTime],...
                [aaPos, aaTime]};
        end
    end
end
