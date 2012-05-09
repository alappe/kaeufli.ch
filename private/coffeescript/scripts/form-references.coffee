(jQuery 'document').ready ->

  # more link
  (jQuery 'a.more').on 'click', (event) ->
    event.preventDefault()
    list = ((jQuery @).parent()).find 'ul'
    template = (jQuery '.template', list).clone()  #.removeClass 'template'
    template.removeClass 'template'
    template.css 'opacity', 0
    (template.find 'input').each (el) ->
      (jQuery @).attr 'name', ((jQuery @).attr 'name').replace /XX/, (list.length - 1)
    list.append template
    template.animate {opacity: 1}, 200, 'linear'
    false

  # Less link
  (jQuery 'a.less').live 'click', (event) ->
    event.preventDefault()
    listItem = (jQuery @).parent()
    list = (jQuery listItem).parent()
    listItem.animate {opacity: 0}, 200, 'linear', ->
      listItem.remove()
      index = 0
      ((list.find 'li').not '.template').each (el) ->
        ((jQuery @).find 'input').each (input) ->
          (jQuery @).attr 'name', ((jQuery @).attr 'name').replace /\[\d+\]/, "[#{index}]"
        index++
    false
  (jQuery 'form.references').on 'change', ->
    console.log 'change!'
  (jQuery 'input[name="title"]').on 'keyup', ->
    val = (jQuery @).val()
    (jQuery 'input[name="slug"]').val (val.replace /[^a-z0-9\-\.]/gi, '-')
    console.log
