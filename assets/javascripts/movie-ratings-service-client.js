// Generated by CoffeeScript 1.7.1
(function() {
  define(['jquery'], function($) {
    var module;
    module = {};
    module.getAllMovieRatings = function(callback) {
      return $.get('/api/movieratings', callback);
    };
    module.getMovieRating = function(movie, callback) {
      return $.get('/api/ratemovie/' + movie, callback);
    };
    return module;
  });

}).call(this);
