_ = require 'underscore'

module.exports = (ratings, arg) ->

  if ratings instanceof Array and not arg?
    if _.uniq(ratings).length >= 3
      min = _.min(ratings)
      max = _.max(ratings)
      newArray = _.without(ratings, min, max)
      i = 0
      sum = 0
      while i < newArray.length
        sum += parseInt(newArray[i])
        i++
      avg = sum/newArray.length
      return avg
    else
      throw Error "Not enough ratings"
  else
    throw Error "Invalid arguments"