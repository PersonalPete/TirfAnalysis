classdef MainModel < TirfAnalysis.Main.AbstractMainModel
    % MainModel is the concrete implementation of the analysis model
    properties (SetAccess = protected)
        CurrentMovie
        MovieMetadata
        AnalysisSettings
        IsTransformLoaded = 0
        IsMovieLoaded = 0
        
        % properties for the parallel analysis
        ParCluster
        Jobs
        LastStatus
        
        JobTimer
    end
    
    properties (Constant = true)
        % where we store the default values for analysis settings
        DFT_PATH = '+TirfAnalysis\+Defaults\Current.mat'
        % parallel cluster profile
        DFT_PROFILE = 'local'
        % timer period (for checking status of parcluster jobs)
        DFT_TIMER_PERIOD = 30 
        
        VERBOSE = 1
        
        ANALYSIS_FOLDER = 'tirf3Analysis'
        TFORM_FILE = '*.tform3.mat'
    end
    
    events
        ViewNeedsUpdate
        JobStatusChanged
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
                defaults.nearNeighLim,...
                defaults.filteringEllip,...
                defaults.filteringWid,...
                defaults.fixedPos,...
                defaults.fixedWid,...
                defaults.ellipse,...
                defaults.posLim,...
                defaults.widLim,...
                defaults.windowRad);
            
            % startup the parallel cluster
            obj.ParCluster = parcluster(obj.DFT_PROFILE);
           
            % timer for updating job status
            obj.JobTimer = timer('Busymode','drop',...
                'ExecutionMode','fixedSpacing',...
                'Period',obj.DFT_TIMER_PERIOD,...
                'TimerFcn',@(~,~) obj.checkJobStatus);
            
        end % constructor
        
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function success = loadTransform(obj)
            % loads a three color transform object from a file
            success = 0;
            [file, path] = uigetfile(obj.TFORM_FILE,'Load 3 Color Transform');
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
                
                import TirfAnalysis.Main.AnalysisMovie
                
                % check if the movie has metadata and matches the transform
                [ok, fitsMovie, metadata] = ...
                    AnalysisMovie.checkIfOk(...
                    path,file,obj.AnalysisSettings);
                
                
                
                if ok
                    obj.CurrentMovie = fitsMovie;
                    obj.MovieMetadata = metadata;
                    obj.IsMovieLoaded = 1;
                    success = 1;
                end
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
            if isnumeric(nFrames) && ~any(isnan(nFrames)) ...
                    && numel(nFrames) == 1 && ~any(isnan(kernel)) && ...
                    isnumeric(kernel) && numel(kernel) == 1 && ...
                    isnumeric(thresh) && numel(thresh) == 3 && ...
                    ~any(isnan(thresh)) && ...
                    isnumeric(radFac) && numel(radFac) == 1 && ...
                    ~any(isnan(radFac))
                kernel = abs(kernel);
                radFac = abs(radFac);
                % max frames can be zero - uses maximum detection method
                nFrames = max(0,round(abs(nFrames)));
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
            if isnumeric(distance) && numel(distance) == 1 && ...
                    ~any(isnan(distance))
                distance = abs(distance);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setLinkRadius(distance);
            end
            notify(obj,'ViewNeedsUpdate');
        end % setLinkingRadius
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function setFiltering(obj,ellip,wid,nearNeighLim)
            % [greenEllip; redEllip,; nirEllip] (min ellipticity)
            % [greenMin, greenMax; redMin; redMax; nirMin, nirMax]
            % ellip is the minimum allowed ellipticity, wid is [minWid maxWid]
            % (in pixels)
            if isnumeric(ellip) && numel(ellip) == 1 && ...
                    ~any(isnan(ellip)) && ...
                    isnumeric(wid) && all(size(wid) == [1,2]) && ...
                    all(wid > 0) && all(wid(:,2) > wid(:,1)) && ...
                    ~any(isnan(wid)) && ...
                    isnumeric(nearNeighLim) && ...
                    numel(nearNeighLim) == 1 && ~any(isnan(nearNeighLim))
                
                nearNeighLim = abs(nearNeighLim);
                ellip = abs(ellip);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setFilteringEllip(ellip);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setFilteringWid(wid);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setNearNeighLim(nearNeighLim);
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
                if nargin(linkBoolFun) == 6
                    working = 0;
                    try
                        sizeIn = [5,1];
                        testInput = ones(sizeIn);
                        if all(size(linkBoolFun(...
                                testInput,testInput,testInput,...
                                testInput,testInput,testInput)) == sizeIn)
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
            if (isnumeric(fixedPos) || islogical(fixedPos)) && ...
                    numel(fixedPos) == 1 && ...
                    ~any(isnan(fixedPos)) && ...
                    (isnumeric(fixedWid) || islogical(fixedWid)) && ...
                    numel(fixedWid) == 1 && ~any(isnan(fixedWid)) && ...
                    (isnumeric(elliptical) || islogical(elliptical)) && ...
                    numel(elliptical) == 1  && ~any(isnan(elliptical))
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
            if isnumeric(posLim) && numel(posLim) == 1 &&...
                    isnumeric(widLims) && ~any(isnan(widLims)) && ...
                    all(size(widLims) == [1,2]) && ...
                    ~any(isnan(widLims)) && ...
                    all(widLims > 0) && all(widLims(:,2) > widLims(:,1))
                posLim = abs(posLim);
                
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setPosLim(posLim);
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setWidLim(widLims);
            end % data validation
            notify(obj,'ViewNeedsUpdate');
        end
        
        function setWindowRad(obj,windowRad)
            if isnumeric(windowRad) && numel(windowRad) == 1 && ...
                    ~any(isnan(windowRad))
                windowRad = max(1,round(abs(windowRad)));
                obj.AnalysisSettings = ...
                    obj.AnalysisSettings.setWindowRad(windowRad);
            end
            notify(obj,'ViewNeedsUpdate');
        end
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function success = runAnalysis(obj)
            % analyse the data in the files specified
            % success indicates that we at least initiated the analysis
            success = 0;
            if obj.IsTransformLoaded
                % use the userinterface for file loading
                [file, loadPath] = uigetfile('*.fits;*.FITS','Load Movie',...
                    'Multiselect','on');
                if iscell(file) || ( ~isempty(file) && ~all(file == 0))
                    % make sure it is always a cell
                    if ~iscell(file)
                        file = {file};
                    end
                    
                    % make a folder to save the output into - mangle its
                    % name with the current time so that multiple runs land
                    % in different folders
                    c = clock;
                    saveFolderName = [obj.ANALYSIS_FOLDER, ...
                        sprintf('%i-%02i-%02i %02i%02i_%.0f',c)];
                    folderSuccess = mkdir(loadPath,saveFolderName);
                    
                    % if the folder is successfully created
                    if folderSuccess
                        savePath = fullfile(loadPath,saveFolderName);                    
                        nJobs = length(obj.Jobs);
                        alreadyStarted = 0;
                        for iMovie = 1:length(file)
                            % allocate storage for the job object
                            if (nJobs == 0 && ~alreadyStarted)% if it is the first job
                                obj.Jobs = obj.ParCluster.createJob;
                                alreadyStarted = 1;
                            else
                                obj.Jobs(nJobs + iMovie) = obj.ParCluster.createJob;
                            end
                            % create the task of analysing a particular file
                            obj.Jobs(nJobs + iMovie).createTask(...
                                @TirfAnalysis.Fitting.AnalysisEngine.analyseMovie,...
                                1,...
                                {obj.AnalysisSettings,...
                                loadPath,...
                                file{iMovie},...
                                savePath});
                            % submit the job to the cluster
                            obj.Jobs(nJobs + iMovie).submit;
                        end
                        success = 1;
                    end % if the folder to save to can be created
                end % if the file choice is valid
            end % if a transform is loaded
        end
        
        % @Override from TirfAnalysis.Main.AbstractMainModel
        function [analysisSettings, isTformLoaded, isMovieLoaded] ...
                = getAnalysisSettings(obj)
            analysisSettings = obj.AnalysisSettings;
            isTformLoaded = obj.IsTransformLoaded;
            isMovieLoaded = obj.IsMovieLoaded;
        end
        
        % performs particle detection and then links between channels
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
        
        % load and save analysis settings
        function saveCurrentSettings(obj,file,path)
            if nargin < 3
                [file, path] = ...
                    uiputfile('*.set3.mat','Save 3 Color Settings','');
            end
            if ~isempty(file) && all(file~=0)
                savePath = fullfile(path,file);
                % match the saved variables to the setting...
                
                as = obj.AnalysisSettings;
                
                nFrames = as.getNFrames;
                smoothKernel = as.getSmoothKernel;
                peakThresh = as.getPeakThresh;
                bgdRadiusFac = as.getBgdRadiusFac;
                linkRadius = as.getLinkRadius;
                linkBoolFun = as.getLinkBoolFun;
                nearNeighLim = as.getNearNeighLim;
                filteringEllip = as.getFilteringEllip;
                filteringWid = as.getFilteringWid;
                fixedPos = as.isFixedPos;
                fixedWid = as.isFixedWid;
                ellipse = as.isEllipse;
                posLim = as.getPosLim;
                widLim = as.getWidLim;
                windowRad = as.getWindowRad;
                
                save(savePath,...
                    'nFrames',...
                    'smoothKernel',...
                    'peakThresh',...
                    'bgdRadiusFac',...
                    'linkRadius',...
                    'linkBoolFun',...
                    'nearNeighLim',...
                    'filteringEllip',...
                    'filteringWid',...
                    'fixedPos',...
                    'fixedWid',...
                    'ellipse',...
                    'posLim',...
                    'widLim',...
                    'windowRad');
                
            end
        end
        
        function success = loadSettings(obj)
            % loads a three color transform object from a file
            success = 0;
            [file, path] = uigetfile('*.set3.mat','Load 3 Color Settings');
            if ~isempty(file) && ~all(file == 0)
                loaded = load(fullfile(path,file));
                % check it has the correct fields
                if all(isfield(loaded,...
                        {'nFrames',...
                        'smoothKernel',...
                        'peakThresh',...
                        'bgdRadiusFac',...
                        'linkRadius',...
                        'linkBoolFun',...
                        'nearNeighLim',...
                        'filteringEllip',...
                        'filteringWid',...
                        'fixedPos',...
                        'fixedWid',...
                        'ellipse',...
                        'posLim',...
                        'widLim',...
                        'windowRad'}))
                    obj.AnalysisSettings = ...
                        TirfAnalysis.Main.AnalysisSettings(...
                        obj.AnalysisSettings.getTform3,...
                        loaded.nFrames,...
                        loaded.smoothKernel,...
                        loaded.peakThresh,...
                        loaded.bgdRadiusFac,...
                        loaded.linkRadius,...
                        loaded.linkBoolFun,...
                        loaded.nearNeighLim,...
                        loaded.filteringEllip,...
                        loaded.filteringWid,...
                        loaded.fixedPos,...
                        loaded.fixedWid,...
                        loaded.ellipse,...
                        loaded.posLim,...
                        loaded.widLim,...
                        loaded.windowRad);
                    success = 1;
                end
            end
            notify(obj,'ViewNeedsUpdate');
        end
        
        
        function [nJobsPending, nJobsRunning, nJobsFinished, nJobsErr] ...
                = getJobStatus(obj)
            jobStates = obj.LastStatus;
            
            nJobsPending = ...
                sum(strcmp('pending',jobStates)) ...
                + sum(strcmp('queued',jobStates));
            
            nJobsRunning = ...
                sum(strcmp('running',jobStates));
            
            nJobsFinished = ...
                sum(strcmp('finished',jobStates));
            
            nJobsErr = ...
                sum(strcmp('failed',jobStates));
                
        end
        
        % delete method to close down the parallel cluster
        function delete(obj)
            nJobs = length(obj.Jobs);
            if obj.VERBOSE
                fprintf('\nClearing cluster jobs\n');
            end
            for iJob = 1:nJobs
                delete(obj.Jobs(iJob));
            end
            
            % stop and delete timer
            if isvalid(obj.JobTimer)
                try
                    stop(obj.JobTimer)
                catch
                    % timer must have already stopped?
                end
                delete(obj.JobTimer)
            end
        end
        
        % for the timer - i.e. check on jobs
        function checkJobStatus(obj,~,~)
            nJobs = length(obj.Jobs);
            lastStatus = obj.LastStatus;
            needToNotify = 0;
            % loop over created jobs
            for iJob = 1:nJobs
                status = obj.Jobs(iJob).State;
                if numel(lastStatus) < iJob || ~strcmp(lastStatus{iJob},status)
                    needToNotify = 1;
                    obj.LastStatus{iJob} = status;
                end
            end % loop over jobs
            if needToNotify
                notify(obj,'JobStatusChanged');
            end
        end
    end
end