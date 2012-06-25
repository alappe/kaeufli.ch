###
Lightbox

Based on Lightbox v2.51 by Lokesh Dhakar - http://www.lokeshdhakar.com
For more information, visit: http://lokeshdhakar.com/projects/lightbox2/

Licensed under the Creative Commons Attribution 2.5 License - http://creativecommons.org/licenses/by/2.5/
- free for use in both personal and commercial projects
- attribution requires leaving author name, author link, and the license info intact

Thanks
- Scott Upton(uptonic.com), Peter-Paul Koch(quirksmode.com), and Thomas Fuchs(mir.aculo.us) for ideas, libs, and snippets.
- Artemy Tregubenko (arty.name) for cleanup and help in updating to latest proto-aculous in v2.05.
###

# Use local alias
$ = jQuery

class Lightbox
  constructor: (@options) ->
    @album = []
    @currentImageIndex = undefined
    @init()
  
  init: ->
    @enable()
    @build()

  # Loop through anchors and areamaps looking for data-lightbox attributes that contain 'lightbox'
  # On clicking these, start lightbox.
  enable: ->
    $('body').on 'click', 'a[data-lightbox="lightbox"], area[data-lightbox="lightbox"]', (e) =>
      @start $(e.currentTarget)
      false

  # Build html for the lightbox and the overlay.
  # Attach event handlers to the new DOM elements. click click click
  build: ->
    markup = '''
    <div id="lightboxOverlay"></div>
      <div id="lightbox">
        <div class="lb-outerContainer">
          <div class="lb-dataContainer">
            <div class="lb-data">
              <a href="#" class="lb-close"></a>
              <div class="lb-nav hidden">
                <a href="#" class="lb-prev"></a>
                <span class="lb-center"></span>
                <a href="#" class="lb-next"></a>
              </div>
              <div class="lb-details">
                <span class="lb-caption"></span>
                <span class="lb-number"></span>
              </div>
            </div>
          </div>
          <div class="lb-container">
              <img class="lb-image" />
              <div class="lb-loader"></div>
          </div>
        </div>
      </div>
    </div>
    '''
    $(markup).appendTo $('body')

    # Attach event handlers to the newly minted DOM elements
    $('#lightboxOverlay')
      .hide()
      .on 'click', (e) =>
        @end()
        return false

    $lightbox = $('#lightbox')
    
    $lightbox
      .hide()
      .on 'click', (e) =>
        if $(e.target).attr('id') == 'lightbox' then @end()
        return false
      
    $lightbox.find('.lb-outerContainer').on 'click', (e) =>
      if $(e.target).attr('id') == 'lightbox' then @end()
      return false
      
    # OS behaviour…
    ($lightbox.find '.lb-prev, .lb-next, .lb-close').on 'mousedown', (e) ->
      ($ @).addClass 'clicked'
    ($lightbox.find '.lb-prev, .lb-next, .lb-close').on 'mouseup', (e) ->
      ($ @).removeClass 'clicked'

    $lightbox.find('.lb-prev').on 'click', (e) =>
      if @options.loop && @currentImageIndex is 0
        @changeImage @album.length - 1
      else
        @changeImage @currentImageIndex - 1
      return false
      
    $lightbox.find('.lb-next').on 'click', (e) =>
      if @options.loop and @currentImageIndex is (@album.length - 1)
        @changeImage 0
      else
        @changeImage @currentImageIndex + 1
      return false

    $lightbox.find('.lb-loader, .lb-close').on 'click', (e) =>
      @end()
      return false

    return

  # Show overlay and lightbox. If the image is part of a set, add siblings to album array.
  start: ($link) ->
    $('select, object, embed').css visibility: 'hidden'
    $('#lightboxOverlay').fadeIn @options.fadeDuration

    @album = []
    imageNumber = 0

    if ($link.attr 'data-lightbox-group')?
      # Image is part of a set
      for a, i in $( $link.prop('tagName') + '[data-lightbox-group="' + ($link.attr 'data-lightbox-group') + '"]')
        @album.push
          link: $(a).attr 'href'
          title: $(a).attr 'title'
        if $(a).attr('href') is $link.attr('href')
          imageNumber = i
    else
      # If image is not part of a set
      @album.push
        link: $link.attr 'href'
        title: $link.attr 'title'

    # Position lightbox 
    $window = $(window)
    top = $window.scrollTop() + $window.height() / 10
    left = $window.scrollLeft()
    $lightbox = $('#lightbox')
    $lightbox
      .css
        top: top + 'px'
        left: left + 'px'
      .fadeIn @options.fadeDuration
      
    @changeImage(imageNumber)
    return

  # Hide most UI elements in preparation for the animated resizing of the lightbox.
  changeImage: (imageNumber) ->
    @disableKeyboardNav()
    $lightbox = $('#lightbox')
    $image = $lightbox.find('.lb-image')

    $('#lightboxOverlay').fadeIn( @options.fadeDuration )
    
    $('.loader').fadeIn 'slow'
    ($lightbox.find '.lb-image').hide()
    ($lightbox.find '.lb-outerContainer').addClass 'animating'
    
    # When image to show is preloaded, we send the width and height to sizeContainer()
    preloader = new Image()
    preloader.onload = =>
      $image.attr 'src', @album[imageNumber].link
      $image.width = preloader.width
      $image.height = preloader.height
      @sizeContainer preloader.width, preloader.height

    preloader.src = @album[imageNumber].link
    @currentImageIndex = imageNumber
    return

  # Animate the size of the lightbox to fit the image we are showing
  sizeContainer: (imageWidth, imageHeight) ->
    $lightbox = $('#lightbox')

    $outerContainer = $lightbox.find '.lb-outerContainer'
    oldWidth = $outerContainer.outerWidth()
    oldHeight = $outerContainer.outerHeight()

    $container = $lightbox.find('.lb-container')
    containerTopPadding = parseInt $container.css('padding-top'), 10
    containerRightPadding = parseInt $container.css('padding-right'), 10
    containerBottomPadding = parseInt $container.css('padding-bottom'), 10
    containerLeftPadding = parseInt $container.css('padding-left'), 10

    $dataContainer = $lightbox.find '.lb-dataContainer'
    dataContainerHeight = $dataContainer.outerHeight()

    newWidth = imageWidth + containerLeftPadding + containerRightPadding
    newHeight = imageHeight + containerTopPadding + containerBottomPadding + dataContainerHeight
  
    # Animate just the width, just the height, or both, depending on what is different
    if newWidth != oldWidth && newHeight != oldHeight
      $outerContainer.animate
          width: newWidth,
          height: newHeight
        , @options.resizeDuration, 'swing'
    else if newWidth != oldWidth
      $outerContainer.animate
          width: newWidth
        , @options.resizeDuration, 'swing'
    else if newHeight != oldHeight
      $outerContainer.animate
          height: newHeight
        , @options.resizeDuration, 'swing'

    # Wait for resize animation to finish before showing the image
    setTimeout =>
        $lightbox.find('.lb-dataContainer').width(newWidth)
        # $lightbox.find('.lb-prevLink').height(newHeight)
        # $lightbox.find('.lb-nextLink').height(newHeight)
        @showImage()
        return
      , @options.resizeDuration
    
    return
  
  # Display the image and it's details and begin preload neighboring images.
  showImage: ->
    $lightbox = $('#lightbox')
    $lightbox.find('.lb-loader').hide()
    $lightbox.find('.lb-image').fadeIn 'slow'

    @updateNav()
    @updateDetails()
    @preloadNeighboringImages()
    @enableKeyboardNav()

    return

  # Display previous and next navigation if appropriate.
  updateNav: ->
    $lightbox = $('#lightbox')
    if @album.length > 1
      $lightbox.find('.lb-nav').show()
    #($lightbox.find '.lb-prev').show() if (@currentImageIndex > 0) or @options.loop
    #($lightbox.find '.lb-next').show() if (@currentImageIndex < (@album.length - 1)) or @options.loop
    return
  
  # Display caption and closing button. 
  updateDetails: ->
    $lightbox = $('#lightbox')
    
    if (typeof @album[@currentImageIndex].title isnt 'undefined') and (@album[@currentImageIndex].title isnt '') and (@options.label isnt false)
      switch @options.label
        when 'title'
          title = @album[@currentImageIndex].title
          labelText = if title? then title else ''
        when 'filename'
          link = @album[@currentImageIndex].link
          labelText = (link.replace /.*\/([^\/]+)$/, '$1')
      (($lightbox.find '.lb-caption').html labelText).fadeIn 'fast'

    $lightbox.find('.lb-outerContainer').removeClass 'animating'
    
    $lightbox.find('.lb-dataContainer')
      .fadeIn @resizeDuration
    return
    
  # Preload previous and next images in set.  
  preloadNeighboringImages: ->
   if @album.length > @currentImageIndex + 1
     preloadNext = new Image()
     preloadNext.src = @album[@currentImageIndex + 1].link
   else if @options.loop and @album.length > 1
     preloadNext = new Image()
     preloadNext.src = @album[0].link

   if @currentImageIndex > 0
       preloadPrev = new Image()
       preloadPrev.src = @album[@currentImageIndex - 1].link
   else if @options.loop and @album.length > 1
     preloadNext = new Image()
     preloadNext.src = @album[@album.length - 1].link
   return

  enableKeyboardNav: ->
    $(document).on 'keyup.keyboard', $.proxy( @keyboardAction, this)
    return
  
  disableKeyboardNav: ->
    $(document).off '.keyboard'
    return
  
  keyboardAction: (event) ->
    KEYCODE_ESC = 27
    KEYCODE_LEFTARROW = 37
    KEYCODE_RIGHTARROW = 39

    keycode = event.keyCode
    key = String.fromCharCode(keycode).toLowerCase()

    if keycode is KEYCODE_ESC or key.match /x|o|c/
      @end()
    else if key == 'p' or keycode is KEYCODE_LEFTARROW
      if @currentImageIndex isnt 0
        @changeImage @currentImageIndex - 1
      else if @options.loop
        @changeImage @album.length - 1
    else if key is 'n' or keycode is KEYCODE_RIGHTARROW
      if @currentImageIndex isnt @album.length - 1
        @changeImage @currentImageIndex + 1
      else if @options.loop
        @changeImage 0
    return

  # Closing time. :-(
  end: ->
    @disableKeyboardNav()
    $('#lightbox').fadeOut @options.fadeDuration
    $('#lightboxOverlay').fadeOut @options.fadeDuration
    $('select, object, embed').css visibility: 'visible'
    
$ ->
  lightbox = new Lightbox
    resizeDuration: 700
    fadeDuration: 500
    labelImage: 'Image' # Change to localize to non-english language
    labelOf: 'of'
    label: 'filename' # false, title or filename
    loop: true
