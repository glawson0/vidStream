class @streamloaderView extends Backbone.View
   initialize: ->
      _.bindAll @
      
      @controller = new getVidController(@el);

      @render()
   
   render: ->
      params = {"allowScriptAccess": "always" }
      atts = {"id" : "myytplayer" }
      $(@el).append '<ul id="temp"><li>Hello, Backbone!</li></ul>'
      $(@el).append (@options.template)
      alert (@options.template)
      @options.fun('ytplayer')
      $.getScript('swfobject.js', loaded: ->
         swfobject.embededSWF("http://www.youtube.com/v/V6V9gpXZgvo&enablejsapi=1&playerapiid=ytplayer", "ytplayer", "425", "365", "8", null, null, params, atts)
      )


   onytplayerStateChange: ->
      if(newState==0)
         loadNewVideo()
   
   loadNewVideo: -> 
      if (@ytplayer) 
         @ytplayer.loadVideoById(controller.nextVideo(), 0)

