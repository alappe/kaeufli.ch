# GET home page.
routes = (app) ->
  app.get '/', (request, response) ->
    response.render 'index', { title: 'Express' }

  app.get '/imprint', (request, response) ->
    response.render 'imprint'
      title: 'Imprint'

module.exports = routes
