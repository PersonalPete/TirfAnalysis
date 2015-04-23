classdef AnalysisSettings % a value class...
    properties (Access = protected)
        % detection settings
        Tform3 % transform
        NFrames % number of frames to average over
        SmoothKernel % smoothing kernel
        PeakThresh % peak detection threshold [greenThresh, redThresh, nir...]
        BgdRadiusFac % radius is ceil(SmoothKernel*BgdRadiusFac) around peak
        LinkRadius % how far away (in px) can linkings between channels be
        
        LinkBoolFun % link = linkBoolFun(DD,DT,DA,TT,TA,AA) % see MainModel
        NearNeighLim % at what distance two localisations are discarded for
                  % being to close to each other
        
        FilteringEllip % [greenEllip; redEllip,; nirEllip] (min ellipticity)
        FilteringWid % [min, max]
        
        % algorithm settings
        FixedPos
        FixedWid
        Ellipse
        
        WindowRad  % extraction area radius
        
        % algorithm limits
        PosLim % [min max]
        WidLim % [min max]
    end
    methods (Access = public)
        function obj = AnalysisSettings(...
                tform3,...
                nFrames,...
                smoothKernel,...
                peakThresh,...
                bgdRadiusFac,...
                linkRadius,...
                linkBoolFun,...
                nearNeighLim,...
                filteringEllip,...
                filteringWid,...
                fixedPos,...
                fixedWid,...
                ellipse,...
                posLim,...
                widLim,...
                windowRad)
            % constructor
            if nargin < 16
                obj.Tform3 = TirfAnalysis.Reg.TformInfo3;
                obj.NFrames = [];
                obj.SmoothKernel = [];
                obj.PeakThresh = [];
                obj.BgdRadiusFac = [];
                obj.LinkRadius = [];
                obj.LinkBoolFun = @(DD,DT,DA,TT,TA,AA)0;
                obj.NearNeighLim = [];
                obj.FilteringEllip = [];
                obj.FilteringWid = [];
                
                % algorithm settings
                obj.FixedPos = [];
                obj.FixedWid = [];
                obj.Ellipse = [];
                
                % algorithm limits
                obj.PosLim = [];
                obj.WidLim = [];
                
                obj.WindowRad = [];
                
            else
                % detection settings
                obj.Tform3 = tform3;
                obj.NFrames = nFrames;
                obj.SmoothKernel = smoothKernel;
                obj.PeakThresh = peakThresh;
                obj.BgdRadiusFac = bgdRadiusFac;
                obj.LinkRadius = linkRadius;
                obj.LinkBoolFun = linkBoolFun;
                obj.NearNeighLim = nearNeighLim;
                obj.FilteringEllip = filteringEllip;
                obj.FilteringWid = filteringWid;
                
                % algorithm settings
                obj.FixedPos = fixedPos;
                obj.FixedWid = fixedWid;
                obj.Ellipse = ellipse;
                
                % algorithm limits
                obj.PosLim = posLim;
                obj.WidLim = widLim;
                
                obj.WindowRad = windowRad;
            end
        end
        
        %% Getters and setters N.B. setters return a new instance of the class
        function tform3 = getTform3(obj)
            tform3 = obj.Tform3;
        end
        function obj = setTform3(obj,tform3)
            obj.Tform3 = tform3;
        end
        
        function nFrames = getNFrames(obj)
            nFrames = obj.NFrames;
        end
        function obj = setNFrames(obj,nFrames)
            obj.NFrames = nFrames;
        end
        
        function smoothKernel = getSmoothKernel(obj)
            smoothKernel = obj.SmoothKernel;
        end
        function obj = setSmoothKernel(obj,smoothKernel)
            obj.SmoothKernel = smoothKernel;
        end
        
        function peakThresh = getPeakThresh(obj)
            peakThresh = obj.PeakThresh;
        end
        function obj = setPeakThresh(obj,peakThresh)
            obj.PeakThresh = peakThresh;
        end
        
        function bgdRadiusFac = getBgdRadiusFac(obj)
            bgdRadiusFac = obj.BgdRadiusFac;
        end
        function obj = setBgdRadiusFac(obj,bgdRadiusFac)
            obj.BgdRadiusFac = bgdRadiusFac;
        end
        
        function linkRadius = getLinkRadius(obj)
            linkRadius = obj.LinkRadius;
        end
        function obj = setLinkRadius(obj,linkRadius)
            obj.LinkRadius = linkRadius;
        end
        
        function linkBoolFun = getLinkBoolFun(obj)
            linkBoolFun = obj.LinkBoolFun;
        end
        function obj = setLinkBoolFun(obj,linkBoolFun)
            obj.LinkBoolFun = linkBoolFun;
        end
        
        function nearNeighLim = getNearNeighLim(obj)
            nearNeighLim = obj.NearNeighLim;
        end       
        function obj = setNearNeighLim(obj,nearNeighLim)
            obj.NearNeighLim = nearNeighLim;
        end
        
        function filteringEllip = getFilteringEllip(obj)
            filteringEllip = obj.FilteringEllip;
        end
        function obj = setFilteringEllip(obj,filteringEllip)
            obj.FilteringEllip = filteringEllip;
        end
        
        function filteringWid = getFilteringWid(obj)
            filteringWid = obj.FilteringWid;
        end
        function obj = setFilteringWid(obj,filteringWid)
            obj.FilteringWid = filteringWid;
        end
        
        % algorithm settings
        function fixedPos = isFixedPos(obj)
            fixedPos = obj.FixedPos;
        end
        function obj = setFixedPos(obj,fixedPos)
            obj.FixedPos = fixedPos;
        end
        
        % NB Fixed width unsupported at this time (21 April 2015)
        function fixedWid = isFixedWid(obj)
            fixedWid = obj.FixedWid;
        end
        function obj = setFixedWid(obj,fixedWid)
            obj.FixedWid = fixedWid;
        end

        function ellipse = isEllipse(obj)
            ellipse = obj.Ellipse;
        end
        function obj = setEllipse(obj,ellipse)
            obj.Ellipse = ellipse;
        end
        
        function windowRad = getWindowRad(obj)
            windowRad = obj.WindowRad;
        end
        function obj = setWindowRad(obj,windowRad)
            obj.WindowRad = windowRad;
        end
        
        % algorithm limits
        function posLim = getPosLim(obj)
            posLim = obj.PosLim;
        end
        function obj = setPosLim(obj,posLim)
            obj.PosLim = posLim;
        end
        
        function widLim = getWidLim(obj)
            widLim = obj.WidLim;
        end
        function obj = setWidLim(obj,widLim)
            obj.WidLim = widLim;
        end
        
        %% getters from nested things
        function greenLim = getGreenLimits(obj,n)
            greenLim = obj.Tform3.getGreenLimits;
            if nargin > 1
                greenLim = greenLim(n);
            end
        end
        function redLim = getRedLimits(obj,n)
            redLim = obj.Tform3.getRedLimits;
            if nargin > 1
                redLim = redLim(n);
            end
        end
        function nirLim = getNirLimits(obj,n)
            nirLim = obj.Tform3.getNirLimits;
            if nargin > 1
                nirLim = nirLim(n);
            end
        end
        
        function link = linkBoolFun(obj,DD,DT,DA,TT,TA,AA)
            try 
                link = obj.LinkBoolFun(DD,DT,DA,TT,TA,AA);
            catch
                link = 0;
                w1 = 'Linking Function undefined or incorrectly defined';
                w2 = ', or linking arguments invalid: No linking performed';
                warning([w1 w2]);
            end
        end % linkBoolFun
    end
end

