assert = require 'should'
Contact = require '../../../../applications/contact/models/contact.coffee'

describe 'Contact', ->
  describe 'Defaults', ->
    contact = undefined
    beforeEach ->
      contact = new Contact
        name: 'My Name'
        email: 'my-email@example.net'
        inquiry: 'My inquiry'
    it 'sets type to »contact«', ->
      (contact.get 'type').should.equal 'contact'
  describe 'formatter', ->
    contact = undefined
    beforeEach ->
      contact = new Contact
        name: 'My Name'
        email: 'my-email@example.net'
        inquiry: 'My inquiry'
    it 'formats as text with formatAsText()', ->
      (contact.formatAsText()).should.not.match /[<>]+/
    it 'formats as HTML with formatAsHTML()', ->
      (contact.formatAsHTML()).should.match /[<>]+/
