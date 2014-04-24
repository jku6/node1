assert = require 'assert'
_ = require 'underscore'

MovieRatingsResource = require '../app/movie-ratings'

describe 'MovieRatingsResource', ->

  movieRatings = {}

  beforeEach ->
    movieRatings = new MovieRatingsResource
      'Bladerunner': [5, 1]
      'The Empire Strikes Back': [1, 1, 2, 3, 5]

  describe '#getAllMovieRatings()', ->

    it 'should return the correct ratings for all movies', ->
      assert.deepEqual movieRatings, movieRatings

  describe '#getMovieRatings()', ->

    it 'should return the correct movie ratings for the requested movie', ->
      assert.deepEqual [1,5], movieRatings.getMovieRatings("Bladerunner").sort (a, b) ->
        a - b

    it 'should throw an error if the requested movie does not exist in the repo', ->
      assert.throws (-> movieRatings.getMovieRatings("Jaws")), "Error"

  describe '#putMovieRatings()', ->

    it 'should put a new movie with ratings into the repo and return the ratings', ->
      assert.deepEqual [1,2,3,4], movieRatings.putMovieRatings("Jaws", [4,3,2,1]).sort (a, b) ->
        a - b

    it 'should overwrite the ratings of an existing movie in the repo and return the new ratings', ->
      assert.deepEqual [1,2,3,4], movieRatings.putMovieRatings("Bladerunner", [3,2,1,4]).sort (a, b) ->
        a - b

  describe '#postMovieRating()', ->

    it 'should put a new movie with rating into the repo if it does not already exist and return the rating', ->
      assert.deepEqual [5], movieRatings.postMovieRating("Red", 5).sort (a, b) ->
        a - b
    it 'should add a new rating to an existing movie in the repo and return the ratings', ->
      assert.deepEqual [1,3,5], movieRatings.postMovieRating("Bladerunner", 3).sort (a, b) ->
        a - b

  describe '#deleteMovieRatings()', ->

    it 'should delete a movie from the ratings repo', ->
      assert.deepEqual true, movieRatings.deleteMovieRatings("Bladerunner")

    it 'should throw an error when attempting to delete a movie that does not exist', ->
      assert.throws (-> movieRatings.deleteMovieRatings("Jaws")), "Error"