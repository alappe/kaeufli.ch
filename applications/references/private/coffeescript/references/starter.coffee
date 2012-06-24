(jQuery 'document').ready ->
  window.references = new window.References.Router.App()
  Backbone.history.start()
