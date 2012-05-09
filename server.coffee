# Module dependencies.
express = require 'express'
namespace = require 'express-namespace'
#routes = require './routes'
Backbone = require 'backbone'

app = module.exports = express.createServer()
port = null

# Configuration
app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use (express.static __dirname + '/public')

app.configure 'development', ->
  port = 3000
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.configure 'production', ->
  port = 3000
  app.use express.errorHandler()

app.configure 'testing', ->
  port = 3001
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

# Helpers
# (require './applications/references/views/_helpers')(app)

# Routes
(require './routes')(app)
# (require './applications/references/routes')(app)


app.listen port, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
