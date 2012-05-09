markdown = require 'markdown-js'

helpers = (app) ->
  app.helpers
    markdown: (text) -> markdown.encode text

    thumbnails: (reference) ->
      thumbnails = []
      index = 1
      id = reference.get '_id'
      root = reference.urlRoot()
      for name, image of (reference.get '_attachments')
        if (name.match /^thumb-/)?
          large = (name.replace /^thumb-/, '')
          image =
            uri: "#{root}/#{id}/#{name}"
            largeUri: "#{root}/#{id}/#{large}" 
            index: index
          index++
          thumbnails.push image
      thumbnails

module.exports = helpers
