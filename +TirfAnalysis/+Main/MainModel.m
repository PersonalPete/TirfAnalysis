classdef MainModel < TirfAnalysis.Main.AbstractMainModel
    % MainModel is the concrete implementation of the analysis model
    properties (SetAccess = protected)
        CurrentMovie
        MovieMetadata
        AnalysisSettings
        IsTransformLoaded = 0
        IsMovieLoaded = 0
    end
    
    properties (Constant = true)
        % where we store the default values for analysis settings
        DFT_PATH = '+TirfAnalysis\+Defaults\Current.mat'
    end
    
    events
        ViewNeedsUpdate
    end
    
    methods (Access = public)
        % constructor
        function obj = MainModel()
            
            % load the default analysis settings
            defaults = load(obj.DFT_PATH);
            tform3Blank = ...
                TirfAnalysis.Reg.TformInfo3(); % use the no arg constructor
            
            obj.AnalysisSettings = ...
                TirfAnalysis.Main.AnalysisSettings(...
                tform3Blank,...
                defaults.nFrames,...
                defaults.smoothKernel,...
                defaults.peakThresh,...
                defaults.bgdRadiusFac,...
                defaults.linkRadius,...
                defaults.linkBoolFun,...
                defaults.filteringEllip,...
                defaults.filteringWid,...
                defaults.fixedPos,...
                defaults.fixedWid,...
                defaults.ellipse,...
                defaults.posLim,...
                defaults.widLim);
            
        end % constructor
        
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function success = loadTransform(obj)
            % loads a three color transform object from a file
            success = 0;
            [file, path] = uigetfile('*.tform3.mat','Load 3 Color Transform');
            if ~isempty(file) && ~all(file == 0)
                loadData = load(fullfile(path,file));
                tform3 = loadData.tformInfo3;
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setTform3(tform3);
                obj.IsTransformLoaded = 1;
                success = 1;
            end
            notify(obj,'ViewNeedsUpdate');
        end
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function success = loadDisplayMovie(obj)
            % load a movie to display (for the sake of linking etc...)
            success = 0;
            if obj.IsTransformLoaded
                [file, path] = uigetfile('*.fits;*.FITS','Load Movie');
                if ~isempty(file) && ~all(file == 0)
                    fullPath = fullfile(path,file);
                    fitsMovie = TirfAnalysis.Movie.FitsMovie(fullPath);
                    [nxPix, nyPix] = fitsMovie.getNPix;
                    % check if the movie is suitable for our transform
                    if obj.AnalysisSettings.getGreenLimits(2) ...
                            <= nxPix && ...
                            obj.AnalysisSettings.getGreenLimits(4) ...
                            <= nyPix && ...
                            obj.AnalysisSettings.getRedLimits(2) ...
                            <= nxPix && ...
                            obj.AnalysisSettings.getRedLimits(4) ...
                            <= nyPix && ...
                            obj.AnalysisSettings.getNirLimits(2) ...
                            <= nxPix && ...
                            obj.AnalysisSettings.getNirLimits(4) ...
                            <= nyPix
                        % if the movie is large enough for the channel
                        % limits
                        metadataLoaded = 0;
                        try
                            movieMetadata = ...
                                load(fullfile(path,[file(1:end-4) 'mat']));                            
                        catch
                            warning('Problem loading movie metadata');
                        end
                        if (isfield(movieMetadata,'frTime') && ...
                                isfield(movieMetadata,'alexSequence') && ...
                                size(movieMetadata.alexSequence,1) == 3)
                            obj.MovieMetadata = movieMetadata;
                            metadataLoaded = 1;
                        end
                        if metadataLoaded
                            obj.CurrentMovie = fitsMovie;
                            obj.IsMovieLoaded = 1;
                            success = 1;
                        end
                    end % if the movie is big enough for the tform3
                end % if the file selected is 'real'
            end % if we have a transform loaded
            notify(obj,'ViewNeedsUpdate');
        end % loadDisplayMovie
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function setDetectionParameters(obj,nFrames,kernel,thresh,radFac)
            % sets the parameters used for detecting particles in each channel
            % nFrames is the number of frames to average over
            % kernel is the size of the smoothing kernel to apply (i.e.
            % gaussian low-pass)
            % thresh is the threshold i.e. peaks are at least thresh greater
            % than the background around them
            % background pixels are taken as ceil(kernel*radFac) away
            
            % Data validation - N.B. thresh has three elements
            if isnumeric(nFrames) && numel(kernel) == 1 && ...
                    isnumeric(kernel) && numel(kernel) == 1 && ...
                    isnumeric(thresh) && numel(thresh) == 3 && ...
                    isnumeric(radFac) && numel(radFac) == 1
                kernel = abs(kernel);
                radFac = abs(radFac);
                nFrames = max(1,round(abs(nFrames)));
                thresh = abs(thresh);
                
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setNFrames(nFrames);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setSmoothKernel(kernel);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setPeakThresh(thresh);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setBgdRadiusFac(radFac);
            end
            notify(obj,'ViewNeedsUpdate');
        end % setDetectionParameters
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function setLinkingRadius(obj,distance)
            % distance is the distance (in px) that we allow linkings between
            % channels to be at most
            if isnumeric(distance) && numel(distance) == 1
                distance = abs(distance);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setLinkRadius(distance);
            end
            notify(obj,'ViewNeedsUpdate');
        end % setLinkingRadius
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function setFiltering(obj,ellip,wid)
            % [greenEllip; redEllip,; nirEllip] (min ellipticity)
            % [greenMin, greenMax; redMin; redMax; nirMin, nirMax]
            % ellip is the minimum allowed ellipticity, wid is [minWid maxWid]
            % (in pixels)
            if isnumeric(ellip) && numel(ellip) == 3 &&...
                    isnumeric(wid) && all(size(wid) == [3,2]) && ...
                    all(wid > 0) && all(wid(:,2) > wid(:,1))
                ellip = abs(ellip);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setFilteringEllip(ellip);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setFilteringWid(wid);
            end
            notify(obj,'ViewNeedsUpdate');
        end % setFiltering
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function setChannelLinking(obj,linkBoolFun)
            % linkBoolFun is a handle to a function that accepts  6 args
            % link = linkBoolFun(DD,DT,DA,TT,TA,AA), where DD is true if there
            % is a DD particle found, and DT is true if there is a DT particle
            % found (etc...) and it returns true or false depending on whether
            % you want to accept a particle with these channel localisations
            % e.g. linkBoolFun = @(DD,DT,DA,TT,TA,AA) (DD & TT); would link
            % particles which have both a DD and a TT localisation
            if isa(linkBoolFun,'function_handle')
                if nargin(a) == 6
                    working = 0;
                    try
                        sizeIn = [5,1];
                        testInput = ones(sizeIn);
                        if all(size(linkBoolFun(...
                                testInput,testInput,testInput,...
                                testInput,testInput,testInput) == sizeIn))
                            working = 1;
                        end
                    catch
                        warning('Invalid linking function')
                    end
                    if working
                        obj.AnalysisSettings = ...
                            obj.AnalysisSettings.setLinkBoolFun(...
                            linkBoolFun);
                    end % if function works with test input
                end % if it is a function handle
            end
            notify(obj,'ViewNeedsUpdate');
        end % setChannelLinking
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function setAlgorithm(obj,fixedPos,fixedWid,elliptical)
            % choose the gaussian analysis algorithm - all arguments are
            % booleans saying whether we want to fix the position or width
            % parametes, and elliptical asks whether we want an elliptical
            % gaussian
            if isnumeric(fixedPos) && numel(fixedPos) == 1 && ...
                    isnumeric(fixedWid) && numel(fixedWid) == 1 && ...
                    isnumeric(elliptical) && numel(elliptical) == 1
                fixedPos = fixedPos >= 1;
                fixedWid = fixedWid >= 1;
                elliptical = elliptical >= 1;
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setFixedPos(fixedPos);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setFixedWid(fixedWid);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setEllipse(elliptical);
            end % data validation
            notify(obj,'ViewNeedsUpdate');
        end % setAlgorithm
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function setAlgorithmLimits(obj,posLim,widLims)
            % posLim is the maximum position change allowed
            % widLims = [minWid, maxWid]
            % of course, this can vary between channels
            if isnumeric(posLim) && numel(posLim) == 3 &&...
                    isnumeric(widLims) && ...
                    all((sizewidLimswid) == [3,2]) && ...
                    all(widLims > 0) && all(widLims(:,2) > widLims(:,1))
                posLim = abs(posLim);
                
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setPosLim(posLim);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setWidLim(widLims);
            end % data validation
            notify(obj,'ViewNeedsUpdate');
        end
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function runAnalysis(obj,filePaths)
            % analyse the data in the files specified (should accept both a
            % single string specifing a movie to analyse, and a cell array of
            % strings specfiying multiple files)
            if ~iscellstr(A)
                filePaths = {filePaths};
            end
            for iFile = 1:length(filePaths)
                fprintf('\nAnalysing (spoof): %s\n',filePaths{iFile});
            end
            
            %% TODO - WRITE THE ANALYSIS CODE THAT ACTUALLY RUNS...
            
        end
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function [analysisSettings, isTformLoaded, isMovieLoaded] ...
                = getAnalysisSettings(obj)
            analysisSettings = obj.AnalysisSettings;
            isTformLoaded = obj.IsTransformLoaded;
            isMovieLoaded = obj.IsMovieLoaded;
        end
        
        function [success, analysisMovie] = generateLinkMovie(obj)
            success = 0;
            analysisMovie = [];
            if obj.IsMovieLoaded && obj.IsTransformLoaded
                analysisMovie = ...
                    TirfAnalysis.Main.AnalysisMovie(...
                    obj.CurrentMovie,...
                    obj.MovieMetadata,...
                    obj.AnalysisSettings);
                success = 1;
            end % is movie and tform loaded
        end % generateLinkMovie
        
    end
end