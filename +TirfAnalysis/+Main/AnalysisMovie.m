classdef AnalysisMovie < TirfAnalysis.Movie.ThreeColorMovie
    properties (Access = protected)
        
        MovieMetadata % frTime and alexSequence
        AnalysisSettings
        
        % logical arrays for indexing into the movie for particular
        % illumination conditions
        GreenFrames % D exc
        RedFrames % T exc
        NirFrames % A exc
        
        % frame time associated with a particular illumination
        GreenFrTimes % the time (in seconds) of each green frame's start
        RedFrTimes
        NirFrTimes
        
        % found peak positions
        DDPositions
        DTPositions
        DAPositions
        TTPositions
        TAPositions
        AAPositions
        
        % linked positions
        LinkedPos % LinkedPos(:,:) = [linkPosRedX(:), linkPosRedY(:)]
        
        
        % Properties inherited from ThreeColorMovie
        
        % TirfMovie (inherits from AbstractMovie)
        % GreenLimits
        % RedLimits
        % NirLimits
        
    end
    
    properties (Constant, Access = public)
        VERBOSE = 0;
    end
    
    methods (Access = public)
        % constructor
        function obj = ...
                AnalysisMovie(tirfMovie,movieMetadata,analysisSettings)
            
            greenLimits = analysisSettings.getGreenLimits;
            redLimits = analysisSettings.getRedLimits;
            nirLimits = analysisSettings.getNirLimits;
            
            obj = ...
                obj@TirfAnalysis.Movie.ThreeColorMovie(...
                tirfMovie,greenLimits,redLimits,nirLimits);
            
            obj.MovieMetadata = movieMetadata;
            obj.AnalysisSettings = analysisSettings;
            
            %% Extract the illumination conditions
            alexSeq = obj.MovieMetadata.alexSequence;
            greenSeq = alexSeq(1,:);
            redSeq = alexSeq(2,:);
            nirSeq = alexSeq(3,:);
            
            nFrames = obj.TirfMovie.getNFrames;
            
            seqLength = size(alexSeq,2);
            
            greenFrames = repmat(greenSeq,1,ceil(nFrames/seqLength));
            redFrames = repmat(redSeq,1,ceil(nFrames/seqLength));
            nirFrames = repmat(nirSeq,1,ceil(nFrames/seqLength));
            
            obj.GreenFrames = logical(greenFrames(1:nFrames));
            obj.RedFrames = logical(redFrames(1:nFrames));
            obj.NirFrames = logical(nirFrames(1:nFrames));
            
            frameTimes = obj.MovieMetadata.frTime*(1:nFrames);
            
            obj.GreenFrTimes = frameTimes(obj.GreenFrames);
            obj.RedFrTimes = frameTimes(obj.RedFrames);
            obj.NirFrTimes = frameTimes(obj.NirFrames);
            
            %% Extract the peak positions using the analysis settings
            smoothKernel = obj.AnalysisSettings.getSmoothKernel;
            peakThresh = obj.AnalysisSettings.getPeakThresh;
            bgdRadiusFac = obj.AnalysisSettings.getBgdRadiusFac;
            
            filtWid = obj.AnalysisSettings.getFilteringWid;
            filtWidMin = min(filtWid); filtWidMax = max(filtWid);
            
            filtEllip = obj.AnalysisSettings.getFilteringEllip;
            
            frameCell = {...
                obj.getMeanDDFrame,...
                obj.getMeanDTFrame,...
                obj.getMeanDAFrame,...
                obj.getMeanTTFrame,...
                obj.getMeanTAFrame,...
                obj.getMeanAAFrame};
            peaksCell = cell(size(frameCell));
            
            peakFacToUse = [1, 2, 3, 2, 3, 3];
            % defines which factor to use for which channel
            % i.e. green (emission) channel is 1
            %      red is 2
            %      NIR is 3
            
            for iChannel = 1:length(frameCell)
                if obj.VERBOSE
                    fprintf('\nFinding Peaks %i/%i',...
                        iChannel,length(frameCell));
                end
                frame = frameCell{iChannel};
                if any(isnan(frame(:)))
                    peaksCell{iChannel} = [];
                else % i.e. this is a valid illumination condition
                    % extract the peaks from the movie frame
                    [xPeakPos, yPeakPos, xPeakSig, yPeakSig] = ...
                        TirfAnalysis.Reg.Detection.findPeakPos(...
                        frame,...
                        smoothKernel,...
                        peakThresh(peakFacToUse(iChannel)),...
                        bgdRadiusFac);
                    % filter based on nearest neighbour limit
                    neighLim = obj.AnalysisSettings.getNearNeighLim;
                    
                    xDif = bsxfun(@minus,xPeakPos(:),xPeakPos(:)');
                    yDif = bsxfun(@minus,yPeakPos(:),yPeakPos(:)');
                    
                    pairDist = hypot(xDif,yDif);
                    
                    nWithinDist = sum(pairDist<=neighLim,2);
                    
                    
                    
                    % filter based on the ellipticity and on image widths
                    ellipticity = ...
                        min(...
                        [xPeakSig(:)./yPeakSig(:),...
                        yPeakSig(:)./xPeakSig(:)],...
                        [],2);
                    peakPos = [xPeakPos(:),yPeakPos(:)];
                    sig = mean([xPeakSig(:),yPeakSig(:)],2);
                    peakPos = peakPos(...
                        sig < filtWidMax & sig > filtWidMin & ...
                        ellipticity > filtEllip & ...
                        nWithinDist < 2,:);
                    peaksCell{iChannel} = peakPos;
                end % if-else on nan's in movie data
            end % loop over channels
            
            if obj.VERBOSE
                fprintf('\nDone!\n');
            end
            
            obj.DDPositions = peaksCell{1};
            obj.DTPositions = peaksCell{2};
            obj.DAPositions = peaksCell{3};
            obj.TTPositions = peaksCell{4};
            obj.TAPositions = peaksCell{5};
            obj.AAPositions = peaksCell{6};
            
            %% link between channels
            obj.linkParticles;
            % this sets the LinkedPos Property
        end
        
        % @Override from ThreeColorMovie (just adds an averaging syntax)
        function greenFrame = getGreenFrame(obj,frameNum)
            if nargin > 1 % if we supply a specific frame
                greenFrame = ...
                    getGreenFrame@TirfAnalysis.Movie.ThreeColorMovie(...
                    obj,...
                    frameNum);
            else
                greenFrame = mean(...
                    getGreenFrame@TirfAnalysis.Movie.ThreeColorMovie(...
                    obj,...
                    1:obj.AnalysisSettings.getNFrames)...
                    ,3);
            end
        end       
        % @Override from ThreeColorMovie (just adds an averaging syntax)
        function redFrame = getRedFrame(obj,frameNum)
            if nargin > 1 % if we supply a specific frame
                redFrame = ...
                    getRedFrame@TirfAnalysis.Movie.ThreeColorMovie(...
                    obj,...
                    frameNum);
            else
                redFrame = mean(...
                    getRedFrame@TirfAnalysis.Movie.ThreeColorMovie(...
                    obj,...
                    1:obj.AnalysisSettings.getNFrames)...
                    ,3);
            end
        end       
        % @Override from ThreeColorMovie (just adds an averaging syntax)
        function nirFrame = getNirFrame(obj,frameNum)
            if nargin > 1 % if we supply a specific frame
                nirFrame = ...
                    getNirFrame@TirfAnalysis.Movie.ThreeColorMovie(...
                    obj,...
                    frameNum);
            else
                nirFrame = mean(...
                    getNirFrame@TirfAnalysis.Movie.ThreeColorMovie(...
                    obj,...
                    1:obj.AnalysisSettings.getNFrames)...
                    ,3);
            end
        end
        
        function greenFrameTimes = getGreenFrameTimes(obj)
            greenFrameTimes = obj.GreenFrTimes;
        end
        function redFrameTimes = getRedFrameTimes(obj)
            redFrameTimes = obj.RedFrTimes;
        end
        function nirFrameTimes = getNirFrameTimes(obj)
            nirFrameTimes = obj.NirFrTimes;
        end        
        
        % Getters for illumination/channel frames
        % if there are no frames with a particular illumination then frames
        % is an empty nyPix x nxPix x 0 matrix
        function frames = getDDFrames(obj)
            frames = obj.getGreenFrame(obj.GreenFrames);
        end
        function frames = getDTFrames(obj)
            frames = obj.getRedFrame(obj.GreenFrames);
        end
        function frames = getDAFrames(obj)
            frames = obj.getNirFrame(obj.GreenFrames);
        end
        function frames = getTTFrames(obj)
            frames = obj.getRedFrame(obj.RedFrames);
        end
        function frames = getTAFrames(obj)
            frames = obj.getNirFrame(obj.RedFrames);
        end
        function frames = getAAFrames(obj)
            frames = obj.getNirFrame(obj.NirFrames);
        end
        
        % getters for the averaged starting frames used for particle
        % detection
        % if there are no frames with a particular illumination, then frame
        % is a matrix of 1s nyPix x nxPix in dimension
        function frame = getMeanDDFrame(obj)
            frame = getMeanFrame(obj,@obj.getDDFrames);
        end
        function frame = getMeanDTFrame(obj)
            frame = getMeanFrame(obj,@obj.getDTFrames);
        end
        function frame = getMeanDAFrame(obj)
            frame = getMeanFrame(obj,@obj.getDAFrames);
        end
        function frame = getMeanTTFrame(obj)
            frame = getMeanFrame(obj,@obj.getTTFrames);
        end
        function frame = getMeanTAFrame(obj)
            frame = getMeanFrame(obj,@obj.getTAFrames);
        end
        function frame = getMeanAAFrame(obj)
            frame = getMeanFrame(obj,@obj.getAAFrames);
        end
        
        
        
        % Getter for the analysis settings
        function analysisSettings = getAnalysisSettings(obj)
            analysisSettings = obj.AnalysisSettings;
        end
        
        % Getters for the detection results
        function ddPos = getDdPos(obj)
            ddPos = obj.DDPositions;
        end
        function dtPos = getDtPos(obj)
            dtPos = obj.DTPositions;
        end
        function daPos = getDaPos(obj)
            daPos = obj.DAPositions;
        end
        function ttPos = getTtPos(obj)
            ttPos = obj.TTPositions;
        end
        function taPos = getTaPos(obj)
            taPos = obj.TAPositions;
        end
        function aaPos = getAaPos(obj)
            aaPos = obj.AAPositions;
        end
        
        
        % Getter for individual image stacks
        function [ddStacks,dtStacks,daStacks,ttStacks,taStacks,aaStacks,...
                    posGreen,posRed,posNir,...
                    originGreen,originRed,originNir] = ...
                getImageStacks(obj)
            % getImageStacks returns (for each channel) a RxRxFxM matrix of
            % pixel intensity values, where R is 2*window_radius + 1, F is
            % the number of frames in the channel, and M is the number of
            % linked particles.
            % the origin positions of the fitting squares are given, to
            % convert any fit positions back to true (in channel) positions
            % then we need to add this position to the output of any
            % gaussian fit
            
            windowRad = obj.AnalysisSettings.getWindowRad;
            [posGreen, posRed, posNir] = getLinkedPos(obj);
            numLink = size(posGreen,1);
            
            import TirfAnalysis.Main.AnalysisMovie
            
            [ddStacks, ddFrames] = ...
                AnalysisMovie.allocateStacks(...
                @obj.getDDFrames,windowRad,numLink);
            [dtStacks, dtFrames] = ...
                AnalysisMovie.allocateStacks(...
                @obj.getDTFrames,windowRad,numLink);
            [daStacks, daFrames] = ...
                AnalysisMovie.allocateStacks(...
                @obj.getDAFrames,windowRad,numLink);
            [ttStacks, ttFrames] = ...
                AnalysisMovie.allocateStacks(...
                @obj.getTTFrames,windowRad,numLink);
            [taStacks, taFrames] = ...
                AnalysisMovie.allocateStacks(...
                @obj.getTAFrames,windowRad,numLink);
            [aaStacks, aaFrames] = ...
                AnalysisMovie.allocateStacks(...
                @obj.getAAFrames,windowRad,numLink);
            
            originGreen = round(posGreen) - (1+windowRad);
            originRed = round(posRed) - (1+windowRad);
            originNir = round(posNir) - (1+windowRad);
            
            % loop over linked particles
            for iLink = 1:numLink    
                % N.B. pos(:,1) is the second movie dimension and pos(:,2)
                % is the first
                ddStacks(:,:,:,iLink) = ...
                    ddFrames(...
                    round(posGreen(iLink,2)-windowRad): ...
                    round(posGreen(iLink,2)+windowRad), ...
                    round(posGreen(iLink,1)-windowRad): ...
                    round(posGreen(iLink,1)+windowRad),:);
                dtStacks(:,:,:,iLink) = ...
                    dtFrames(...
                    round(posRed(iLink,2)-windowRad): ...
                    round(posRed(iLink,2)+windowRad), ...
                    round(posRed(iLink,1)-windowRad): ...
                    round(posRed(iLink,1)+windowRad),:);               
                daStacks(:,:,:,iLink) = ...
                    daFrames(...
                    round(posNir(iLink,2)-windowRad): ...
                    round(posNir(iLink,2)+windowRad), ...
                    round(posNir(iLink,1)-windowRad): ...
                    round(posNir(iLink,1)+windowRad),:);
                
                ttStacks(:,:,:,iLink) = ...
                    ttFrames(...
                    round(posRed(iLink,2)-windowRad): ...
                    round(posRed(iLink,2)+windowRad), ...
                    round(posRed(iLink,1)-windowRad): ...
                    round(posRed(iLink,1)+windowRad),:);
                taStacks(:,:,:,iLink) = ...
                    taFrames(...
                    round(posNir(iLink,2)-windowRad): ...
                    round(posNir(iLink,2)+windowRad), ...
                    round(posNir(iLink,1)-windowRad): ...
                    round(posNir(iLink,1)+windowRad),:);
                
                aaStacks(:,:,:,iLink) = ...
                    aaFrames(...
                    round(posNir(iLink,2)-windowRad): ...
                    round(posNir(iLink,2)+windowRad), ...
                    round(posNir(iLink,1)-windowRad): ...
                    round(posNir(iLink,1)+windowRad),:);                
            end   
        end
        
        function [posGreen, posRed, posNir] = getLinkedPos(obj)
            linkedPos = obj.LinkedPos;
            
            tform = obj.AnalysisSettings.getTform3;
            
            posGreen = tform.transformR2G(linkedPos);
            posRed = linkedPos;
            posNir = tform.transformR2N(linkedPos);
            
        end
        
        function movieMetadata = getMovieMetadata(obj)
            movieMetadata = obj.MovieMetadata;
        end
    end
    
    methods (Access = private, Static)
        % convenience function for allocating empty image stacks array
        function [emptyStacks, channelFrames] = ...
                allocateStacks(getFrameMethod,windowRad,numLink)
            channelFrames = getFrameMethod();
            emptyStacks = zeros(...
                windowRad*2 + 1,...
                windowRad*2 + 1,...
                size(channelFrames,3),...
                numLink);
        end
        
    end
    
    methods (Access = private)
        
        % helper for mean frame getter
        function frame = getMeanFrame(obj,getFrameMethod)
            frames = getFrameMethod();
            if isempty(frames)
                frame = zeros(size(frames,1),size(frames,2));
            else
                if obj.AnalysisSettings.getNFrames == 0 
                    frame = max(frames,[],3);
                else
                    lastFrame = ...
                        min(size(frames,3),obj.AnalysisSettings.getNFrames);
                    frame = mean(frames(:,:,1:lastFrame),3);
                end
            end
        end
        
        function linkParticles(obj)
            %% Linking algorithm - for setting the LinkedPos
            tform3 = obj.AnalysisSettings.getTform3;
            % convert all positions to red channel
            ddPos = tform3.transformG2R(obj.DDPositions);
            dtPos = obj.DTPositions;
            daPos = tform3.transformN2R(obj.DAPositions);
            ttPos = obj.TTPositions;
            taPos = tform3.transformN2R(obj.TAPositions);
            aaPos = tform3.transformN2R(obj.AAPositions);
            
            nearNeighLimSq = (obj.AnalysisSettings.getNearNeighLim()).^2;
            
            % check all channels for nearest neighbour distance violations
            posCell = {ddPos, dtPos, daPos, ttPos, taPos, aaPos};
            posCellOut = cell(size(posCell));
            for iChannel = 1:length(posCell)
                loopPos = ...
                    [posCell{iChannel}, ones(size(posCell{iChannel},1),1)];
                % loopPos(:,1) and loopPos(:,2) are positions and
                % loopPos(:,3) is a logical which is true if we want to
                % keep this localisation, and false if we don't
                for iPos = 1:size(loopPos,1)
                    if (sum(sum(...
                            bsxfun(@minus,...
                            loopPos(iPos,1:2),...
                            loopPos(:,1:2)).^2,2) < nearNeighLimSq) > 1)
                        % if any are too close to a neighbour
                        loopPos(iPos,3) = 0;
                    end
                end % loop over positions
                if isempty(loopPos)
                    goodPos = ones(0,2);
                else
                    goodPos = loopPos(logical(loopPos(:,3)),1:2);
                end
                posCellOut{iChannel} = goodPos;
            end % loop over channels (checking nearest neighbour violations
            
            [ddPos, dtPos, daPos, ttPos, taPos, aaPos] = ...
                deal(posCellOut{:});
            
            % the search radius in pixels
            searchRadSq = obj.AnalysisSettings.getLinkRadius^2;
            
            allPos = [...
                ddPos, ones(size(ddPos,1),1), 1*ones(size(ddPos,1),1);...
                dtPos, ones(size(dtPos,1),1), 2*ones(size(dtPos,1),1);...
                daPos, ones(size(daPos,1),1), 3*ones(size(daPos,1),1);...
                ttPos, ones(size(ttPos,1),1), 4*ones(size(ttPos,1),1);...
                taPos, ones(size(taPos,1),1), 5*ones(size(taPos,1),1);...
                aaPos, ones(size(aaPos,1),1), 6*ones(size(aaPos,1),1)];
            % this has the format [xPos, yPos, available, channelID]
            % where the positions are all mapped to the red channel, the
            % available flag tells us whether this point has been used in a
            % cluster already, and the channelID is DD:1, DT:2, DA:3, TT:4,
            % TA:5, AA:6 and lets us check what channel the clusters are
            % made up of
            
            foundClusters = cell(500,1); % preallocate to a sufficiently
            % large size that we don't expect
            % to have to increase its size
            nClusters = 0;
            
            for iPosStart = 1:size(allPos,1) % loop over localisations
                if allPos(iPosStart,3) % if this localisation is available
                    % set the starting localisation's flag to unavaliable
                    allPos(iPosStart,3) = 0;
                    % increment the cluster counter
                    nClusters = nClusters + 1;
                    % add this localisation to the currentCluster
                    foundClusters{nClusters} = allPos(iPosStart,:);
                    needsTesting = 1; % needs checking through
                    while needsTesting
                        needsTesting = 0; % escape the loop if we don't
                        % add a point to the cluster
                        for jPosTest = 1:size(allPos,1) % loop over test points
                            if allPos(jPosTest,3) && ...
                                    any(...
                                    sum(...
                                    bsxfun(...
                                    @minus,...
                                    foundClusters{nClusters}(:,1:2),...
                                    allPos(jPosTest,1:2)...
                                    ).^2 ...
                                    ,2)...
                                    < searchRadSq)
                                % if the point is available for clustering,
                                % and lies within a distance of searchRad
                                
                                % add it to the cluster
                                foundClusters{nClusters} = [...
                                    foundClusters{nClusters};...
                                    allPos(jPosTest,:)];
                                % set this point to unavailable for future
                                % clustering
                                allPos(jPosTest,3) = 0;
                                % set the flag that starts the testing
                                % again
                                needsTesting = 1;
                                % leave the for loop (and restart testing)
                                continue; % no point in testing later points
                                % since we are going to add them
                                % again
                            end % if compare whether point is added to cluster
                        end % loop over localisations to test against
                    end
                end % if the start localisation is available
            end % loop over localisations (starting)
            
            linkedPos = zeros(500,2); % initialise this for speed
            
            nKeep = 0;
            
            fitWindowRad = obj.AnalysisSettings.getWindowRad;
            
            
            greenLim = tform3.getGreenLimits;
            redLim = tform3.getRedLimits;
            nirLim = tform3.getNirLimits;
            
            greenXMax = greenLim(2) - greenLim(1) + 1;
            greenYMax = greenLim(4) - greenLim(3) + 1;
            redXMax = redLim(2) - redLim(1) + 1;
            redYMax = redLim(4) - redLim(3) + 1;
            nirXMax = nirLim(2) - nirLim(1) + 1;
            nirYMax = nirLim(4) - nirLim(3) + 1;
            
            
            checkBoundaryOk = @(pos,xmax,ymax) ...
                round(pos(1) - fitWindowRad) >= 1 && ...
                round(pos(1) + fitWindowRad) <= xmax && ...
                round(pos(2) - fitWindowRad) >=1 && ...
                round(pos(2) + fitWindowRad) < ymax;
            
            if nClusters > 0
                foundClusters = foundClusters(1:nClusters);
                
                keepClusters = cell(500,1);
                
                
                linkBoolFun = obj.AnalysisSettings.getLinkBoolFun;
                
                % sort the clusters (i.e. ones with two from the same
                % channel) and apply the linking function
                for iCluster = 1:size(foundClusters)
                    clusterPos = foundClusters{iCluster};
                    numChan(1) = sum(clusterPos(:,4) == 1,1);
                    numChan(2) = sum(clusterPos(:,4) == 2,1);
                    numChan(3) = sum(clusterPos(:,4) == 3,1);
                    numChan(4) = sum(clusterPos(:,4) == 4,1);
                    numChan(5) = sum(clusterPos(:,4) == 5,1);
                    numChan(6) = sum(clusterPos(:,4) == 6,1);
                    
                    
                    % test if we have multiple linked particles from same
                    % channel and if the user supplied linking function is
                    % ok
                    if all(numChan < 2) && ...
                            linkBoolFun(...
                            numChan(1),...
                            numChan(2),...
                            numChan(3),...
                            numChan(4),...
                            numChan(5),...
                            numChan(6))

                        meanPos = mean(clusterPos(:,1:2),1);
                        redPos = meanPos;
                        greenPos = tform3.transformR2G(meanPos);
                        nirPos = tform3.transformR2N(meanPos);
                        
                        if checkBoundaryOk(...
                                greenPos,greenXMax,greenYMax) && ...
                                checkBoundaryOk(...
                                redPos,redXMax,redYMax) && ...
                                checkBoundaryOk(...
                                nirPos,nirXMax,nirYMax)
                            nKeep = nKeep + 1;
                            % store the OK clusters
                            keepClusters{nKeep} = clusterPos;
                            % set the linked position to the mean cluster
                            % positon (in the red channel)
                            
                            linkedPos(nKeep,:) = meanPos;
                        end

                    end % check whether correct channels for linking
                    
                end % loop over found clusters
                
            end % if (we have found any clusters)
            
            if nKeep > 0
                linkedPos = linkedPos(1:nKeep,:);
            else
                linkedPos = [];
            end
            obj.LinkedPos = linkedPos;
            
        end % function linkParticles
    end
    
    methods (Static, Access = public)
        % for checking if metadata is present and the analysis settings are
        % suitable
        function [ok, fitsMovie, metadata] = ...
                checkIfOk(path,file,analysisSettings)
            
            ok = 0;
            fitsMovie = [];
            metadata = [];
            
            if ~isempty(file) && ~all(file == 0)
                fullPath = fullfile(path,file);
                fitsMovie = TirfAnalysis.Movie.FitsMovie(fullPath);
                [nxPix, nyPix] = fitsMovie.getNPix;
                % check if the movie is suitable for our transform
                if analysisSettings.getGreenLimits(2) ...
                        <= nxPix && ...
                        analysisSettings.getGreenLimits(4) ...
                        <= nyPix && ...
                        analysisSettings.getRedLimits(2) ...
                        <= nxPix && ...
                        analysisSettings.getRedLimits(4) ...
                        <= nyPix && ...
                        analysisSettings.getNirLimits(2) ...
                        <= nxPix && ...
                        analysisSettings.getNirLimits(4) ...
                        <= nyPix
                    % if the movie is large enough for the channel
                    % limits
                    metadataLoaded = 0;
                    try
                        metadata = ...
                            load(fullfile(path,[file(1:end-4) 'mat']));
                    catch
                        warning('Problem loading movie metadata');
                    end
                    if (isfield(metadata,'frTime') && ...
                            isfield(metadata,'alexSequence') && ...
                            size(metadata.alexSequence,1) == 3)
                        metadataLoaded = 1;
                    end
                    if metadataLoaded
                        ok = 1;
                    end
                end % if the movie is big enough for the tform3
            end % if the file selected is 'real'
            
            
            
        end
    end
end