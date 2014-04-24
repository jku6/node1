requirejs.config
  baseUrl: '/javascripts'
  paths:
    'jquery': "//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min"
    'raphael': "./raphael/raphael"
    'morris': "http://cdn.oesmith.co.uk/morris-0.5.0.min"
    'alertify': "./alertify/alertify"
    vendor: './vendor'
  shim:
    'jquery':
      exports: 'jQuery'
    'vendor/underscore':
      exports: '_'
    'vendor/handlebars':
      exports: 'Handlebars'
    'raphael':
      exports: 'Raphael'
    'morris':
      exports: 'Morris'
    'alertify':
      exports: 'Alertify'




dependencies = [
  'jquery'
  'vendor/underscore'
  'vendor/handlebars'
  'movie-ratings-service-client'
]

requirejs dependencies, ($, _, Handlebars, ratingsService) ->
  requirejs ['morris', 'raphael', 'alertify'], ->

    movieRatingsTemplate = """
                           <div class="movie-ratings">
                             {{#each movieRatings}}
                                <div class="movie-component">
                                  <span>Movie Name: {{@key}}</span>
                                  <span>Movie Ratings: {{this}}</span>
                                </div>
                             {{/each}}
                           </div>
                           """
    ratedMovieTemplate = """
                         <div class="rated-movie" id="{{movieName}}">
                           <div class="movie-name">{{movieName}}</div>
                           <div class="rating">{{rating}}</div>
                           <div class="edit">EDIT</div>
                           <div class="delete">DELETE</div>
                         </div>
                         """

    formTemplate =  """
                    <form id='create-movie'>
                      <h4>Rate new movies!</h4>
                      <input type='text' id='form-name' name='name' placeholder='Movie Name'>
                      <input type='text' id='form-rating' name='rating' placeholder='Rating'>
                      <input type='submit' value='Create' class='create-button'>
                    </form>
                    """


    movieRatingsSection = Handlebars.compile movieRatingsTemplate
    ratedMovieSection = Handlebars.compile ratedMovieTemplate
    formSection = Handlebars.compile formTemplate

    #GET
    ratingsService.getAllMovieRatings (ratings) ->
      $('body').append "<div id='container'></div>"
      $('body').append "<div id='newchart' style='height: 250px;'></div>"
      newdata = []
      for k, v of ratings
        i = 0
        sum = 0
        while i < v.length
          sum += parseInt(v[i])
          i++
        avg = sum/v.length
        newdata.push { y: k, a: avg.toFixed(1)}
      new Morris.Bar({
        element: 'newchart'
        data: newdata
        xkey: 'y'
        ykeys: ['a']
        labels: ['Movie Rating']
      })

      $('#container').append formSection
      $('#container').append "<div class='existing-movies-block'><h4>All Movies with at least 3 unique ratings</h4></div>"
      for movie of ratings
        do (movie) ->
          ratingsService.getMovieRating movie, (rating) ->
            $('.existing-movies-block').append ratedMovieSection { movieName: movie, rating: rating.toFixed(1) }
      $('#container').append movieRatingsSection { movieRatings: ratings }
      $('#container').append "<div class='data-click'>Movie Data</div>"
      $('.movie-ratings').hide()
      $(document).on 'click', '.data-click', ->
        $('.data-click').hide()
        $('.movie-ratings').show()
      $(document).on 'click', '.movie-ratings', ->
        $('.movie-ratings').hide()
        $('.data-click').show()


    #POST
    $(document).on 'submit', "#create-movie", (e) ->
      e.preventDefault()
      name = $("#form-name").val()
      rating = $("#form-rating").val()
      $.ajax
        type: 'post'
        url: "/api/movieratings/" + name
        data:
          rating: parseInt(rating)
        success: (response) ->

          define [".alertify/alertify"], (alertify) ->
            alertify.success "Success notification"

          if $("[id='#{name}']").length
            ratingsService.getMovieRating name, (newrating) ->
              $("[id='#{name}']").find(".rating").html(newrating.toFixed(1))
            ratingsService.getAllMovieRatings (ratings) ->
              $('.movie-ratings').remove()
              $('#newchart').html("")
              $('#container').append movieRatingsSection { movieRatings: ratings }
              $('.movie-ratings').hide()
              newdata = []
              for k, v of ratings
                i = 0
                sum = 0
                while i < v.length
                  sum += parseInt(v[i])
                  i++
                avg = sum/v.length
                newdata.push { y: k, a: Math.floor(avg * 100) / 100}
              new Morris.Bar({
                element: 'newchart'
                data: newdata
                xkey: 'y'
                ykeys: ['a']
                labels: ['Movie Rating']
              })
          else
            $(".existing-movies-block").append ratedMovieSection { movieName: name, rating: "*" }
            ratingsService.getAllMovieRatings (ratings) ->
              $('.movie-ratings').remove()
              $('#newchart').html("")
              $('#container').append movieRatingsSection { movieRatings: ratings }
              $('.movie-ratings').hide()
              newdata = []
              for k, v of ratings
                i = 0
                sum = 0
                while i < v.length
                  sum += parseInt(v[i])
                  i++
                avg = sum/v.length
                newdata.push { y: k, a: Math.floor(avg * 100) / 100}
              new Morris.Bar({
                element: 'newchart'
                data: newdata
                xkey: 'y'
                ykeys: ['a']
                labels: ['Movie Rating']
              })




    #PUT
    $(document).on 'click', ".edit", (object) ->
      movie = $(object.target).parent()
      movieName = movie.attr("id")
      newRating = prompt("Please enter the new rating for '#{movieName}'.","Must be at least 3 unique numbers")
      newRating = newRating.split(',')
      (parseInt(number) for number in newRating)
      $.ajax
        type: 'put'
        url: "/api/movieratings/" + movieName
        data: 
          ratings: newRating
        success: (response) ->
          ratingsService.getMovieRating movieName, (rating) ->
            movie.find(".rating").html(rating.toFixed(2))
          ratingsService.getAllMovieRatings (ratings) ->
              $('.movie-ratings').remove()
              $('#newchart').html("")
              $('#container').append movieRatingsSection { movieRatings: ratings }
              $('.movie-ratings').hide()
              newdata = []
              for k, v of ratings
                i = 0
                sum = 0
                while i < v.length
                  sum += parseInt(v[i])
                  i++
                avg = sum/v.length
                newdata.push { y: k, a: Math.floor(avg * 100) / 100}
              new Morris.Bar({
                element: 'newchart'
                data: newdata
                xkey: 'y'
                ykeys: ['a']
                labels: ['Movie Rating']
              })


    #DELETE
    $(document).on 'click', ".delete", (object) ->
      movie = $(object.target).parent()
      movieName = movie.attr("id")
      if confirm("Delete '#{movieName}' from database?")
        $.ajax
          type: 'delete'
          url: "/api/movieratings/" + movieName
          success: (response) ->
            movie.remove()
            ratingsService.getAllMovieRatings (ratings) ->
              $('.movie-ratings').remove()
              $('#newchart').html("")
              $('#container').append movieRatingsSection { movieRatings: ratings }
              $('.movie-ratings').hide()
              newdata = []
              for k, v of ratings
                i = 0
                sum = 0
                while i < v.length
                  sum += parseInt(v[i])
                  i++
                avg = sum/v.length
                newdata.push { y: k, a: Math.floor(avg * 100) / 100}
              new Morris.Bar({
                element: 'newchart'
                data: newdata
                xkey: 'y'
                ykeys: ['a']
                labels: ['Movie Rating']
              })






