classdef Detection < TirfAnalysis.Reg.AbstractDetection
    properties (Constant = true, Access = protected)
        DFT_BLUR_SIG = 2 % for blurring before particle detection
        % roughly the spot size
        DFT_PEAK_FAC = 3 % 0.05 % peaks are >2% higher than background
        DFT_KERNEL_FAC = 2 % kernel size and background are this many times
        % the blurring sigma
        % image fitting upper and lower bounds
        DFT_IMSIG_MIN = 0.5
        DFT_IMSIG_MAX = 3
        DFT_OPTIMSET = [0 1e-4 1e-5 10 10e3] % [verbose, e_1, e_2, e_3, nIt]
        % the kernel sigma
        % the fitting procedure - start with sigma = 8 for the gaussian
        % costs and then move down in steps
        DFT_SIG_SER = [8 5 2 1 0.1]
    end
    methods (Static, Access = public)
        % @Override from AbstractDetection
        function [xPeakPos, yPeakPos, xPeakSig, yPeakSig] = ...
                findPeakPos(data,sig,peakFac,kFac)
            % finds the positions of peaks (i.e. particles in our data)
            if nargin < 2
                sig = TirfAnalysis.Reg.Detection.DFT_BLUR_SIG;
            end
            if nargin < 3
                peakFac = TirfAnalysis.Reg.Detection.DFT_PEAK_FAC;
            end
            if nargin < 4
                kFac = TirfAnalysis.Reg.Detection.DFT_KERNEL_FAC;
            end
            % apply a gaussian blur for noise filtering
            if sig == 0
                blurData = data;
            else
                blurData = ...
                    imfilter(data,...
                    fspecial('Gaussian',ceil(kFac*sig),sig),...
                    'replicate');
            end
            % if we are using peakFac as a fraction then normalise between
            % zero and one
            % otherwise, just use blurData as it is
            if peakFac < 1
                normData = ...
                    (blurData - min(blurData(:)))...
                    ./(max(blurData(:)) - min(blurData(:)));
            else
                normData = blurData;
            end
            % compare each pixel to the background around it
            bgdRad = ceil(kFac*sig); % where we look for our background
            
            if bgdRad == 0
                bgdRad = kFac;
            end
            
            peakArray = zeros(size(data));
            
            % use a convolution to work out the background
            kernelBgd = zeros(bgdRad*2+1);
            kernelBgd([1 end],:) = 1;
            kernelBgd(:,[1 end]) = 1;
            kernelBgd = kernelBgd./sum(kernelBgd(:));
            
            meanBgdArray = conv2(normData,kernelBgd,'same');
            
            for iPx = 1+bgdRad:size(normData,1)-bgdRad
                for jPx = 1+bgdRad:size(normData,2)-bgdRad
                    % loop over all pixels
                    
                    % use convolution background
                    meanBgd = meanBgdArray(iPx,jPx);
                    
                    neighbours = ...
                        normData(iPx-bgdRad:iPx+bgdRad,jPx-bgdRad:jPx+bgdRad);
                    neighbours(bgdRad+1,bgdRad+1) = 0;
                    
                    if normData(iPx,jPx) > meanBgd + peakFac && ...
                            all(normData(iPx,jPx) > neighbours(:))
                        peakArray(iPx,jPx) = 1;
                    end
                end % loop over jPx
            end % loop over iPx
            
            % find the peak positions and return them
            [yPeakPosRough, xPeakPosRough] = find(peakArray);
            
            
            % we can improve on this by performing fits to the peak
            % positions
            nPeaks = length(yPeakPosRough);
            xPeakPos = zeros(size(xPeakPosRough));
            yPeakPos = zeros(size(yPeakPosRough));
            xPeakSig = zeros(size(yPeakPosRough));
            yPeakSig = zeros(size(yPeakPosRough));
            
            % import the elliptical gaussian fitting function
            import TirfAnalysis.Fitting.GaussFitTools_bin_Win64.gaussfit_free_elliptical
            % use the class default optimisation settings
            sigMin = TirfAnalysis.Reg.Detection.DFT_IMSIG_MIN;
            sigMax = TirfAnalysis.Reg.Detection.DFT_IMSIG_MAX;
            optimSettings = TirfAnalysis.Reg.Detection.DFT_OPTIMSET;
            
            % loop over peaks
            for iPeak = 1:nPeaks
                iPx = yPeakPosRough(iPeak);
                jPx = xPeakPosRough(iPeak);
                subRegion = ...
                    data(iPx-bgdRad:iPx+bgdRad,jPx-bgdRad:jPx+bgdRad);
                minSubRegion = min(subRegion(:));
                maxSubRegion = max(subRegion(:));
                
                initialGuess = ...
                    [maxSubRegion,...
                    (sigMin+sigMax)*0.5,...
                    (sigMin+sigMax)*0.5,...
                    minSubRegion,...
                    1+bgdRad,... % x-position
                    1+bgdRad,... % y-position
                    0]; % zero at end is theta guess
                
                [~, fitParams] = ...
                    gaussfit_free_elliptical(...
                    subRegion,...
                    sigMin,sigMax,...
                    sigMin,sigMax,...
                    0.5*(1+bgdRad),1.5*(1+bgdRad),...
                    0.5*(1+bgdRad),1.5*(1+bgdRad),...
                    1,initialGuess,...
                    optimSettings);
                
                % extract the fit peak, accounting for the offset in
                % the fit - i.e. moving back into the whole image
                % coordinates, rather than the sub-image
                xPeakPos(iPeak) = fitParams(5) + ...
                    xPeakPosRough(iPeak) - (1+bgdRad);
                yPeakPos(iPeak) = fitParams(6) + ...
                    yPeakPosRough(iPeak) - (1+bgdRad);
                xPeakSig(iPeak) = fitParams(2);
                yPeakSig(iPeak) = fitParams(3);
            end % loop over peaks for fitting
            
        end % function findPeakPos
        
        function [p2dTform] = pointsTransform(staticPoints, movingPoints)
            % tries to find a transform [x y 1] = [u v 1] * T, where u,v is
            % in the old co-ordinate system and x,y is in the new one
            % (which is the reference one)
            
            % define the cost function
            function costForPoints = nCostFun(queryPoints,staticPoints,sigCost)
                costForPoints = zeros(size(queryPoints,1),1);
                for iPoint = 1:size(staticPoints,1)
                    % loop over the reference (static) points
                    costForPoints = costForPoints + ...
                        exp((-(queryPoints(:,1)-staticPoints(iPoint,1)).^2 ...
                        -(queryPoints(:,2)-staticPoints(iPoint,2)).^2)./...
                        (2*sigCost.^2));
                end
            end % function nCostFun
            
            % define the objective function
            function objectiveVal = nObjectiveFun(tform,staticPoints,movingPoints,sigCost,tformObj)
                % function to minimise to optimise the transform
                tformObj.T = tform;
                M = tform;
                transformedPoints = zeros(size(movingPoints,1),3);
                % transform the moving points
                for iPoint = 1:size(movingPoints,1)
                    
                    % try replacing the transform using the object with a
                    % simple transform (with no arg checking)
                    u = movingPoints(iPoint,1);
                    v = movingPoints(iPoint,2);
                    
                    x = M(1,1).*u + M(2,1).*v + M(3,1);
                    y = M(1,2).*u + M(2,2).*v + M(3,2);
                    z = M(1,3).*u + M(2,3).*v + M(3,3);
                    
                    transformedPoints(iPoint,1:2) = [x./z, y./z];
                    % ---- original method using tform.transform.... -----
                    %                     [xPoint, yPoint] = ...
                    %                         tformObj.transformPointsForward(...
                    %                         movingPoints(iPoint,1),movingPoints(iPoint,2));
                    %                     transformedPoints(iPoint,1:2) = [xPoint, yPoint];
                end
                transformedPoints = transformedPoints(:,1:2); % strip out the ones
                costForPoints = ...
                    nCostFun(transformedPoints,staticPoints,sigCost);
                
                % the objective, which we are minimising is the negative
                % summed cost
                objectiveVal = -sum(costForPoints);
            end % function nObjectiveFun
            
            tformOpt = eye(3); % initial guess of the transform
            tformObj =  projective2d(tformOpt);
            
            % optimise with fminsearch
            sigCost = TirfAnalysis.Reg.Detection.DFT_SIG_SER; % reduce sigma each time
            % set the number of evaluations higher
            options = optimset('fminsearch');
            options.MaxFunEvals = 5e3;
            options.MaxIter = 5e3;
            options.Display = 'none';
            
            for iSigma = 1:length(sigCost)
                sigma = sigCost(iSigma);
                [tformOpt, ~, exFlag, ~] = fminsearch(...
                    @(tform) nObjectiveFun(...
                    tform,...
                    staticPoints,...
                    movingPoints,...
                    sigma,...
                    tformObj),...
                    tformOpt,...
                    options);
            end
            
            if exFlag == 0
                fprintf('\nWarning! Registration not converged\n')
            end
            
            p2dTform =  projective2d(tformOpt);
            
        end % function pointsTransform
        
        % function to find points and perform the transform then output a
        % summary statistic (distribution of errors)
        function [tformInfo3, positionsInRed] = threeColorTransform(threeColorBeadsMovie)
            % function that generates a three-color transform which
            % contains the image boundary information as well
            % extract individual frames
            % positions in red is a cell array of nx2 doubles which are the
            % {greenBeads, redBeads, nirBeads} all in red co-ords
            greenFrame = threeColorBeadsMovie.getGreenFrame;
            redFrame = threeColorBeadsMovie.getRedFrame;
            nirFrame = threeColorBeadsMovie.getNirFrame;
            
            greenLimits = threeColorBeadsMovie.getGreenLimits;
            redLimits = threeColorBeadsMovie.getRedLimits;
            nirLimits = threeColorBeadsMovie.getNirLimits;
            
            % extract peak positions
            [xPeakPosGreen,yPeakPosGreen] = ...
                TirfAnalysis.Reg.Detection.findPeakPos(greenFrame);
            
            [xPeakPosRed,yPeakPosRed] = ...
                TirfAnalysis.Reg.Detection.findPeakPos(redFrame);
            
            [xPeakPosNir,yPeakPosNir] = ...
                TirfAnalysis.Reg.Detection.findPeakPos(nirFrame);
            
            % build a transform between the channels
            
            tform2dG2R = ...
                TirfAnalysis.Reg.Detection.pointsTransform(...
                [xPeakPosRed,yPeakPosRed],...
                [xPeakPosGreen, yPeakPosGreen]);
            
            tform2dN2R = ...
                TirfAnalysis.Reg.Detection.pointsTransform(...
                [xPeakPosRed,yPeakPosRed],...
                [xPeakPosNir, yPeakPosNir]);
            
            % apply them to our bead positions
            
            [xGreenInRed, yGreenInRed] = ...
                tform2dG2R.transformPointsForward(xPeakPosGreen,yPeakPosGreen);
            
            [xNirInRed, yNirInRed] = ...
                tform2dN2R.transformPointsForward(xPeakPosNir,yPeakPosNir);
            
            % find the nearest point (in green and nir) for each red point
            greenDist = zeros(size(xPeakPosRed));
            nirDist = zeros(size(xPeakPosRed));
            for iRedPeak = 1:length(xPeakPosRed)
                % what is this red peak's position
                xPosRed = xPeakPosRed(iRedPeak);
                yPosRed = yPeakPosRed(iRedPeak);
                % find its nearest green peak (in red coordinates)
                greenDist(iRedPeak) = ...
                    min(hypot(xGreenInRed-xPosRed,yGreenInRed-yPosRed));
                nirDist(iRedPeak) = ...
                    min(hypot(xNirInRed-xPosRed,yNirInRed-yPosRed));
            end
            
            % construct the TformInfo3 object
            tformInfo3 = ...
                TirfAnalysis.Reg.TformInfo3(...
                tform2dG2R,...
                tform2dN2R,...
                greenLimits,...
                redLimits,...
                nirLimits,...
                greenDist,...
                nirDist);
            
            % return the bead positions (after transformation) used
            positionsInRed = {...
                [xGreenInRed, yGreenInRed],...
                [xPeakPosRed,yPeakPosRed],...
                [xNirInRed, yNirInRed]};
            
        end % function threeColorTransform
    end
end
