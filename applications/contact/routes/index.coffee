Contact = require "#{__dirname}/../models/contact"

routes = (app) ->
  app.namespace '/contact', ->
    app.get '/', (request, response) ->
      response.render "#{__dirname}/../views/index",
        title: 'Get in contact'
    app.post '/', (request, response) ->
      (new Contact request.body).handle (error, name) ->
        response.render "#{__dirname}/../views/sent",
          title: 'Got in contact'
          name: name

module.exports = routes
