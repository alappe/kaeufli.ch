Reference = require "#{__dirname}/../models/reference"
restler = require 'restler'
buffertools = require 'buffertools'

routes = (app) ->
  app.namespace '/references', ->

    # List of all references
    app.get '/', (request, response) ->
      Reference.allPublished (error, references) ->
        if error
          console.log error
        else
          response.render "#{__dirname}/../views/index",
            title: 'References'
            references: references

    app.namespace '/tags', ->
      # List of all tags
      app.get '/', (request, response) ->
        Reference.allTags (error, tags) ->
          if error
            console.log error
          else
            response.render "#{__dirname}/../views/tags",
              title: 'All tags'
              tags: tags

      # List of all references that have :tag
      app.get '/:tag', (request, response) ->
        Reference.byTag request.params.tag, (error, references) ->
          if error
            console.log error
          else
            response.render "#{__dirname}/../views/index",
              title: "References tagged with »#{request.params.tag}«"
              references: references
              selectedTag: request.params.tag

    app.namespace '/admin', ->
      # Login form
      app.get '/login*', (request, response) ->
        response.render "#{__dirname}/../views/admin/login",
          title: 'Login'
      app.post '/login*', (request, response) ->
        nano = (require 'nano')('http://localhost:5984')
        auth =
          method: 'POST'
          db: '_session'
          form:
            name: request.body.username
            password: request.body.password
          content_type: 'application/x-www-form-urlencoded; charset=utf-8'
        nano.request auth, (error, body, headers) ->
          #console.log 'request done…'
          if error
            console.log error
            response.send error.error
            return
          else if headers and headers['set-cookie']
            response.cookie headers['set-cookie']
            if (request.param 'redirect')?
              response.redirect (request.param 'redirect')
            else
              response.redirect '/references/admin/'

      # Redirect if not authorized…
      app.all '/', (request, response, next) ->
        authenticated = request.cookies.authsession
        if authenticated
          next()
        else
          response.redirect "/references/admin/login?redirect=#{request.originalUrl}"
          return

      # Redirect if not authorized…
      # TODO: Find a way to combine the two .all routes…
      app.all '/*', (request, response, next) ->
        authenticated = request.cookies.authsession
        if authenticated
          next()
        else
          response.redirect "/references/admin/login?redirect=#{request.originalUrl}"
          return

      # Administer references…
      app.get '/', (request, response) ->
        Reference.all (error, references) ->
          if error
            console.log error
          else
            response.render "#{__dirname}/../views/admin/index",
              references: references
              title: "Admin"
              admin: true

      # Create a new reference
      app.get '/new', (request, response) ->
        Reference.save (new Reference()), (error, body) ->
          if error
            console.log 'error'
            console.log error
          else
            response.redirect "/references/admin/#{body.id}"

      # Edit a single reference
      app.get '/:id', (request, response) ->
        Reference.getById request.params.id, (error, reference) ->
          if error
            console.log error
          else
            if request.headers.accept?.match /^application\/json/
              response.contentType 'text/json'
              response.send (JSON.stringify reference.toJSON())
            else
              response.render "#{__dirname}/../views/admin/edit",
                title: reference.attributes.name
                reference: reference

      # Save a single reference
      app.put '/:id', (request, response) ->
        Reference.save request.body, (error, reference) ->
          if error
            console.log 'error!'
            console.log error
          else
            response.contentType 'application/json'
            response.send reference

      # Save an image
      app.post '/:title/images/', (request, response) ->
        payload = []
        request.on 'data', (data) ->
          console.log 'concatenating payload…'
          payload.push data
        request.on 'end', ->
          imageData = buffertools.concat.apply buffertools, payload
          console.log imageData
          Reference.get request.params.title, (error, reference) ->
            reference.addImage request, imageData, (error, imageResponse) ->
              console.log error
              response.contentType 'application/json'
              response.send imageResponse
      # Here ends the /admin area…

    # Show a single reference
    app.get '/:title', (request, response) ->
      Reference.get request.params.title, (error, reference) ->
        if error
          console.log error
        else
          response.render "#{__dirname}/../views/show",
            title: reference.attributes.name
            reference: reference

    # Shows an image of a single reference
    app.get '/:title/images/:id/', (request, response) ->
      Reference.get request.params.title, (error, reference) ->
        if error
          console.log 'now here'
          console.log error
          response.send 404
        else
          image = (reference.get '_attachments')[request.params.id]
          if image?
            options =
              decoding: 'buffer'
            url = reference.url() + "/#{request.params.id}"
            (restler.get url, options).on 'complete', (result) ->
              response.contentType image.content_type
              response.send result
          else
            console.log 'here'
            response.send 404

module.exports = routes
