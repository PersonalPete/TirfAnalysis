classdef Particle % A value class
    % Particle (Value class) is the base class for 3 color analysis results
    % Its methods are used to extract information about the fit
    % e.g.
    %
    % [dd, frameTime] = particle.getDd;
    % [position, frameTime] = particle.getDdPosition;
    % images = particle.getDdImageData;
    %
    %
    properties (Access = protected)
        GreenFrameTime
        RedFrameTime
        NirFrameTime
        
        IsFixedPos
        IsEllipse
        
        FitParamNames
        
        DdFit
        DtFit
        DaFit
        TtFit
        TaFit
        AaFit
        
        DdImageData
        DaImageData
        DtImageData
        TtImageData
        TaImageData
        AaImageData
        
        Tform3
    end
    
    methods (Access = public)
        % constructor
        function obj = ...
                Particle(...
                fitResults,...
                isFixedPos,...
                isEllipse,...
                imData,...
                frameTimes,...
                tform3)
            % special syntax, useful for subclassing to add behaviour
            % objCopy = Particle(obj);
            % you'd want a subclass constructor that took in an original
            % particle object and called the superclass constructor with
            % the original particle - then you could add methods, which
            % would access the original particle's data
            % fitResults = {dd,dt,da,tt,ta,aa} (same for imData)
            % frameTimes = {green, red, nir}
            if nargin == 0
                % no-arg constructor, used for initialising
                obj.GreenFrameTime = [];
                obj.RedFrameTime = [];
                obj.NirFrameTime = [];
                
                obj.IsFixedPos = [];
                obj.IsEllipse = [];
                
                obj.FitParamNames = [];
                
                obj.DdFit = [];
                obj.DtFit = [];
                obj.DaFit = [];
                obj.TtFit = [];
                obj.TaFit = [];
                obj.AaFit = [];
                
                obj.DdImageData = [];
                obj.DaImageData = [];
                obj.DtImageData = [];
                obj.TtImageData = [];
                obj.TaImageData = [];
                obj.AaImageData = [];
                
                obj.Tform3 = [];
            elseif nargin == 1
                % special constructor syntax that copies an object passed
                % as a single input
                obj.GreenFrameTime = fitResults.getGreenFrameTime;
                obj.RedFrameTime = fitResults.getRedFrameTime;
                obj.NirFrameTime = fitResults.getNirFrameTime;
                
                obj.IsFixedPos = fitResults.getIsFixedPos;
                obj.IsEllipse = fitResults.getIsEllipse;
                
                obj.FitParamNames = fitResults.getFitParamNames;
                
                obj.DdFit = fitResults.getDdFit;
                obj.DtFit = fitResults.getDtFit;
                obj.DaFit = fitResults.getDaFit;
                obj.TtFit = fitResults.getTtFit;
                obj.TaFit = fitResults.getTaFit;
                obj.AaFit = fitResults.getAaFit;
                
                obj.DdImageData = fitResults.getDdImageData;
                obj.DaImageData = fitResults.getDaImageData;
                obj.DtImageData = fitResults.getDtImageData;
                obj.TtImageData = fitResults.getTtImageData;
                obj.TaImageData = fitResults.getTaImageData;
                obj.AaImageData = fitResults.getAaImageData;
                
                obj.Tform3 = fitResults.getTform3;
            else
                obj.IsFixedPos = isFixedPos;
                obj.IsEllipse = isEllipse;
                
                if isEllipse
                    obj.FitParamNames = ...
                        {'A0','s_x','s_y','bgd','x','y','theta'};
                else
                    obj.FitParamNames = ...
                        {'A0','s','bgd','x','y'};
                end
                
                % TODO: setup the fit param names based on the analysis
                % settings
                
                obj.DdFit = fitResults{1};
                obj.DtFit = fitResults{2};
                obj.DaFit = fitResults{3};
                obj.TtFit = fitResults{4};
                obj.TaFit = fitResults{5};
                obj.AaFit = fitResults{6};
                
                obj.DdImageData = imData{1};
                obj.DaImageData = imData{2};
                obj.DtImageData = imData{3};
                obj.TtImageData = imData{4};
                obj.TaImageData = imData{5};
                obj.AaImageData = imData{6};
                
                obj.GreenFrameTime = frameTimes{1}(:);
                obj.RedFrameTime = frameTimes{2}(:);
                obj.NirFrameTime = frameTimes{3}(:);
                
                obj.Tform3 = tform3;
            end
            
            
        end
        
        % getters for properties
        function greenFrameTime = getGreenFrameTime(obj)
            greenFrameTime = obj.GreenFrameTime;
        end
        function redFrameTime = getRedFrameTime(obj)
            redFrameTime = obj.RedFrameTime;
        end
        function nirFrameTime = getNirFrameTime(obj)
            nirFrameTime = obj.NirFrameTime;
        end
        function isFixedPos = isFixedPos(obj)
            isFixedPos = obj.IsFixedPos;
        end
        function isEllipse = isEllipse(obj)
            isEllipse = obj.IsEllipse;
        end
        
        function fitParamNames = getFitParamNames(obj)
            fitParamNames = obj.FitParamNames;
        end

        function ddFit = getDdFit(obj)
            ddFit = obj.DdFit;
        end
        function dtFit = getDtFit(obj)
            dtFit = obj.DtFit;
        end
        function daFit = getDaFit(obj)
            daFit = obj.DaFit;
        end
        function ttFit = getTtFit(obj)
            ttFit = obj.TtFit;
        end
        function taFit = getTaFit(obj)
            taFit = obj.TaFit;
        end
        function aaFit = getAaFit(obj)
            aaFit = obj.AaFit;
        end
        
        function ddImageData = getDdImageData(obj)
            ddImageData = obj.DdImageData;
        end
        function dtImageData = getDtImageData(obj)
            dtImageData = obj.DtImageData;
        end
        function daImageData = getDaImageData(obj)
            daImageData = obj.DaImageData;
        end
        function ttImageData = getTtImageData(obj)
            ttImageData = obj.TtImageData;
        end
        function taImageData = getTaImageData(obj)
            taImageData = obj.TaImageData;
        end
        function aaImageData = getAaImageData(obj)
            aaImageData = obj.AaImageData;
        end
        
        % getters for derived quantities i.e. intensity or mean image width
        function [dd, frameTime] = getDd(obj)
            dd = obj.getIntensity(@obj.getDdFit);
            frameTime = obj.getGreenFrameTime;
        end
        function [dt, frameTime] = getDt(obj)
            dt = obj.getIntensity(@obj.getDtFit);
            frameTime = obj.getGreenFrameTime;
        end
        function [da, frameTime] = getDa(obj)
            da = obj.getIntensity(@obj.getDaFit);
            frameTime = obj.getGreenFrameTime;
        end
        function [tt, frameTime] = getTt(obj)
            tt = obj.getIntensity(@obj.getTtFit);
            frameTime = obj.getRedFrameTime;
        end
        function [ta, frameTime] = getTa(obj)
            ta = obj.getIntensity(@obj.getTaFit);
            frameTime = obj.getRedFrameTime;
        end
        function [aa, frameTime] = getAa(obj)
            aa = obj.getIntensity(@obj.getAaFit);
            frameTime = obj.getNirFrameTime;
        end
        
        function [ddWidth, frameTime] = getDdWidth(obj)
            ddWidth = obj.getWidth(@obj.getDdFit);
            frameTime = obj.getGreenFrameTime;
        end
        function [dtWidth, frameTime] = getDtWidth(obj)
            dtWidth = obj.getWidth(@obj.getDtFit);
            frameTime = obj.getGreenFrameTime;
        end
        function [daWidth, frameTime] = getDaWidth(obj)
            daWidth = obj.getWidth(@obj.getDaFit);
            frameTime = obj.getGreenFrameTime;
        end
        function [ttWidth, frameTime] = getTtWidth(obj)
            ttWidth = obj.getWidth(@obj.getTtFit);
            frameTime = obj.getRedFrameTime;
        end
        function [taWidth, frameTime] = getTaWidth(obj)
            taWidth = obj.getWidth(@obj.getTaFit);
            frameTime = obj.getRedFrameTime;
        end
        function [aaWidth, frameTime] = getAaWidth(obj)
            aaWidth = obj.getWidth(@obj.getAaFit);
            frameTime = obj.getNirFrameTime;
        end
        
        % position getters - these all return in the red coordinates
        function [ddPosition, frameTime] = getDdPosition(obj)
            ddPosition = obj.getPosition(@obj.getDdFit);
            ddPosition = obj.Tform3.transformG2R(ddPosition);
            frameTime = obj.getGreenFrameTime;
        end
        function [dtPosition, frameTime] = getDtPosition(obj)
            dtPosition = obj.getPosition(@obj.getDtFit);
            frameTime = obj.getGreenFrameTime;
        end
        function [daPosition, frameTime] = getDaPosition(obj)
            daPosition = obj.getPosition(@obj.getDaFit);
            daPosition = obj.Tform3.transformN2R(daPosition);
            frameTime = obj.getGreenFrameTime;
        end
        function [ttPosition, frameTime] = getTtPosition(obj)
            ttPosition = obj.getPosition(@obj.getTtFit);
            frameTime = obj.getRedFrameTime;
        end
        function [taPosition, frameTime] = getTaPosition(obj)
            taPosition = obj.getPosition(@obj.getTaFit);
            taPosition = obj.Tform3.transformN2R(taPosition);
            frameTime = obj.getRedFrameTime;
        end
        function [aaPosition, frameTime] = getAaPosition(obj)
            aaPosition = obj.getPosition(@obj.getAaFit);
            aaPosition = obj.Tform3.transformN2R(aaPosition);
            frameTime = obj.getNirFrameTime;
        end
        
        function tform3 = getTform3(obj)
            tform3 = obj.Tform3;
        end
    end
    
    methods (Access = protected)
        % convenience function for accessing derived quantities from fits
        function intensity = getIntensity(obj,fitGetFcn)
            fitResult = fitGetFcn();
            if obj.IsEllipse
                intensity = 2*pi*prod(fitResult(:,1:3),2);
            else
                intensity = 2*pi*prod(fitResult(:,1:2),2).*fitResult(:,2);
            end
        end  
        function width = getWidth(obj,fitGetFcn)
            fitResult = fitGetFcn();
            if obj.IsEllipse
                width = mean(fitResult(:,2:3),2);
            else
                width = fitResult(:,2);
            end
        end
        function position = getPosition(obj,fitGetFcn)
            fitResult = fitGetFcn();
            if obj.IsEllipse
                position = fitResult(:,5:6);
            else
                position = fitResult(:,4:5);
            end
        end
        
    end
end
            