function tirf3Analysis
%% tirf3Analysis launches the launcher GUI for 3-color TIRF analysis
% This program was developed by Peter May (Kapanidis Group, Oxford
% University)
%
% Copyright (C) 2015 Peter F J May (pfjmay@gmail.com)
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% 
% This work depends on levmar for constrained Levenberg-Marquard fitting 
% (http://users.ics.forth.gr/~lourakis/levmar/index.html), and 
% gaussfitTools, written by Seamus Holden and Oliver Britton (of the
% Kapanidis Group, Oxford)
%
% To install, simply set path in matlab to the folder containing this file,
% and the folder '+TirfAnalysis'.
%
% To run, simply type tirf3Analysis at the MATLAB command line
    
    % build the launcher gui
    TirfAnalysis.Launcher.LaunchController.getInstance;
    
end