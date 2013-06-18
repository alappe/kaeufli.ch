# GET home page.
routes = (app) ->
  app.get '/', (request, response) ->
    response.render 'index',
      title: 'Start'

  app.get '/imprint', (request, response) ->
    response.render 'imprint',
      title: 'Imprint'

  app.get '/robots.txt', (request, response) ->
    response.set 'Content-Type', 'text/plain'
    robot = """
    User-agent: *
    Disallow:/references/admin/
    """
    response.send 200, robot

module.exports = routes
