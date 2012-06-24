namespace 'References.Model', (exports) ->
  class exports.Reference extends Backbone.Model
    idAttribute: '_id'

    initialize: ->

    # Essentially a wrapper around @save() but handles the
    # _rev property of the couchdb backend.
    persist: ->
      @save @toJSON(),
        success: (model, response) =>
          #@fetch()
          @set _rev: response.rev, silent: true

    addFramework: (framework) =>
      frameworks = @get 'frameworks'
      if framework?
        updated = false
        for knownFramework, index in frameworks
          if (knownFramework.name is '') and (knownFramework.url is '')
            frameworks.splice index, 1
          else if knownFramework.name isnt '' and ((knownFramework.name is framework.name) or (knownFramework.url is framework.url))
            frameworks[index] = name: framework.name, url: framework.url
            updated = true
        frameworks.push framework unless updated
      else
        frameworks.push {name: '', url: ''}
      @set frameworks: frameworks, silent: true

    getThumbnails: ->
      console.log 'getting thumbnails'
      images = []
      for name of (@get '_attachments')
        if name.match /^thumb-/
          images.push
            name: "#{name}"
            address: "/references/#{@get 'slug'}/images/#{name}"
      images

    deleteImage: (id) ->
      console.log 'deleting ' + id
      images = @get '_attachments'
      for name of (@get '_attachments')
        delete images[name] if (name is id) or (name is "thumb-#{id}")
      @set '_attachments', images
      @persist()

    addImages: (files) ->
      if files.item?
        console.log 'converting to array'
        files = for file in files
          console.log file.name
          file
      if files.length > 0
        file = files.pop()
        @sendImage file, files

    sendImage: (image, images) ->
      console.log image
      reader = new FileReader()
      reader.onloadstart = -> console.log 'onloadstart'
      reader.onprogress = -> console.log 'onprogress'
      reader.onload = (event) =>
        console.log 'POSTing image…'
        jQuery.ajax
          url: "/references/admin/#{@get 'slug'}/images"
          type: 'POST'
          contentType: image.type
          data: event.target.result
          processData: false
          success: (response, status) =>
            console.log 'POSTed…'
            @addImages images
            @fetch()
          error: (a,b,c) =>
            console.log a
            console.log b
            console.log c
      reader.onabort = -> console.log 'onabort'
      reader.onerror = (event) ->
        console.log 'onerror'
        console.log event.target.error.code
      reader.onloadend = -> console.log 'onloadend'
      reader.readAsArrayBuffer image
      null
