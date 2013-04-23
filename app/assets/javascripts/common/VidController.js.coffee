@getVidController=(VidPlayer, name) ->
  new VidController(VidPlayer, name)

class VidController
  vidList=[]
  previous=null
   
  @getSuccess =(data) ->
    vidList=vidList.concat(data['vids'])
    if !data['rec']
       $.ajax
         url: "/streams/rec_vids"
         data: {'name': @name}

  constructor: (@VidPlayer, @name) ->
    $.ajax
      url: "/streams/get_vids"
      success: (data) => @getSuccess(data, @name)
      dataType:"json"
  
  nextVideo: ()->
    #previous=vidList.shift()
    $.ajax
      url: "/streams/get_vids"
      success: (data) => @getSuccess(data, @name)
      dataType:"json"
    return previous

  queueVideo: (tag)->
    vidList.push(tag)

  getList: ()->
    return vidList
  
