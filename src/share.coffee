(exports ? this).shareButton = (el, opts) ->
  hasClass = (elem, className) ->
    new RegExp(" " + className + " ").test " " + elem.className + " "

  addClass = (elem, className) ->
    elem.className += " " + className  unless hasClass(elem, className)
    return

  removeClass = (elem, className) ->
    newClass = " " + elem.className.replace(/[\t\r\n]/g, " ") + " "
    if hasClass(elem, className)
      newClass = newClass.replace(" " + className + " ", " ")  while newClass.indexOf(" " + className + " ") >= 0
      elem.className = newClass.replace(/^\s+|\s+$/g, "")
    return

  toggleClass = (elem, className) ->
    newClass = " " + elem.className.replace(/[\t\r\n]/g, " ") + " "
    if hasClass(elem, className)
      newClass = newClass.replace(" " + className + " ", " ")  while newClass.indexOf(" " + className + " ") >= 0
      elem.className = newClass.replace(/^\s+|\s+$/g, "")
    else
      elem.className += " " + className
    return

  addEvent = (element, evnt, funct) ->
    if element.attachEvent
      element.attachEvent "on" + evnt, funct
    else
      element.addEventListener evnt, funct, false



  $elements = document.querySelectorAll(el)
  console.log 'Elements', $elements


  ###########################
  # Check if elements exist #
  ###########################

  if $elements.length is 0
    console.log "Share Button: No elements found."
    return


  #######################
  # Set Global Elements #
  #######################

  $head = document.querySelector('head')
  $body = document.querySelector('body')


  #########################
  # Iterate over elements #
  #########################
  
  for $sharer, i in $elements
    console.log "Sharer", $sharer

    #################
    # Configuration #
    #################

    ## Add unique class to each element and hide

    addClass($sharer, "sharer-#{i}")
    # TODO: $sharer.hide()

    ## Set up options

    opts ?= {}
    config = {}

    ## Basic Configurations

    config.url    = opts.url || window.location.href
    config.text   = opts.text || $head.querySelector('meta[name=description]').getAttribute('content') || ''
    config.app_id = opts.app_id
    config.title  = opts.title
    config.image  = opts.image
    config.flyout = opts.flyout || 'top center'

    ## UI Configurations

    config.button_color      = opts.color || '#333'
    config.button_background = opts.background || '#e1e1e1'
    config.button_icon       = opts.icon || 'export'
    config.button_text       = if typeof(opts.button_text) is 'string'
      opts.button_text
    else
      'Share'

    ## Network-Specific Configurations

    set_opt = (base,ext) -> if opts[base] then opts[base][ext] || config[ext] else config[ext]

    config.twitter_url  = set_opt('twitter', 'url')
    config.twitter_text = set_opt('twitter', 'text')
    config.fb_url       = set_opt('facebook', 'url')
    config.fb_title     = set_opt('facebook', 'title')
    config.fb_caption   = set_opt('facebook', 'caption')
    config.fb_text      = set_opt('facebook', 'text')
    config.fb_image     = set_opt('facebook', 'image')
    config.gplus_url    = set_opt('gplus', 'url')

    #############
    ## PRIVATE ##
    #############

    ## Selector Configuration
    config.selector = ".#{$sharer.getAttribute('class').split(" ").join(".")}"

    ## Correct Common Errors
    config.twitter_text = encodeURIComponent(config.twitter_text)
    config.app_id = config.app_id.toString() if typeof config.app_id == 'integer'


    ################
    # Inject Icons #
    ################
    
    unless $head.querySelector('link[href="http://weloveiconfonts.com/api/?family=entypo"]')
      link = document.createElement("link")
      link.setAttribute("rel", "stylesheet")
      link.setAttribute("href", "http://weloveiconfonts.com/api/?family=entypo")
      $head.appendChild(link)

    
    ################
    # Inject Fonts #
    ################

    unless $head.querySelector('link[href="http://fonts.googleapis.com/css?family=Lato:900"]')
      link = document.createElement("link")
      link.setAttribute("rel", "stylesheet")
      link.setAttribute("href", "http://fonts.googleapis.com/css?family=Lato:900&text=#{config.button_text}")
      $head.appendChild(link)


    ##############
    # Inject CSS #
    ##############

    unless $head.querySelector("meta[name='sharer#{config.selector}']")
      $head.innerHTML += getStyles(config)

      meta = document.createElement("meta")
      meta.setAttribute("name", "sharer#{config.selector}")
      $head.appendChild(meta)


    ###############
    # Inject HTML #
    ###############

    $sharer.innerHTML = "<label class='entypo-#{config.button_icon}'><span>#{config.button_text}</span></label><div class='social #{config.flyout}'><ul><li class='entypo-twitter' data-network='twitter'></li><li class='entypo-facebook' data-network='facebook'></li><li class='entypo-gplus' data-network='gplus'></li></ul></div>"


    #######################
    # Set Up Facebook API #
    #######################

    if !window.FB && config.app_id && !document.querySelector('#fb-root')
      protocol = if ['http', 'https'].indexOf(window.location.href.split(':')[0]) is -1 then 'https://' else '//'
      $body.innerHTML += "<div id='fb-root'></div><script>(function(a,b,c){var d,e=a.getElementsByTagName(b)[0];a.getElementById(c)||(d=a.createElement(b),d.id=c,d.src='#{protocol}connect.facebook.net/en_US/all.js#xfbml=1&appId=#{config.app_id}',e.parentNode.insertBefore(d,e))})(document,'script','facebook-jssdk');</script>"


    ###########################
    # Share URL Configuration #
    ###########################

    paths =
      twitter: "http://twitter.com/intent/tweet?text=#{config.twitter_text}&url=#{config.twitter_url}"
      facebook: "https://www.facebook.com/sharer/sharer.php?u=#{config.fb_url}"
      gplus: "https://plus.google.com/share?url=#{config.gplus_url}"


    ##############################
    # Popup/Share Links & Events #
    ##############################

    bubbles = $body.querySelector(".social")
    bubble  = $sharer.querySelector(".social")
    label   = document.querySelector("#{config.selector} label")

    toggle = (e) =>
      console.log 'test'
      e.stopPropagation()
      toggleClass(bubble, 'active')

    open = -> addClass(bubble, 'active')

    close = -> removeClass(bubble, 'active')

    # TODO: Click Link

    #$sharer.find('label').on 'click', toggle
    #$sharer.find('li').on 'click', click_link

    addEvent label, 'click', =>
      console.log "toggle", bubble
      toggleClass(bubble, 'active')
      #toggle
      return


    for li in $sharer.querySelectorAll("#{config.selector} li")
      addEvent li, 'click', ->
        alert "click link"
        #click_link

    addEvent $body, 'click', ->
      removeClass(bubbles, 'active')

    # TODO: setTimeout (=> $sharer.show()), 250

    return

      
    
