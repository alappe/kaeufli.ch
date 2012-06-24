Backbone = require 'backbone'
gm = require 'gm'

module.exports = class File extends Backbone.Model
  defaults:
    temporaryPath: '/tmp'
    largeWidth: 800
    thumbnailWidth: 100

  initialize: (properties) ->
    if properties?
      @set ending: (properties.type.replace /.*\//, '') if properties.type?
      @set filename: "#{properties.name}.#{@get 'ending'}"

  # Returns the full temporaryPath including filename and -ending.
  #
  # @return [String]
  getFullPath: ->
    "#{@get 'temporaryPath'}/#{@get 'name'}.#{@get 'ending'}"

  # Returns the full temporaryPath for the thumbnail
  #
  # @return [String]
  getFullThumbnailPath: ->
    "#{@get 'temporaryPath'}/#{@getThumbnailName()}"

  # Returns the thumbnail filename
  #
  # @return [String]
  getThumbnailName: ->
    "thumb-#{@get 'name'}.#{@get 'ending'}"

  # Return the dimensions for the given file if height is scaled to
  # e.g. 800px with respect to the image ratio.
  #
  # @param [Number] width
  # @param [Object] callback
  # @return [Object]
  getLargeDimensions: (width, callback) ->
    (gm @getFullPath()).size (error, size) =>
      callback error, (@calculateDimensions size, width)
   
  # Returns the new dimensions
  #
  # @param [Object] size size.width and size.height
  # @oaram [Number] width
  # @return [Object]
  calculateDimensions: (size, width) ->
    #console.log "original: #{size.width}x#{size.height}"
    if size.width >= width
      # Horizontal orientation:
      if size.width >= size.height
        factor = size.height / size.width
      # Vertical orientation:
      else
        factor = size.height / size.width
        #console.log "new: #{width}x#{width * factor}"
    result =
      width: width
      height: Math.floor(width * factor)

  # Resize the original image to the /large/ size
  # we use on the page…
  #
  # @param [Object] callback
  resizeLarge: (callback) ->
    @getLargeDimensions (@get 'largeWidth'), (error, size) =>
      #console.log "Resizing #{@getFullPath()} to #{size.width}x#{size.height}"
      ((gm @getFullPath()).resize size.width, size.height).write @getFullPath(), (gmError, stdout, stderr, command) =>
        #console.log "resize done?: #{@getFullPath()}"
        callback()

  # Resize for thumbnail
  #
  # TODO: Add error logger…
  #
  # @param [Object] callback
  resizeThumbnail: (callback) ->
    #console.log "Resize #{@getFullPath()} to #{@getFullThumbnailPath()}"
    (gm @getFullPath()).thumb (@get 'thumbnailWidth'), (@get 'thumbnailWidth'), @getFullThumbnailPath(), (gmError, stdout, stderr, command) =>
      callback()
