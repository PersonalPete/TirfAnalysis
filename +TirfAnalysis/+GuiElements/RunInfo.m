classdef RunInfo < handle
    % RunInfo is for displaying the current cluster status regarding
    % analysis jobs submitted, and for supplying a 'run' button
    properties (Access = protected)
        FigH
        
        PendingH
        RunningH
        FinishedH
        FailedH
        
        RunH
        StatH
    end
    
    properties (Access = protected, Constant)
        % some settings which control the appearance
        BGD_COL = [0.2 0.2 0.2]
        TXT_COL = [1.0 1.0 1.0]
        TXT_SIZE = 0.6
        
        DFT_BUT_COL = [0.24 0.35 0.67]
        DFT_BUT_TXT = [1 1 1]
        
        ALIGN_FAC = 0.7
    end
    
    methods (Access = public)
        % constructor
        function obj = RunInfo(figH,pos,runCallback,statusCallback)
            obj.FigH = figH;
            
            % set up the spacing
            yStep = pos(4)./7;
            pos(4) = yStep;
            
            posPending = pos;
            posPending(2) = posPending(2) + yStep*6;
            posRunning = pos;
            posRunning(2) = posRunning(2) + yStep*5;
            posFinished = pos;
            posFinished(2) = posFinished(2) + yStep*4;
            posFailed = pos;
            posFailed(2) = posFailed(2) + yStep*3;
            
            posRun = pos;
            posRun(3) = posRun(3)/2;
            posRun(4) = yStep*2;
            
            posStat = pos;
            posStat(3) = posStat(3)/2;
            posStat(1) = posStat(1) + posStat(3);
            posStat(4) = yStep*2;
            
            obj.PendingH = obj.makeTextBox(posPending);
            obj.RunningH = obj.makeTextBox(posRunning);
            obj.FinishedH = obj.makeTextBox(posFinished);
            obj.FailedH = obj.makeTextBox(posFailed);
            
            obj.RunH = uicontrol('parent',obj.FigH,...
                'style','pushbutton',...
                'units','normalized',...
                'position',posRun,...
                'FontUnits','normalized',...
                'FontSize',obj.TXT_SIZE/2,...
                'BackgroundColor',obj.DFT_BUT_COL,...
                'ForegroundColor',obj.DFT_BUT_TXT,...
                'String','RUN',...
                'Callback',runCallback);
            
            obj.StatH = uicontrol('parent',obj.FigH,...
                'style','pushbutton',...
                'units','normalized',...
                'position',posStat,...
                'FontUnits','normalized',...
                'FontSize',obj.TXT_SIZE/2,...
                'BackgroundColor',obj.DFT_BUT_COL,...
                'ForegroundColor',obj.DFT_BUT_TXT,...
                'String','Update Status',...
                'Callback',statusCallback);
            
            obj.setDisplay(0,0,0,0);
            
        end
        
        % for setting the current information about the job status
        function setDisplay(obj,...
                nJobsPending, nJobsRunning, nJobsFinished, nJobsErr)
            set(obj.PendingH,...
                'String',sprintf('%i jobs pending',nJobsPending));
            set(obj.RunningH,...
                'String',sprintf('%i jobs running',nJobsRunning));
            set(obj.FinishedH,...
                'String',sprintf('%i jobs done',nJobsFinished));
            set(obj.FailedH,...
                'String',sprintf('%i jobs failed',nJobsErr));
        end
        
    end 
    
    methods (Access = protected)
        % convenience method for producing our string boxes
        function textH = makeTextBox(obj,pos)
            % make a small gap
            pos(1) = pos(1) + (1 - obj.ALIGN_FAC)*pos(3);
            pos(3) = pos(3) * obj.ALIGN_FAC;
            
            textH = uicontrol('parent',obj.FigH,...
                'style','text',...
                'units','normalized',...
                'position',pos,...
                'HorizontalAlignment','left',...
                'FontUnits','normalized',...
                'FontSize',obj.TXT_SIZE,...
                'BackgroundColor',obj.BGD_COL,...
                'ForegroundColor',obj.TXT_COL,...
                'String','');
        end
    end
end