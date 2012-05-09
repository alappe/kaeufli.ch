Reference = require "#{__dirname}/../models/reference"

routes = (app) ->
  app.namespace '/references', ->

    # List of all references
    app.get '/', (request, response) ->
      Reference.all (error, references) ->
        if error
          console.log error
        else
          response.render "#{__dirname}/../views/index",
            title: 'Express References'
            references: references

    # Add a new reference
    app.post '/', (request, response) ->
      reference = new Reference()
      reference.parseForm {form: request.body}, ->
        console.log reference.toJSON()
        reference.save reference.toJSON(),
          error: (model, response) ->
            console.log 'ERROR'
            console.log response
          success: (model, response) ->
            console.log 'SUCCESS'
            #console.log model
            model.uploadImages request.files
      #console.log request.files

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
              title: "All projects tagged with »#{request.params.tag}«"
              references: references
              selectedTag: request.params.tag

    app.namespace '/admin', ->
      # Administer references…
      app.get '/', (request, response) ->
        response.render "#{__dirname}/../views/admin/index",
          title: "Admin"
          admin: true

      # Show the form for a new reference
      app.get '/new', (request, response) ->
        Reference.uuid (error, uuid) ->
          response.render "#{__dirname}/../views/admin/new",
            title: "new"
            uuid: uuid
            admin: true

    # Show a single reference
    app.get '/:title', (request, response) ->
      Reference.get request.params.title, (error, reference) ->
        if error
          console.log error
        else
          response.render "#{__dirname}/../views/show",
            title: reference.attributes.name
            reference: reference


module.exports = routes
