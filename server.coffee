# Module dependencies.
express = require 'express'
namespace = require 'express-namespace'
Backbone = require 'backbone'
ConnectCouchDB = (require 'connect-couchdb')(express)
connectAssets = (require 'connect-assets')()
marked = require 'marked'

app = module.exports = express.createServer()
port = null

# couchdb session storage:
sessionStore = new ConnectCouchDB
  name: "kaeuflich-#{process.env.NODE_ENV}"
  reapInterval: 600000
  compactInterval: -1

# Configuration
app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use (express.session secret: ' srdtfygihojp drtyfugkh', store: sessionStore)
  app.use app.router
  app.use (express.static __dirname + '/public')

app.configure 'development', ->
  app.use connectAssets
  port = 3000
  app.set 'port', port
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.configure 'production', ->
  app.use connectAssets
  port = 3000
  app.set 'port', port
  app.use express.errorHandler()

app.configure 'testing', ->
  port = 3001
  app.set 'port', port
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

# Helpers
(require './applications/references/views/_helpers')(app)
console.log app.locals().markdown
app.locals
  markdown: (raw) -> marked raw

# Routes
(require './routes')(app)
(require './applications/references/routes')(app)
(require './applications/contact/routes')(app)

app.listen port, ->
  console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
