#= require jquery-min.js
#= require underscore-min.js
#= require backbone-min.js


###
 Copyright (c) 2012, Andreas Lappe <a.lappe@kuehlhaus.com>, kuehlhaus AG
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
 
 - Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
 - Neither the name of the kuehlhaus AG nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###


###
@author Andreas Lappe <nd@kaeufli.ch>
###


# Taken from https://github.com/jashkenas/coffee-script/wiki/FAQ
# `top` is a reference to the main namespace
namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top = target
  target = target[item] or= {} for item in name.split '.'
  block target, top


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


namespace 'References.Templates', (exports) ->
  exports.Reference = """
  <form action="#" method="post" enctype="multipart/form-data" class="form references reference-new">
    <fieldset>
      <legend>Basics</legend>
      <input type="hidden" name="<%= id %>" />
      <label>
        <span>Published</span>
        <input type="checkbox" <%= (published) ? 'checked="checked"' : '' %> name="published" />
      </label>
      <label>
        <span>Title</span>
        <input type="text" name="name" value="<%= name %>"/>
      </label>
      <label>
        <span>Slug</span>
        <input type="text" name="slug" readonly="readonly" value="<%= slug %>"/>
      </label>
      <label>
        <span>Start</span>
        <input type="date" name="start" value="<%= start %>" />
      </label>
      <label>
        <span>End</span>
        <input type="date" name="end" value="<%= end %>" />
      </label>
      <label>
        <span>Company</span>
        <input type="text" name="company" value="<%= company %>" />
      </label>
    </fieldset>
    <fieldset>
    	<legend>Short</legend>
      <textarea id="short" name="body.short" rows="10" cols="30"><%= body.short %></textarea>
    </fieldset>
    <fieldset>
      <legend>Long</legend>
      <textarea id="long" name="body.long" rows="10" cols="30"><%= body.long %></textarea>
    </fieldset>
    <fieldset>
      <legend>Frameworks</legend>
      <ul class="frameworks">
        <% _.each(frameworks, function(framework, i) { %>
          <li class="framework <%= (i === 0) ? 'first' : '' %><%= (framework.name === '') ? 'fade' : '' %>">
            <a href="#" class="icon icon-minus">
              <span>-</span>
            </a>
            <label class="first">
              <span>Name</span>
              <input type="text" name="frameworks[<%= i %>][name]" value="<%= framework.name %>" />
            </label>
            <label>
              <span>URL</span>
              <input type="text" name="frameworks[<%= i %>][url]" value="<%= framework.url %>" />
            </label>
          </li>
        <% }); %>
      </ul>
      <a href="#" class="icon icon-plus framework">
        <span>+</span>
      </a>
    </fieldset>
    <fieldset>
      <legend>Images</legend>
      <div class="imageDrop">
        <p class="dropText">Drop images here…</p>
        <ul class="images">
          <% _.each(this.model.getThumbnails(), function(thumbnail) { %>
            <li class="image">
              <img src="<%= thumbnail.address %>" alt="Thumbnail of Image <%= thumbnail.name %>" data:id="<%= thumbnail.name %>"  width="60px" />
            </li>
          <% }); %>
        </ul>
      </div>
    </fieldset>
    <fieldset>
      <legend>Tags</legend>
      <% var tagList = tags.join(', '); %>
      <textarea id="tags" name="tags" rows="10" cols="30"><%= tagList %></textarea>
    </fieldset>
  </form>
  """


namespace 'References.Router', (exports) ->
  class exports.App extends Backbone.Router
    routes:
      '': 'indexAction'

    initialize: ->

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


(jQuery 'document').ready ->
  window.references = new window.References.Router.App()
  Backbone.history.start()