if jQuery?
  jQuery.fn.share = (opts) ->
    shareButton(jQuery(@), opts)



###
$ = jQuery
$.fn.share2 = (opts) ->

  if $(@).length is 0
    console.log "Share Button: No elements found."
    return


  $head = $('head')
  $body = $('body')

  $(@).each (i, el) ->
    $sharer = $(@)


    $sharer.addClass("sharer-#{i}")
    $sharer.hide()


    opts ?= {}
    config = {}


    config.url    = opts.url || window.location.href
    config.text   = opts.text || $('meta[name=description]').attr('content') || ''
    config.app_id = opts.app_id
    config.title  = opts.title
    config.image  = opts.image
    config.flyout = opts.flyout || 'top center'


    config.button_color      = opts.color || '#333'
    config.button_background = opts.background || '#e1e1e1'
    config.button_icon       = opts.icon || 'export'
    config.button_text       = if typeof(opts.button_text) is 'string'
      opts.button_text
    else
      'Share'


    set_opt = (base,ext) -> if opts[base] then opts[base][ext] || config[ext] else config[ext]

    config.twitter_url  = set_opt('twitter', 'url')
    config.twitter_text = set_opt('twitter', 'text')
    config.fb_url       = set_opt('facebook', 'url')
    config.fb_title     = set_opt('facebook', 'title')
    config.fb_caption   = set_opt('facebook', 'caption')
    config.fb_text      = set_opt('facebook', 'text')
    config.fb_image     = set_opt('facebook', 'image')
    config.gplus_url    = set_opt('gplus', 'url')


    config.selector = ".#{$sharer.attr('class').split(" ").join(".")}"

    config.twitter_text = encodeURIComponent(config.twitter_text)
    config.app_id = config.app_id.toString() if typeof config.app_id == 'integer'


    unless $('link[href="http://weloveiconfonts.com/api/?family=entypo"]').length
      $("<link />").attr(
        rel: "stylesheet"
        href: "http://weloveiconfonts.com/api/?family=entypo"
      ).appendTo $("head")


    unless $('link[href="http://fonts.googleapis.com/css?family=Lato:900"]').length
      $("<link />").attr(
        rel: "stylesheet"
        href: "http://fonts.googleapis.com/css?family=Lato:900"
      ).appendTo $("head")


    unless $("meta[name='sharer#{config.selector}']").length
      $('head').append(getStyles(config))
               .append("<meta name='sharer#{config.selector}'>")


    $(@).html("<label class='entypo-#{config.button_icon}'><span>#{config.button_text}</span></label><div class='social #{config.flyout}'><ul><li class='entypo-twitter' data-network='twitter'></li><li class='entypo-facebook' data-network='facebook'></li><li class='entypo-gplus' data-network='gplus'></li></ul></div>")


    if !window.FB && config.app_id && ($('#fb-root').length is 0)
      protocol = if ['http', 'https'].indexOf(window.location.href.split(':')[0]) is -1 then 'https://' else '//'
      $body.append("<div id='fb-root'></div><script>(function(a,b,c){var d,e=a.getElementsByTagName(b)[0];a.getElementById(c)||(d=a.createElement(b),d.id=c,d.src='#{protocol}connect.facebook.net/en_US/all.js#xfbml=1&appId=#{config.app_id}',e.parentNode.insertBefore(d,e))})(document,'script','facebook-jssdk');</script>")

    paths =
      twitter: "http://twitter.com/intent/tweet?text=#{config.twitter_text}&url=#{config.twitter_url}"
      facebook: "https://www.facebook.com/sharer/sharer.php?u=#{config.fb_url}"
      gplus: "https://plus.google.com/share?url=#{config.gplus_url}"

    parent  = $sharer.parent()
    bubbles = parent.find(".social")
    bubble  = parent.find("#{config.selector} .social")

    toggle = (e) ->
      e.stopPropagation()
      bubble.toggleClass('active')

    open = -> bubble.addClass('active')

    close = -> bubble.removeClass('active')

    click_link = ->
      link = paths[$(@).data('network')]
      if ($(@).data('network') == 'facebook') && config.app_id
        unless window.FB
          console.log "The Facebook JS SDK hasn't loaded yet."
          return

        window.FB.ui
          method: 'feed',
          name: config.fb_title
          link: config.fb_url
          picture: config.fb_image
          caption: config.fb_caption
          description: config.fb_text
      else
        window.open(link, 'targetWindow', 'toolbar=no,location=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=500,height=350')
      return false

    $sharer.find('label').on 'click', toggle
    $sharer.find('li').on 'click', click_link

    $body.on 'click', -> bubbles.removeClass('active')

    setTimeout (=> $sharer.show()), 250

    return {
      toggle: toggle.bind(@)
      open: open.bind(@)
      close: close.bind(@)
      options: config
      self: @
    }
  ###
