@getVidController=(VidPlayer) ->
  new VidController(VidPlayer)

class VidController
  vidList=[]
  constructor: (@VidPlayer) ->
    vidList.push("lJu2G1dvTIU")
    vidList.push("aegRMcI-jnM")
  
  nextVideo: ()->
    vidList.shift()

  queueVideo: (tag)->
    vidList.push(tag)

  getList: ()->
    return vidList
  
