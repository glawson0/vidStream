@getVidController=(VidPlayer, name) ->
  new VidController(VidPlayer, name)

class VidController
  @vidList
  @previous
  @liked=false
   
  getSuccess: (data) ->
    if data['vids'][0]['v']==@previous
      @nextVideo()
    else    
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
  getLiked: () ->
   @liked
  nextVideo: ()->
    if !!@previous
      $.ajax
         url: "/streams/watched"
         data: {'name': @name}
         dataType:"json"
    newvid=@vidList.shift()
    if (!!newvid)
      while (newvid['v']==@previous)
         newvid=@vidList.shift()
      @previous=newvid['v']
      @liked=newvid['l']
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
    if id!=null
      $.ajax 
        url: "/streams/like"
        data: {'name': @name, 'id': id}
        dataType: "json"
      $('#vurl').val("added")
    else
      $('#vurl').val("bad URL")
    false
  
  like: () ->
    $.ajax 
      url: "/streams/like"
      data: {'name': @name, 'id': @previous}
      dataType: "json"
    @liked=true
    false
   
  dislike: () ->
    $.ajax 
      url: "/streams/dislike"
      data: {'name': @name, 'id': @previous}
      dataType: "json"
    false

  getList: ()->
    return @vidList
  
