class @streamloaderView extends Backbone.View
   
   initialize: ->
      _.bindAll @
      @render()
   
   render: ->
      $(@el).append '<ul><li>Hello, Backbone!</li></ul>'
