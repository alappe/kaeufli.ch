assert = require 'should'
File = require '../../../../applications/references/models/file.coffee'

describe 'File', ->
  describe 'Defaults', ->
    file = undefined
    beforeEach ->
      file = new File
        name: 'testfile'
        type: 'image/png'
    it 'sets temporaryPath', ->
      (file.get 'temporaryPath').should.equal '/tmp'
    it 'sets largeWidth', ->
      (file.get 'largeWidth').should.equal 800
    it 'sets thumbnailWidth', ->
      (file.get 'thumbnailWidth').should.equal 100
    it 'has method getFullPath()', ->
      (file.getFullPath()).should.not.be.empty
    it 'has method getFullThumbnailPath()', ->
      path = file.getFullThumbnailPath()
      path.should.not.be.empty
      path.should.match /thumb-/
    it 'has method getThumbnailName()', ->
      (file.getThumbnailName()).should.not.be.empty

  describe 'Dimensions', ->
    file = undefined
    beforeEach ->
      file = new File()
    it 'calculates correct dimensions for resizing a square', ->
      result = file.calculateDimensions {width: 700, height: 700}, 500
      result.width.should.equal 500
      result.height.should.equal 500
    it 'calculates correct dimensions for resizing 4:3', ->
      result = file.calculateDimensions {width: 400, height: 300}, 200
      result.width.should.equal 200
      result.height.should.equal 150
    it 'calculates correct dimensions for resizing 3:4', ->
      result = file.calculateDimensions {width: 300, height: 400}, 200
      result.width.should.equal 200
      result.height.should.equal 266
