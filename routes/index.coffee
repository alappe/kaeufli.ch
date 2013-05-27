# GET home page.
routes = (app) ->
  app.get '/', (request, response) ->
    response.render 'index',
      title: 'Start'

  app.get '/imprint', (request, response) ->
    response.render 'imprint',
      title: 'Imprint'

  app.get '/robots.txt', (request, response) ->
    robot = """
    User-agent: *
    Disallow:/references/admin/
    """
    response.send robot, 'Content-Type': 'text/plain', 200

module.exports = routes
