if module?.exports?
  Backbone = require 'backbone'
  _ = require 'underscore'
  nano = (require 'nano')('http://localhost:5984')
  fs = require 'fs'
  gm = require 'gm'

module.exports = class Reference extends Backbone.Model
  @view: 'references'
  @db: -> nano.db.use @dbName
  @dbName: "kaeuflich-#{process.env.NODE_ENV}"

  db: -> nano.db.use @dbName
  dbName: "kaeuflich-#{process.env.NODE_ENV}"
  urlRoot: ->
    'http://localhost:5984/kaeuflich-development/'

  sync: (method, model, options) ->
    console.log options
    switch method
      when 'create', 'update'
        @db().insert @.toJSON(), (error, body) =>
          if error and options.error?
            options.error @, error
          else if options.success?
            @set '_rev', body.rev
            console.log "Setting rev to #{body.rev}"
            options.success @, body
      when 'delete'
        console.log 'delete'
        @db().destroy (@get '_id'), (@get '_rev'), (error, body) =>
          if error and options.error?
            options.error @, error
          else if options.success?
            options.success @, body

  uploadImages: (files) ->
    console.log "#{files.images.length} images to upload…"
    if files.images.length > 0
      image = files.images.pop()
      @uploadImage image, files, (error, body, remainingFiles) =>
        console.log 'callback uploadImageS'
        console.log error if error
        console.log body
        unless error
          @set '_rev', body.rev
          @uploadImages remainingFiles

  readFile: (path, callback) ->
    fs.readFile path, (error, data) ->
      callback error, data

  attachmentUpload: (name, data, type, callback) ->
    id = @get '_id'
    rev = { rev: (@get '_rev') }
    console.log "uploading #{name} with #{rev.rev}"
    @db().attachment.insert id, name, data, type, rev, (error, body) =>
      @set '_rev', body.rev unless body.error?
      callback error, body

  # Upload a single image in two variations: original and a thumbnail.
  uploadImage: (image, remainingFiles, callback) ->
    @readFile image.path, (fsError, data) =>
      Reference.uuid (uuidError, name) =>
        @attachmentUpload name, data, image.type, (error, body) =>
          console.log 'uploaded master file, now thumbnail…'
          @uploadThumbnail name, image, remainingFiles, (error, body, remainingFiles) ->
            console.log 'callback uploadImage'
            callback error, body, remainingFiles

#    fs.readFile path, (error, data) =>
#      console.log error if error
#      unless error
#        db.attachment.insert id, name, data, type, rev, (err, body) =>
#          unless error?
#            console.log body
#            @uploadThumbnail db, id, path, name, body.rev, remainingFiles, callback
#            #callback error, body, remainingFiles

  uploadThumbnail: (name, image, remainingFiles, callback) ->
    name = "thumb-#{name}"
    # TODO: FIXME
    path = "/tmp/#{name}.png"
    console.log "Resize #{image.path} to #{path}"
    (gm image.path).thumb 200, 200, path, (gmError, stdout, stderr, command) =>
      @readFile path, (fsError, data) =>
        console.log "Uploading #{name}"
        @attachmentUpload name, data, image.type, (error, body) ->
          console.log 'callback uploadThumbnail'
          callback error, body, remainingFiles

  uploadThumbnailOld: (db, id, path, name, rev, remainingFiles, callback) ->
    name = "/tmp/thumb-#{name}.png"
    (gm path).thumb 200, 200, name, 60, (err, stdout, stderr, command) =>
      unless err?
        fs.readFile name, (error, data) =>
          unless error?
            db.attachment.insert id, "thumb-#{name}", data, 'image/png', {rev: rev}, (e, body) =>
              unless e?
                callback e, body, remainingFiles

    # unless original?

  @all: (callback) ->
    @db().view @view, 'all', (error, body) ->
      references = []
      references = for row in body.rows
        reference = new Reference row.value
      callback error, references

  @allTags: (callback) ->
    @db().view @view, 'allTags', {group: true}, (error, body) ->
      tags = []
      tags = for row in body.rows
        tag =
          name: row.key
      callback error, tags

  @byTag: (tag, callback) ->
    @db().view @view, 'byTag', {key: tag}, (error, body) ->
      references = []
      references = for row in body.rows
        reference = new Reference row.value
      callback error, references

  @get: (slug, callback) ->
    @db().view @view, 'all', {key: slug}, (error, body) ->
      referenceData = _.first body.rows
      callback error, new Reference referenceData.value

  @uuid: (callback) ->
    options =
      path: '_uuids'
    nano.request options, (error, body) ->
      #console.log _.first body.uuids
      callback error, _.first body.uuids

  # Parse from form data, converting some fields
  #
  # @param [Object] response
  # @return null
  parseForm: (response, callback) ->
    parsed = _.extend {}, response.form
    parsed.tags = @parseTags response.form.tags
    @set parsed
    callback() if callback?

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
        tag.replace /[^a-z0-9\.\-]/i, '-'
