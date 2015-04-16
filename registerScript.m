% test script for user-input free image registration algorithm

greenLim = [339 511 1 512];
redLim = [173 338 1 512];
nirLim = [1 172 1 512];

beadsMovieName = 'Beads Leakage Full FOV 060515_9.fits';

% load the movie
fitsMovie = ...
    TirfAnalysis.Movie.FitsMovie(beadsMovieName);

% split the channels
beadsMovie = ...
    TirfAnalysis.Movie.ThreeColorBeadsMovie(...
    fitsMovie,...
    greenLim,...
    redLim,...
    nirLim);

% extract individual frames
greenFrame = beadsMovie.getGreenFrame;
redFrame = beadsMovie.getRedFrame;
nirFrame = beadsMovie.getNirFrame;

% extract peak positions
[xPeakPosGreen,yPeakPosGreen] = ...
    TirfAnalysis.Reg.Detection.findPeakPos(greenFrame);

[xPeakPosRed,yPeakPosRed] = ...
    TirfAnalysis.Reg.Detection.findPeakPos(redFrame);

[xPeakPosNir,yPeakPosNir] = ...
    TirfAnalysis.Reg.Detection.findPeakPos(nirFrame);

fprintf('\nPeaks found...\nRegistering green to red\n');

% build a transform between the channels

tform2dG2R = ...
    TirfAnalysis.Reg.Detection.pointsTransform(...
    [xPeakPosRed,yPeakPosRed],...
    [xPeakPosGreen, yPeakPosGreen]);

fprintf('...done!\nRegistering NIR to red\n');

tform2dN2R = ...
    TirfAnalysis.Reg.Detection.pointsTransform(...
    [xPeakPosRed,yPeakPosRed],...
    [xPeakPosNir, yPeakPosNir]);

fprintf('...done!\n');

% apply them to our bead positions

[xGreenInRed, yGreenInRed] = ...
    tform2dG2R.transformPointsForward(xPeakPosGreen,yPeakPosGreen);

[xNirInRed, uNirInRed] = ...
    tform2dN2R.transformPointsForward(xPeakPosNir,yPeakPosNir);

% plot these

plot(xPeakPosRed,yPeakPosRed,'+r',...
    xGreenInRed, yGreenInRed,'+g',...
    xNirInRed, yNirInRed,'+y');

