assert = require 'should'
Reference = require '../../../../applications/references/models/reference.coffee'

describe 'Reference', ->
  describe 'create', ->
    it 'initializes from hash', ->
      reference = new Reference {title: 'My Title'}
      (reference.get 'title').should.equal 'My Title'
  describe 'update', ->
    it 'has working setters', ->
      reference = new Reference {}
      reference.set 'title', 'Something Weird'
      (reference.get 'title').should.equal 'Something Weird'
  describe 'parseForm', ->
    it 'parseTags parses list of comma separated tags to an array containing tags', ->
      reference = new Reference {}
      list = 'my, list, of, tags'
      result = reference.parseTags list
      result.should.be.instanceOf Array
      result.should.have.length 4
      result.should.include 'my'
      result.should.include 'list'
      result.should.include 'of'
      result.should.include 'tags'

    it 'parseTags parses empty string to empty array', ->
      reference = new Reference {}
      list = ''
      result = reference.parseTags list
      result.should.be.instanceOf Array
      result.should.have.length 0

    it 'parseTags parses tag with whitespace or non-alphanumeric string to dash-separated string', ->
      reference = new Reference {}
      list = 'my stuff, something%weird'
      result = reference.parseTags list
      result.should.be.instanceOf Array
      result.should.have.length 2
      result.should.include 'my-stuff'
      result.should.include 'something-weird'
