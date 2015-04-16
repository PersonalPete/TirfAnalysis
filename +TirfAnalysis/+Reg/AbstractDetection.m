classdef (Abstract) AbstractDetection
    %% AbstractDetection provides the interface for particle detection
    % routines
    methods (Access = public, Static)
        peakPositions = findPeakPos(data);        
        tformInfo3 = threeColorTransform(threeColorBeadsMovie)
    end
end