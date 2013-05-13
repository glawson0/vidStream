@getVidController=(VidPlayer, name) ->
  new VidController(VidPlayer, name)

class VidController
  vidList=[]
  previous=null
   
  getSuccess: (data) ->
    vidList=vidList.concat(data['vids'])
    if data['rec']
       $.ajax
         url: "/streams/a_rec_vids"
         data: {'name': @name}

  constructor: (@VidPlayer, @name) ->
    $.ajax
      url: "/streams/get_vids"
      data: {'name': @name}
      success: (data) => @getSuccess(data)
      dataType:"json"
  
  nextVideo: ()->
    if !!previous
      $.ajax
         url: "/streams/watched"
         data: {'name': @name}
         dataType:"json"
    previous=vidList.shift()
    if vidList.length ==0
      $.ajax
         url: "/streams/get_vids"
         data: {'name': @name}
         success: (data) => @getSuccess(data)
         dataType:"json"
    return previous

  queueVideo: (tag)->
    vidList.push(tag)
  
  like: () ->
    $.ajax 
      url: "/streams/like"
      data: {'name': @name, 'id': previous}
      dataType: "json"
    false
   
  dislike: () ->
    $.ajax 
      url: "/streams/dislike"
      data: {'name': @name, 'id': previous}
      dataType: "json"
    false

  getList: ()->
    return vidList
  
