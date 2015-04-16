classdef FitsMovie < TirfAnalysis.Movie.AbstractMovie
%% FitsMovie is the concrete movie class for reading in and accessing data
% from a FITS file
    methods (Access = public)
        function obj = FitsMovie(filename)
            obj.MovieInfo = filename;
            obj.MovieData = fitsread(filename);
        end
    end
end