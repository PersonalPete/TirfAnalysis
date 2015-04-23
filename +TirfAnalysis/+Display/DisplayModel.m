classdef DisplayModel < handle
    % DisplayModel holds the data for the visualisation of analysis results
    properties (Access = protected)
        MovieResults % this is a cell array for multiple movies
        CurrentMovie