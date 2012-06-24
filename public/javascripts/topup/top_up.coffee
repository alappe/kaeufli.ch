jQuery.extend
  keys: (hash) ->
    keys = []
    keys = for key of hash
      key
    keys
jQuery.fn.extend
  id: ->
    unless @is '[id]'
      for element, index in (jQuery "#{id}")
        (jQuery element).attr 'id', "element_#{index}"
    (jQuery @).attr 'id'
  markerId: ->
    "_#{@id()}_marker"
  bubbleDetect: (selector, separator) ->
    jQuery.each (selector.split (separator || ',')), (i, e) ->
      selector = jQuery.trim e
  
class TopUp
  version = '2.0.0'
