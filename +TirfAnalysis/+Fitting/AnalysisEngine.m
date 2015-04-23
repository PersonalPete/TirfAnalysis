classdef AnalysisEngine < handle
    properties (Access = protected)
        % things passed in the constructor
        AnalysisSettings
        LoadPath
        MovieFileName
        
        % things constructed in constructor
        AnalysisMovie
        PosLim
        WidLim
        IsFixedPos
        IsEllipse
        FrameTimes
        Tform3
        
        Abort % if something has gone wrong, we needn't continue analysis
    end
        
    properties (Constant, Access = protected)
        % fitting settings
        VERBOSE = 0
        
        EPS_1 = 1e-7
        EPS_2 = 1e-9
        EPS_3 = 0
        
        MAX_ITER_FIX = 30
        MAX_ITER_FREE = 100
        
        SCALE_FAC = 5 % scale image between 0-5 for fitting
                      % we do this so the fit parameters have similar
                      % magnitude
                      
        POS_BOUND = 65535 % used when we don't want to constrain position
        
        FILE_APPEND = '.fit3Result.mat'
    end
    
    methods (Access = protected)
        % constructor
        function obj = AnalysisEngine(...
                analysisSettings,...
                loadPath,...
                movieFileName)
            
            obj.AnalysisSettings = analysisSettings;
            obj.LoadPath = loadPath;
            obj.MovieFileName = movieFileName;
            
            % unpackage some analysis settings for easy access
            obj.PosLim = analysisSettings.getPosLim;
            widLim = analysisSettings.getWidLim;
            obj.WidLim = [min(widLim), max(widLim)];
            
            obj.IsFixedPos = analysisSettings.isFixedPos;
            obj.IsEllipse = analysisSettings.isEllipse;
            
            obj.Tform3 = analysisSettings.getTform3;
            
            % check if the Movie File name/path is legit
            
            obj.AnalysisMovie = [];
            obj.Abort = 1;
            
            try
                % check if the movie has metadata and matches the transform
                [ok, fitsMovie, metadata] = ...
                    TirfAnalysis.Main.AnalysisMovie.checkIfOk(...
                    obj.LoadPath,obj.MovieFileName,obj.AnalysisSettings);
                
                if ok
                    obj.AnalysisMovie = ...
                        TirfAnalysis.Main.AnalysisMovie(...
                        fitsMovie,metadata,obj.AnalysisSettings);
                    obj.FrameTimes = {...
                        obj.AnalysisMovie.getGreenFrameTimes,...
                        obj.AnalysisMovie.getRedFrameTimes,...
                        obj.AnalysisMovie.getNirFrameTimes};
                    obj.Abort = 0;
                end
            catch
                w1 = 'Problem loading movie/metadata:';
                w2 = ' limits may not match tform';
                warning([w1 w2]);
            end
            
        end
        
        % for running the analysis
        function [success, movieResult] = runAnalysis(obj)
            
            success = 0;
            movieResult = [];
            
            if ~obj.Abort % i.e. don't run if we have had a problem
                
                [ddStacks,dtStacks,daStacks,ttStacks,taStacks,aaStacks,...
                    posGreen,posRed,posNir,...
                    originGreen,originRed,originNir] = ...
                    obj.AnalysisMovie.getImageStacks;
                
                nParticles = size(originGreen,1);
                
                metadata = obj.AnalysisMovie.getMovieMetadata;
                
                % delete the analysis movie object (hopefully this reduces
                % memory useage)
                delete(obj.AnalysisMovie);
                obj.Abort = 1; % having deleted this, we can't run analysis
                               % again
                
                % allocate the results array
                particles(nParticles) = TirfAnalysis.Results.Particle();
                
                % loop over the detected particles
                for iParticle = 1:nParticles
                    % perform the fitting for this particular particle and
                    % build a TirfAnalysis.Results.Particle object which
                    % contains all the fit information
                    particles(iParticle) = ...
                        obj.fitParticle(...
                        {ddStacks(:,:,:,iParticle),...
                        dtStacks(:,:,:,iParticle),...
                        daStacks(:,:,:,iParticle),...
                        ttStacks(:,:,:,iParticle),...
                        taStacks(:,:,:,iParticle),...
                        aaStacks(:,:,:,iParticle)},...
                        {posGreen(iParticle,:),...
                        posRed(iParticle,:),...
                        posNir(iParticle,:),...
                        posRed(iParticle,:),...
                        posNir(iParticle,:),...
                        posNir(iParticle,:)},...
                        {originGreen(iParticle,:),...
                        originRed(iParticle,:),...
                        originNir(iParticle,:),...
                        originRed(iParticle,:),...
                        originNir(iParticle,:),...
                        originNir(iParticle,:)});
                end
                
                movieResult = TirfAnalysis.Results.MovieResult(...
                    particles,...
                    obj.AnalysisSettings,...
                    metadata,...
                    obj.MovieFileName);
                
                success = 1;
            end % if not abort
            
        end
        
        % fit an particle's stack of images
        function particle = fitParticle(obj,stacks,positions,origins)
            % TODO write loops over all images that fit in all the channels
            fitResults = cell(size(stacks));
            
            % loop over the image stacks
            for iStack = 1:length(stacks)
                stack = stacks{iStack};
                nFrames = size(stack,3);
                
                % check what the analysis method is
                if obj.IsEllipse
                    nParam = 7;
                    if obj.IsFixedPos
                        gaussFitFun = @obj.fitFixedGaussEllipse;
                    else
                        gaussFitFun = @obj.fitFreeGaussEllipse;
                    end
                else
                    nParam = 5;
                    if obj.IsFixedPos
                        gaussFitFun = @obj.fitFixedGauss;
                    else
                        gaussFitFun = @obj.fitFreeGauss;
                    end
                end
                % allocate the memory for the fit parameters
                fitResults{iStack} = zeros(nFrames,nParam);
                
                % what is the localisation position in this channel, in the
                % sub-image coordinate system
                pos = positions{iStack} - origins{iStack};
                
                % loop over frames within a stack
                for iFrame = 1:nFrames
                    fitResults{iStack}(iFrame,:) = ...
                        gaussFitFun(squeeze(stack(:,:,iFrame)),pos);
                end % loop over frames  
                
                % add the origin position to the fit position, so we get the
                % positions in terms of the original channel frame - we can
                % directly apply any transforms here
                if obj.IsEllipse
                    fitResults{iStack}(:,5:6) = ...
                        bsxfun(@plus,fitResults{iStack}(:,5:6),...
                        origins{iStack});
                else
                    fitResults{iStack}(:,4:5) = ...
                        bsxfun(@plus,fitResults{iStack}(:,4:5),...
                        origins{iStack});
                end
                
            end % loop over image stacks
           
            % finally, build the particle object that stores the info
            particle = TirfAnalysis.Results.Particle(...
                fitResults,...
                obj.IsFixedPos,...
                obj.IsEllipse,...
                stacks,...
                obj.FrameTimes,...
                obj.Tform3);
            
        end
        
        % the fitting functions
        % fixed position, circular
        function fitResult = fitFixedGauss(obj,image,pos)
            % fitResult = [amp, wid, bgd, xPos, yPos]
            % scale the image
            imScaleFac = max(image(:))./obj.SCALE_FAC;
            image = image./imScaleFac;
            
            % set up the fitting options
            options = [...
                obj.VERBOSE,...
                obj.EPS_1, obj.EPS_2, obj.EPS_3,...
                obj.MAX_ITER_FIX];
            
            % fixed gauss so don't estimate the x,y-position
            [sigGuess, ~, ~] = obj.paramEstimate(image);
            
            initialGuess = [...
                max(image(:)),...
                sigGuess,...
                min(image(:)),...
                pos(1),...
                pos(2)];
            
            import TirfAnalysis.Fitting.GaussFitTools_bin_Win64.*
            
            % two ignored outputs are brightness (remember this needs
            % rescaling) and the normalized sqdev (per pixel, again needing
            % scaling)
            [~, fitParams, ~] = gaussfit_fixedposition(...
                image,...
                pos(1),...
                pos(2),...
                obj.WidLim(1),...
                obj.WidLim(2),...
                -obj.POS_BOUND,...
                +obj.POS_BOUND,...
                -obj.POS_BOUND,...
                +obj.POS_BOUND,...
                true,...
                initialGuess,...
                options);
            
            % rescale to match original image
            fitParams(1) = fitParams(1) * imScaleFac;
            fitParams(3) = fitParams(3) * imScaleFac;
            
            fitResult = fitParams;        
        end    
        % fixed position, elliptical
        function fitResult = fitFixedGaussEllipse(obj,image,pos)
            % pos is used for the limits on the fitted position
            % fitResult = [amp, xWid, yWid, bgd, xPos, yPos, theta]
            
            imScaleFac = max(image(:))./obj.SCALE_FAC;
            image = image./imScaleFac;
            
            options = [...
                obj.VERBOSE,...
                obj.EPS_1, obj.EPS_2, obj.EPS_3,...
                obj.MAX_ITER_FIX];
            
            [sigGuess, ~, ~] = obj.paramEstimate(image);
            
            initialGuess = [...
                max(image(:)),...
                sigGuess,...
                sigGuess,...
                min(image(:)),...
                pos(1),...
                pos(2),...
                0]; % thetaGuess = 0
            
            import TirfAnalysis.Fitting.GaussFitTools_bin_Win64.*
            
            [~,fitParams,~] = gaussfit_fixedposition_elliptical(...
                image,...
                pos(1),...
                pos(2),...
                obj.WidLim(1),...
                obj.WidLim(2),...
                obj.WidLim(1),...
                obj.WidLim(2),...
                -obj.POS_BOUND,...
                +obj.POS_BOUND,...
                -obj.POS_BOUND,...
                +obj.POS_BOUND,...
                true,...
                initialGuess,...
                options);
            
            % rescale to match original image
            fitParams(1) = fitParams(1) * imScaleFac;
            fitParams(4) = fitParams(4) * imScaleFac;
            
            fitResult = fitParams;  
                
        end 
        % free position, elliptical
        function fitResult = fitFreeGaussEllipse(obj,image,pos)
            % pos is used for the limits on the fitted position
            % fitResult = [amp, xWid, yWid, bgd, xPos, yPos, theta]
            
            imScaleFac = max(image(:))./obj.SCALE_FAC;
            image = image./imScaleFac;
            
            options = [...
                obj.VERBOSE,...
                obj.EPS_1, obj.EPS_2, obj.EPS_3,...
                obj.MAX_ITER_FREE];
            
            % this time use the centroids as guesses for x and y position
            [sigGuess, xGuess, yGuess] = obj.paramEstimate(image);
            
            initialGuess = [...
                max(image(:)),...
                sigGuess,...
                sigGuess,...
                min(image(:)),...
                xGuess,...
                yGuess,...
                0]; % thetaGuess = 0
            
            deltaPos = obj.PosLim;
            
            xMin = pos(1) - deltaPos;
            xMax = pos(1) + deltaPos;
            yMin = pos(2) - deltaPos;
            yMax = pos(2) + deltaPos;
            
            import TirfAnalysis.Fitting.GaussFitTools_bin_Win64.*
            
            [~,fitParams,~] = gaussfit_free_elliptical(...
                image,...
                obj.WidLim(1),...
                obj.WidLim(2),...
                obj.WidLim(1),...
                obj.WidLim(2),...
                xMin,...
                xMax,...
                yMin,...
                yMax,...
                true,...
                initialGuess,...
                options);
            
            % rescale to match original image
            fitParams(1) = fitParams(1) * imScaleFac;
            fitParams(4) = fitParams(4) * imScaleFac;
            
            fitResult = fitParams;  
                
        end  
        % free position, circular
        function fitResult = fitFreeGauss(obj,image,pos)
            % pos is used for the limits on the fitted position
            % fitResult = [amp, xWid, yWid, bgd, xPos, yPos, theta]
            
            imScaleFac = max(image(:))./obj.SCALE_FAC;
            image = image./imScaleFac;
            
            options = [...
                obj.VERBOSE,...
                obj.EPS_1, obj.EPS_2, obj.EPS_3,...
                obj.MAX_ITER_FREE];
            
            % this time use the centroids as guesses for x and y position
            [sigGuess, xGuess, yGuess] = obj.paramEstimate(image);
            
            initialGuess = [...
                max(image(:)),...
                sigGuess,...
                min(image(:)),...
                xGuess,...
                yGuess];
            
            deltaPos = obj.PosLim;
            
            xMin = pos(1) - deltaPos;
            xMax = pos(1) + deltaPos;
            yMin = pos(2) - deltaPos;
            yMax = pos(2) + deltaPos;
            
            import TirfAnalysis.Fitting.GaussFitTools_bin_Win64.*
            
            [~,fitParams,~] = gaussfit_free(...
                image,...
                obj.WidLim(1),...
                obj.WidLim(2),...
                xMin,...
                xMax,...
                yMin,...
                yMax,...
                true,...
                initialGuess,...
                options);
            
            % rescale to match original image
            fitParams(1) = fitParams(1) * imScaleFac;
            fitParams(3) = fitParams(3) * imScaleFac;
            
            fitResult = fitParams;  
                
        end
        
        function [sig, xCent, yCent] = paramEstimate(obj,image)
            xSum = abs(sum(image,1));
            ySum = abs(sum(image,2));
            xCoord = 1:size(image,2);
            yCoord = (1:size(image,1))';
            % work out the centroid of the image
            xCent = sum(xCoord.*xSum)/sum(xSum);
            yCent = sum(yCoord.*ySum)/sum(ySum);
            % work out the variance of the image (i.e. deviation from
            % centroid)
            xVar = sum((xCoord-xCent).^2.*xSum)/sum(xSum);
            yVar = sum((yCoord-yCent).^2.*ySum)/sum(ySum);
            % sigma we guess is the mean standard deviation
            sig = 0.25*(sqrt(xVar) + sqrt(yVar)); % guess a little smaller
            % make sure we don't guess a value that lies out of range
            widLim = obj.WidLim;
            
            sig = min(sig,widLim(2));
            sig = max(sig,widLim(1));
        end
        
    end
    
    % methods called externally to direct analysis
    methods (Static, Access = public)
        function success = analyseMovie(...
                analysisSettings,...
                loadPath,...
                movieFileName,...
                savePath)
            
            analysisEngine = TirfAnalysis.Fitting.AnalysisEngine(...
                analysisSettings,loadPath,movieFileName);
        
            [success, movieResult] = analysisEngine.runAnalysis;
            
            if success
                saveFile = ...
                    [movieFileName(1:end-5) analysisEngine.FILE_APPEND];
                saveFullPath = fullfile(savePath,saveFile);
                save(saveFullPath,'movieResult');
            end
        end
            
    end
end
            
            
            
            
            