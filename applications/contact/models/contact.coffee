Backbone = require 'backbone'
mailer = require 'nodemailer'
nano = (require 'nano')('http://localhost:5984')

module.exports = class Contact extends Backbone.Model
  defaults:
    type: 'contact'

  formatAsText: ->
    """
    Name: #{@get 'name'}
    eMail: #{@get 'email'}
    Inquiry:
      #{@get 'inquiry'}
    """

  formatAsHTML: ->
    """
    <html>
    Name: #{@get 'name'}
    eMail: #{@get 'email'}
    Inquiry:
      #{@get 'inquiry'}
    </html>
    """

  handle: (callback) ->
    @set date: (new Date).toUTCString()
    @saveToDatabase (error) =>
      console.log error if error
      @sendMail callback

  saveToDatabase: (callback) ->
    db = nano.db.use "kaeuflich-#{process.env.NODE_ENV}"
    db.insert @toJSON(), (error, response) ->
      callback error

  sendMail: (callback) ->
    smtpTransport = mailer.createTransport 'SMTP'
    mailOptions =
      from: 'info@kaeufli.ch'
      to: 'nd@kaeufli.ch'
      subject: 'Inquiry from kaeufli.ch'
      text: @formatAsText()
      html: @formatAsHTML()

    smtpTransport.sendMail mailOptions, (error, response) =>
      console.log error if error
      smtpTransport.close()
      callback error, @get 'name'
