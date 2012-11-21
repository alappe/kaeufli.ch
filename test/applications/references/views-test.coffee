assert = require 'should'
express = require 'express'
request = require 'request'
app = require '../../../server'

describe 'Views', ->
  describe 'Index', ->
    body = null
    before (done) ->
      options = uri: "http://localhost:#{app.settings.port}/references/"
      request options, (error, response, _body) ->
        body = _body
        done()
    it 'contains references', ->
      body.should.match /<section[^>]*class="reference">/
    it 'contains headline per reference', ->
      body.should.match /<section[^>]*><a[^>]*><h1>/i
    it 'contains links to details per reference', ->
      body.should.match /<section[^>]*><a href="\/references\/[a-z\-]+" title="Show more details/i
    it 'contains a link of tags', ->
      body.should.match /ul class="tags"/i

  describe 'Atom Feed', ->
    body = null
    response = null
    before (done) ->
      options = uri: "http://localhost:#{app.settings.port}/references/feed.xml"
      request options, (error, _response, _body) ->
        body = _body
        response = _response
        done()
    it 'has correct content-type', ->
      response.headers['content-type'].should.equal 'application/atom+xml'
    it 'contains xml preamble', ->
      body.should.match /xml version='1.0' encoding='utf-8'/
    it 'contains atom feed', ->
      body.should.match /feed xmlns/
    it 'contains entries', ->
      body.should.match /entry/
    it 'contains summary', ->
      body.should.match /summary/
    it 'contains correctly formatted dates', ->
      body.should.match /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/
    it 'contains URI as id', ->
      body.should.match /<id>http:\/\//

  describe 'Show', ->
    body = null
    before (done) ->
      options = uri: "http://localhost:#{app.settings.port}/references/edit-me"
      request options, (error, response, _body) ->
        body = _body
        done()
    it 'contains article', ->
      body.should.match /<article class="reference">/
    it 'contains headline', ->
      body.should.match /<h1>EDIT ME<\/h1>/i

  describe 'Tags', ->
    body = null
    before (done) ->
      options = uri: "http://localhost:#{app.settings.port}/references/tags"
      request options, (error, response, _body) ->
        body = _body
        done()
    it 'contains a list of tags', ->
      body.should.match /<ul class="tags">/
    it 'contains a link for each tag', ->
      body.should.match /<li class="tag"><a[^>]*>[^<]*<\/a><\/li>/i

  describe 'List by tag', ->
    body = null
    before (done) ->
      options = uri: "http://localhost:#{app.settings.port}/references/tags/something"
      request options, (error, response, _body) ->
        body = _body
        done()
    it 'contains a list of matching references', ->
      body.should.match /<section[^>]*class="reference"/i
    it 'contains the tag again', ->
      body.should.match /<li class="tag">something<\/li>/i

  describe 'Admin area', ->
    describe 'without login', ->
      body = null
      before (done) ->
        options =
          uri: "http://localhost:#{app.settings.port}/references/admin"
          jar: false
        request options, (error, response, _body) ->
          body = _body
          done()
      it 'contains a login form', ->
        body.should.match /Username/
        body.should.match /Password/
      it 'redirects to login for unauthorized edit', (done) ->
        options =
          uri: "http://localhost:#{app.settings.port}/references/admin/ceb815dce89d3ad990f4c813a000972b"
          jar: false
        request options, (error, response, _body) ->
          response.request._redirectsFollowed.should.equal 1
          _body.should.match /Username/
          _body.should.match /Password/
          done()
    describe 'with login', ->
      body = null
      before (done) ->
        options =
          uri: "http://localhost:#{app.settings.port}/references/admin/login"
          method: 'POST'
          form:
            username: 'user'
            password: 'pass'
        request options, (error, response, _body) ->
          body = _body
          done()
      it 'redirects after creating a new reference', (done) ->
        options = uri: "http://localhost:#{app.settings.port}/references/admin/new"
        request options, (_error, _response, __body) ->
          _response.request._redirectsFollowed.should.equal 1
          __body.should.match /<div id="container">/
          done()
      it 'returns json if accept-headers contains it', (done) ->
        options =
          uri: "http://localhost:#{app.settings.port}/references/admin/ceb815dce89d3ad990f4c813a000972b"
          headers: accept: 'application/json'
        request options, (_error, _response, __body) ->
          __body.should.match /{.*"_id":"ceb815dce89d3ad990f4c813a000972b".*}/
          done()
