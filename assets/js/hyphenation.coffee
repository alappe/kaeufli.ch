#= require Hyphenator
Hyphenator.config
  selectorfunction: -> document.querySelectorAll '#container p'
  remoteloading: false
  persistentconfig: true
  useCSS3hyphenation: true
Hyphenator.run()
