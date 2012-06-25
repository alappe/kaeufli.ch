markdown = require 'markdown-js'

helpers = (app) ->
  app.helpers
    markdown: (text) -> markdown.encode text

    thumbnails: (reference) ->
      thumbnails = []
      index = 1
      id = reference.get 'slug'
      root = '/references'
      for name, image of (reference.get '_attachments')
        if (name.match /^thumb-/)?
          large = (name.replace /^thumb-/, '')
          image =
            uri: "#{root}/#{id}/images/#{name}"
            largeUri: "#{root}/#{id}/images/#{large}"
            index: index
          index++
          thumbnails.push image
      thumbnails
    
    getDuration: (reference) ->
      dateMatcher = /(\d{2})\.(\d{2})\.(\d{4})/
      start = reference.get 'start'
      end = reference.get 'end'

      months = [
        'January'
        'February'
        'March'
        'April'
        'Mai'
        'June'
        'July'
        'August'
        'September'
        'October'
        'November'
        'December'
      ]

      # Ignore days, we do not have that resolution:
      startMonth = (parseInt (start.replace dateMatcher, '$2'), 10) - 1
      startYear  = parseInt (start.replace dateMatcher, '$3'), 10
      startDate = new Date startYear, startMonth, 1
      endMonth =  (parseInt (end.replace dateMatcher, '$2'), 10) - 1
      endYear = parseInt (start.replace dateMatcher, '$3'), 10
      endDate = new Date endYear, endMonth, 1

      date =
        startText: if startYear is endYear then "#{months[startMonth]}" else "#{months[startMonth]} #{startYear}"
        startDate: startDate.toString 'yyyy-MM-dd'
        endText: "#{months[endMonth]} #{endYear}"
        endDate: endDate.toString 'yyyy-MM-dd'

module.exports = helpers
