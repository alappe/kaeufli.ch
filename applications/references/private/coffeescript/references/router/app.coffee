namespace 'References.Router', (exports) ->
  class exports.App extends Backbone.Router
    routes:
      '': 'indexAction'

    initialize: ->
      console.log 'router init'

    indexAction: ->
      reference = new top.References.Model.Reference()
      reference.url = top.window.location.href
      reference.fetch
        success: (model, response) =>
          @showAction model

    showAction: (model) ->
      referenceView = new top.References.View.Reference
        model: model
      referenceView.render()
