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
    it 'contains dummy intro', ->
      body.should.match /<pre>/
      body.should.match /Love your work/
    it 'contains a link to imprint/', ->
      body.should.match /href\=\"\/imprint\"/
    it 'contains a link to the atom feed', ->
      body.should.match /application\/atom\+xml/

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

  describe 'robots.txt', ->
    body = null
    response = null
    before (done) ->
      options = uri: "http://localhost:#{app.settings.port}/robots.txt"
      request options, (error, _response, _body) ->
        body = _body
        response = _response
        done()
    it 'contains User-agent', ->
      body.should.match /User-agent/
    it 'has Content-Type set to »text/plain«', ->
      response.headers['content-type'].should.match /text\/plain/
