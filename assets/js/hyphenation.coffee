#= require Hyphenator
(jQuery 'document').ready  ->
  Hyphenator.config
    selectorfunction: -> (jQuery '#container p').toArray()
    remoteloading: false
    persistentconfig: true
    useCSS3hyphenation: true
  Hyphenator.run()
