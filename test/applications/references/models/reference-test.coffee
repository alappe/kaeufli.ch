assert = require 'should'
Reference = require '../../../../applications/references/models/reference.coffee'

describe 'Reference', ->
  describe 'Defaults', ->
    reference = undefined
    beforeEach ->
      reference = new Reference()
    it 'sets published', ->
      (reference.get 'published').should.equal false
    it 'sets name', ->
      (reference.get 'name').should.equal 'EDIT ME'
    it 'sets slug', ->
      (reference.get 'slug').should.equal 'edit-me'
    it 'sets company', ->
      (reference.get 'company').should.equal ''
    it 'sets type', ->
      (reference.get 'type').should.equal 'reference'
    it 'sets tags', ->
      (reference.get 'tags').should.have.lengthOf 0
    it 'sets frameworks', ->
      (reference.get 'frameworks').should.have.lengthOf 0
    it 'sets id', ->
      (reference.get 'id').should.equal = ''
    it 'sets start', ->
      (reference.get 'start').should.equal = ''
    it 'sets end', ->
      (reference.get 'end').should.equal = ''
    it 'sets body', ->
      body = reference.get 'body'
      body.should.be.a 'object'
      body.should.have.property 'short'
      body.should.have.property 'long'
    it 'holds a reference to the database', ->
      (reference.db()).should.be.a 'object'
    it 'has the right db-name', ->
      reference.dbName.should.equal 'kaeuflich-testing'

  describe 'ClassProperties', ->
    it 'can fetch all references', (done)->
      Reference.all (error, references) ->
        throw error if error?
        done()
    it 'can fetch all published references', (done) ->
      Reference.allPublished (error, references) ->
        throw error if error?
        done()
    it 'can fetch all tags', (done) ->
      Reference.allTags (error, tags) ->
        throw error if error?
        done()
    it 'can fetch by tag', (done) ->
      Reference.byTag 'tag', (error, references) ->
        throw error if error?
        done()
    it 'can get a reference by slug', (done) ->
      Reference.get 'edit-me', (error, reference) ->
        throw error if error?
        done()
    it 'can fetch a uuid', (done) ->
      Reference.uuid (error, uuid) ->
        throw error if error?
        uuid.should.not.be.empty
        done()
    it 'can fetch by id', (done) ->
      Reference.getById 'ceb815dce89d3ad990f4c813a000972b', (error, reference) ->
        throw error if error?
        done()
    it 'can save to database', (done) ->
      ref = new Reference()
      Reference.save ref, (error, body) ->
        throw error if error?
        body.should.be.a 'object'
        body.should.have.property 'id'
        body.should.have.property 'rev'
        body.should.have.property 'ok', true
        done()
    it 'has a view name set', ->
      Reference.view.should.equal 'references'
    it 'holds a reference to the database', ->
      (Reference.db()).should.be.a 'object'
    it 'has the right db-name', ->
      (Reference.dbName).should.equal 'kaeuflich-testing'

  describe 'create', ->
    it 'initializes from hash', ->
      reference = new Reference {title: 'My Title'}
      (reference.get 'title').should.equal 'My Title'
  describe 'update', ->
    it 'has working setters', ->
      reference = new Reference {}
      reference.set 'title', 'Something Weird'
      (reference.get 'title').should.equal 'Something Weird'
#   describe 'parseForm', ->
#     it 'parseTags parses list of comma separated tags to an array containing tags', ->
#       reference = new Reference {}
#       list = 'my, list, of, tags'
#       result = reference.parseTags list
#       result.should.be.instanceOf Array
#       result.should.have.length 4
#       result.should.include 'my'
#       result.should.include 'list'
#       result.should.include 'of'
#       result.should.include 'tags'
# 
#     it 'parseTags parses empty string to empty array', ->
#       reference = new Reference {}
#       list = ''
#       result = reference.parseTags list
#       result.should.be.instanceOf Array
#       result.should.have.length 0
# 
#     it 'parseTags parses tag with whitespace or non-alphanumeric string to dash-separated string', ->
#       reference = new Reference {}
#       list = 'my stuff, something%weird'
#       result = reference.parseTags list
#       result.should.be.instanceOf Array
#       result.should.have.length 2
#       result.should.include 'my-stuff'
#       result.should.include 'something-weird'
