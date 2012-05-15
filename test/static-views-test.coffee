assert = require 'should'
express = require 'express'
request = require 'request'
app = require '../server'

describe 'Static Views', ->
  describe 'Index', ->
    body = null
    before (done) ->
      options =
        uri: "http://localhost:#{app.settings.port}/"
      request options, (error, response, _body) ->
        body = _body
        done()
    it 'contains centered placeholder', ->
      body.should.match /p class\=\"center\"/
      body.should.match /cooking/

  describe 'Imprint', ->
    body = null
    before (done) ->
      options =
        uri: "http://localhost:#{app.settings.port}/imprint"
      request options, (error, response, _body) ->
        body = _body
        done()
    it 'contains my name', ->
      body.should.match /Andreas Lappe/
    it 'contains something about google analytics', ->
      body.should.match /google analytics/i
