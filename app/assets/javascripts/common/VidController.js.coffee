@getVidController=(VidPlayer, name) ->
  new VidController(VidPlayer, name)

class VidController
  @vidList
  @previous
   
  getSuccess: (data) ->
    @vidList=@vidList.concat(data['vids'])
    if data['rec']
       $.ajax
         url: "/streams/a_rec_vids"
         data: {'name': @name}

  constructor: (@VidPlayer, @name) ->
    @vidList=[]
    @previous =null
    $.ajax
      url: "/streams/get_vids"
      data: {'name': @name}
      success: (data) => @getSuccess(data)
      dataType:"json"
  
  getVideo: ()->
    if !@previous
       @nextVideo()
    else
       @previous
  
  nextVideo: ()->
    if !!@previous
      $.ajax
         url: "/streams/watched"
         data: {'name': @name}
         dataType:"json"
    @previous=@vidList.shift()
    if @vidList.length ==0
      $.ajax
         url: "/streams/get_vids"
         data: {'name': @name}
         success: (data) => @getSuccess(data)
         dataType:"json"
    return @previous

  queueVideo: (tag)->
    @vidList.push(tag)
 
  add:(id) ->
   $.ajax
     url: "/streams/a_add_video"
     data: {'name':@name, id}

  like: () ->
    $.ajax 
      url: "/streams/like"
      data: {'name': @name, 'id': @previous}
      dataType: "json"
    false
   
  dislike: () ->
    $.ajax 
      url: "/streams/dislike"
      data: {'name': @name, 'id': @previous}
      dataType: "json"
    false

  getList: ()->
    return @vidList
  
