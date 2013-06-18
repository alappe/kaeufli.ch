if module?.exports?
  Backbone = require 'backbone'
  _ = require 'underscore'
  nano = (require 'nano')('http://localhost:5984')
  fs = require 'fs'
  gm = require 'gm'
  moment = require 'moment'
  File = require "#{__dirname}/../models/file"

module.exports = class Reference extends Backbone.Model
  @view: 'references'
  @db: -> nano.db.use @dbName
  @dbName: "kaeuflich-#{process.env.NODE_ENV}"

  db: -> nano.db.use @dbName
  dbName: "kaeuflich-#{process.env.NODE_ENV}"
  urlRoot: ->
    "http://localhost:5984/kaeuflich-#{process.env.NODE_ENV}/"
  idAttribute: '_id'
  defaults:
    published: false
    name: 'EDIT ME'
    slug: 'edit-me'
    company: ''
    type: 'reference'
    tags: []
    frameworks: []
    id: ''
    start: ''
    end: ''
    body:
      short: ''
      long: ''

  sync: (method, model, options) ->
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
        @db().destroy (@get '_id'), (@get '_rev'), (error, body) =>
          if error and options.error?
            options.error @, error
          else if options.success?
            options.success @, body

  # Adds an image
  addImage: (request, data, callback) ->
    Reference.uuid (error, uuid) =>
      throw error if error
      file = new File
        type: request.header 'content-type'
        name: uuid
      fs.writeFile file.getFullPath(), data, 'binary', (error) =>
        console.log 'writing ' + file.getFullPath()
        throw error if error
        @uploadImage file, callback

  # Show image
  showImage: (docId, imageId, response) ->
    (@db().attachment.get docId, imageId).pipe response

  # Upload a single image in two variations: original and a thumbnail.
  #
  # @param [Object] file
  # @param [Buffer] imageData
  # @param [Object] callback
  uploadImage: (file, callback) ->
    file.resizeLarge =>
      @readFile file.getFullPath(), (fsError, data) =>
        @attachmentUpload (file.get 'filename'), data, (file.get 'type'), (error, body) =>
          console.log 'uploaded master file, now thumbnail…'
          @uploadThumbnail file, (error, body) ->
            console.log 'callback uploadImage'
            callback error, body

  # Convert to thumbnail, then upload
  #
  # @param [Object] file
  uploadThumbnail: (file, callback) ->
    file.resizeThumbnail =>
      @readFile file.getFullThumbnailPath(), (fsError, data) =>
        console.log "Uploading #{file.getThumbnailName()}"
        @attachmentUpload file.getThumbnailName(), data, (file.get 'type'), (error, body) ->
          console.log 'callback uploadThumbnail'
          callback error, body

  # Asynchronous read the file
  #
  # @param [String] path
  # @param [Object] callback
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

  # @return [String]
  getISODate: -> (moment.utc (@get 'start'), 'DD.MM.YYYY').format 'YYYY-MM-DDTHH:mm:ss[Z]'

  @all: (callback) ->
    @db().view @view, 'all', (error, body) ->
      references = []
      references = for row in body.rows
        reference = new Reference row.value
      callback error, references

  @allPublished: (callback) ->
    @db().view @view, 'allPublished', {descending: true}, (error, body) ->
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
      if body.rows.length > 0
        referenceData = _.first body.rows unless error
        reference = new Reference referenceData.value
      else
        error = new Error 'cannot find reference'
        reference = null
      callback error, reference

  @getById: (id, callback) ->
    @db().get id, (error, body) ->
      callback error, new Reference body

  @uuid: (callback) ->
    options =
      path: '_uuids'
    nano.request options, (error, body) ->
      callback error, _.first body.uuids

  @save: (model, callback) ->
    @db().insert model, null, (error, body) ->
      callback error, body
