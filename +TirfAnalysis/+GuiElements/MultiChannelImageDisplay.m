classdef MultiChannelImageDisplay < handle
    % MultiChannelImageDisplay displays 3-color image data
    % DISPLAYS WHOLE IMAGE
    
    properties (Access = protected)
        DdIm
        DtIm
        DaIm
        TtIm
        TaIm
        AaIm   
        
        FigH
    end
    
    properties (Constant, Access = protected)
        DFT_XSPACING = 0.1
        DFT_INFO_FRAC = 0.075;
        DFT_GAP_FRAC = 0.025;
        
        DFT_D_COL = [0.0 0.8 0.0]
        DFT_T_COL = [0.8 0.0 0.0]
        DFT_A_COL = [0.8 0.8 0.5]
        
        DFT_DD_COL = [0.0 0.8 0.0]
        DFT_DT_COL = [0.8 0.0 0.0]
        DFT_DA_COL = [0.8 0.8 0.5]
        DFT_TT_COL = [0.8 0.0 0.0]
        DFT_TA_COL = [0.8 0.8 0.5]
        DFT_AA_COL = [0.8 0.8 0.5]
        
        DFT_FONT_SIZE = 0.8;        
    end
        
    
    methods (Access = public)
        % constructor
        function obj = MultiChannelImageDisplay(figH,pos)
            obj.FigH = figH;
            % work out the positions
            % the x positions are the ones we need to analysis
            xMin = pos(1);
            xStep = pos(3)/(6 + obj.DFT_XSPACING);
            xSpace = (xStep*obj.DFT_XSPACING)/5;
            
            ySpace = (1-obj.DFT_INFO_FRAC)* pos(4);
            yRem = obj.DFT_INFO_FRAC*pos(4);           
            
            ddPos = [xMin + 0*(xStep + xSpace), ...
                pos(2), xStep, ySpace];
            dtPos = [xMin + 1*(xStep + xSpace),...
                pos(2), xStep, ySpace];
            daPos = [xMin + 2*(xStep + xSpace),...
                pos(2), xStep, ySpace];
            ttPos = [xMin + 3*(xStep + xSpace),...
                pos(2), xStep, ySpace];
            taPos = [xMin + 4*(xStep + xSpace),...
                pos(2), xStep, ySpace];
            aaPos = [xMin + 5*(xStep + xSpace),...
                pos(2), xStep, ySpace];
            
            import TirfAnalysis.GuiElements.ImageDisplayWithMarkings
            
            % build the image displays
            obj.DdIm = ImageDisplayWithMarkings(figH,ddPos,obj.DFT_DD_COL);
            obj.DtIm = ImageDisplayWithMarkings(figH,dtPos,obj.DFT_DT_COL);
            obj.DaIm = ImageDisplayWithMarkings(figH,daPos,obj.DFT_DA_COL);
            obj.TtIm = ImageDisplayWithMarkings(figH,ttPos,obj.DFT_TT_COL);
            obj.TaIm = ImageDisplayWithMarkings(figH,taPos,obj.DFT_TA_COL);
            obj.AaIm = ImageDisplayWithMarkings(figH,aaPos,obj.DFT_AA_COL);
            
            % build the information boxes
            
            yGap = obj.DFT_GAP_FRAC * pos(4);
            
            ddPosInf = [xMin + 0*(xStep + xSpace), ...
                pos(2) + ySpace + yGap, xStep, yRem - yGap];
            dtPosInf = [xMin + 1*(xStep + xSpace),...
                pos(2) + ySpace + yGap, xStep, yRem - yGap];
            daPosInf = [xMin + 2*(xStep + xSpace),...
                pos(2) + ySpace + yGap, xStep, yRem - yGap];
            ttPosInf = [xMin + 3*(xStep + xSpace),...
                pos(2) + ySpace + yGap, xStep, yRem - yGap];
            taPosInf = [xMin + 4*(xStep + xSpace),...
                pos(2) + ySpace + yGap, xStep, yRem - yGap];
            aaPosInf = [xMin + 5*(xStep + xSpace),...
                pos(2) + ySpace + yGap, xStep, yRem - yGap];
            
            d = obj.DFT_D_COL;
            t = obj.DFT_T_COL;
            a = obj.DFT_A_COL;
            
            % build the information boxes above them
            obj.buildInfoStrings('D','D',d,d,ddPosInf);
            obj.buildInfoStrings('D','T',d,t,dtPosInf);
            obj.buildInfoStrings('D','A',d,a,daPosInf);
            obj.buildInfoStrings('T','T',t,t,ttPosInf);
            obj.buildInfoStrings('T','A',t,a,taPosInf);
            obj.buildInfoStrings('A','A',a,a,aaPosInf);
            
        end
        
        % update the image information with what is found in an
        % AnalysisMovie
        function updateDisplay(obj,analysisMovie)
            % set the frame data
            obj.DdIm.setImData(analysisMovie.getMeanDDFrame);
            obj.DtIm.setImData(analysisMovie.getMeanDTFrame);
            obj.DaIm.setImData(analysisMovie.getMeanDAFrame);
            obj.TtIm.setImData(analysisMovie.getMeanTTFrame);
            obj.TaIm.setImData(analysisMovie.getMeanTAFrame);
            obj.AaIm.setImData(analysisMovie.getMeanAAFrame);
            
            [linkGreen, linkRed, linkNir] = analysisMovie.getLinkedPos;
            
            obj.DdIm.setMarkData(linkGreen,analysisMovie.getDdPos);
            obj.DtIm.setMarkData(linkRed,analysisMovie.getDtPos);
            obj.DaIm.setMarkData(linkNir,analysisMovie.getDaPos);
            obj.TtIm.setMarkData(linkRed,analysisMovie.getTtPos);
            obj.TaIm.setMarkData(linkNir,analysisMovie.getTaPos);
            obj.AaIm.setMarkData(linkNir,analysisMovie.getAaPos);
            
        end
        
    end % public methods
    
    methods (Access = protected)
        function buildInfoStrings(obj,string1,string2,col1,col2,pos)
            pos(3) = pos(3)/2;
            pos1 = pos;
            pos2 = pos;
            pos2(1) = pos2(1) + pos2(3);
            
            % build one
            uicontrol('parent',obj.FigH,...
                'Style','Text',...
                'Units','Normalized',...
                'position',pos1,...
                'FontUnits','normalized',...
                'FontSize',obj.DFT_FONT_SIZE,...
                'String',string1,...
                'BackgroundColor',col1);
            % build the other
             uicontrol('parent',obj.FigH,...
                'Style','Text',...
                'Units','Normalized',...
                'position',pos2,...
                'FontUnits','normalized',...
                'FontSize',obj.DFT_FONT_SIZE,...
                'String',string2,...
                'BackgroundColor',col2);           
        end
    end % protected methods

end