namespace 'References.View', (exports) ->
  class exports.Reference extends Backbone.View
    events:
      'change': 'save'
      'click .icon-plus': 'addEntry'
      'click .icon-minus': 'removeEntry'
      'click li.image img': 'deleteImage'
      'drop .imageDrop': 'addImages'
      'dragover .imageDrop': 'addHoverClass'
      'dragleave .imageDrop': 'removeHoverClass'

    tagName: 'article'
    className: 'reference'
    initialize: ->
      @template = _.template top.References.Templates.Reference
      @model.bind 'change', @render
      @model.bind 'change:frameworks', @renderFrameworks

      # http://www.thebuzzmedia.com/html5-drag-and-drop-and-file-api-tutorial/comment-page-1/#comment-359927
      jQuery.event.props.push 'dataTransfer'

    renderFrameworks: =>
      console.log 'fraaaaame'
      @

    render: =>
      console.log 'render!'
      (jQuery @el).html (@template @model.toJSON())
      (jQuery '#container').append @el
      toFadeIn = (jQuery '.fade', @el)
      toFadeIn.animate {opacity: 1}, 900, 'linear', ->
        toFadeIn.removeClass 'fade'
      @

    save: (event) ->
      changedElement = (jQuery event.srcElement)
      name = changedElement.attr 'name'
      value = changedElement.val()
      console.log name
      console.log value

      switch name
        when 'name'
        # Adjust slug to name
          slug = (value.replace /[^a-z0-9\-\.]/gi, '-').toLowerCase()
          @model.set 'slug', slug
          @model.set 'name', value
        when 'body.short'
          # Work with nested values:
          body = @model.get 'body'
          body.short = value
          @model.set 'body', body
        when 'body.long'
          body = @model.get 'body'
          body.long = value
          @model.set 'body', body
        when 'tags'
          @model.set 'tags', @parseTags value
        when 'imageDrop'
          return null
        else
          if (name.match /frameworks\[/)?
            console.log 'fiddling with frameworks!'
            entryNumber = name.replace /frameworks\[(\d+)\].*/, '$1'
            entryName = (jQuery "input[name='frameworks[#{entryNumber}][name]']", @el).val()
            entryURL = (jQuery "input[name='frameworks[#{entryNumber}][url]']", @el).val()
            console.log "it is all about {name:#{entryName},url:#{entryURL}}"
            @model.addFramework
              name: entryName
              url: entryURL
          else
            @model.set name, value
      # Save the model…
      @model.persist()

    addEntry: (event) ->
      event.preventDefault()
      clickedElement = (jQuery event.srcElement)
      if clickedElement.hasClass 'framework'
        @model.addFramework()
      false

    removeEntry: (event, b, c) ->
      event.stopPropagation()
      event.preventDefault()
      console.log 'remove'
      console.log event
      console.log b
      console.log c
      
    # Parse a comma separated list of tags into an array of strings
    #
    # @param [String] tags
    # @return [Array]
    parseTags: (tagString) ->
      if tagString is '' or tagString.match /^\s+$/
        []
      else
        preliminary = tagString.split ','
        tags = for tag in preliminary
          tag = tag.replace /^\s+/, ''
          tag = tag.replace /\s+$/, ''
          # TODO: Replace me with posix classes, argh:
          tag.replace /[^a-z0-9\.\-]/gi, '-'
        _.uniq tags

    addImages: (dropEvent) ->
      dropEvent.stopPropagation()
      dropEvent.preventDefault()
      files = dropEvent.dataTransfer.files
      if files.length > 0
        @model.addImages files

    deleteImage: (image) ->
      imageId = (jQuery image.srcElement).attr 'data:id'
      imageId = imageId.replace /^thumb-/, ''
      @model.deleteImage imageId

    # Small visual helpers…
    addHoverClass: (event) -> (jQuery event.currentTarget).addClass 'hover' # if (jQuery event.srcElement).hasClass 'imageDrop'
    removeHoverClass: (event) -> (jQuery event.currentTarget).removeClass 'hover' if (jQuery event.srcElement).hasClass 'dropText'
