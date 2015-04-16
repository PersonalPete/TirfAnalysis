classdef (Abstract) AbstractMainModel < handle
    % AbstractMainModel defines the methods that the 3-color TIRF fitting
    % software main analysis class must implement
    methods (Access = public)
        %% setting up the analysis
        loadTransform(obj)
        % loads a three color transform object from a file
        
        loadDisplayMovie(obj)
        % load a movie to display (for the sake of linking etc...)
        
        setDetectionParameters(obj,nFrames,kernel,thresh,radFac)
        % sets the parameters used for detecting particles in each channel
        
        % nFrames is the number of frames to average over
        % kernel is the size of the smoothing kernel to apply (i.e.
        % gaussian low-pass)
        % thresh is the threshold i.e. peaks are at least thresh greater
        % than the background around them [green, red, nir]
        % background pixels are taken as ceil(kernel*radFac) away
        
        setLinkingRadius(obj,distance)
        % distance is the distance (in px) that we allow linkings between
        % channels to be at most
        
        setFiltering(obj,channel,ellip,wid)
        % ellip is the minimum allowed ellipticity, wid is [minWid maxWid]
        % (in pixels)
        
        setChannelLinking(obj,linkBoolFun)
        % linkBoolFun is a handle to a function that accepts  6 args
        % link = linkBoolFun(DD,DT,DA,TT,TA,AA), where DD is true if there
        % is a DD particle found, and DT is true if there is a DT particle
        % found (etc...) and it returns true or false depending on whether
        % you want to accept a particle with these channel localisations
        % e.g. linkBoolFun = @(DD,DT,DA,TT,TA,AA) (DD & TT); would link
        % particles which have both a DD and a TT localisation
        
        setAlgorithm(obj,fixedPos,fixedWid,elliptical)
        % choose the gaussian analysis algorithm - all arguments are
        % booleans saying whether we want to fix the position or width
        % parametes, and elliptical asks whether we want an elliptical
        % gaussian
        
        setAlgorithmLimits(obj,posLim,widLims)
        % posLim is the maximum position change allowed
        % widLims = [minWid, maxWid]
        % of course, this can vary between channels
        
        runAnalysis(obj,filePaths)
        % analyse the data in the files specified (should accept both a
        % single string specifing a movie to analyse, and a cell array of
        % strings specfiying multiple files)
        
        %% Getters for current state
        
        analysisSettings = getAnalysisSettings(obj)
        % Query the current analysis settings
    end
end