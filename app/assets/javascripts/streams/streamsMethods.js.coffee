@createSuccess= (data) ->
  if data['success']
    $('#message').text("Stream Created!")
    $('#addDeets').hide()
    $('#makenew').show(80)
    $(':input','#addDeets').val("")
  else
    $('#message').text("Stream Already Exists")
@createError= (data) ->
  $('#message').text("Server Error Try Again")


@createStream=() ->
  input={}
  input['name']=$('#title').val()
  if input['name']==""
    $('#message').text("Stream title required")
    return false
  
  text=$('#vids').val()
  urls=text.split(",")
  
  tags=[]
  for url in urls
     tag=getTag(url)
     if tag==null
       $('#message').text("videos contains nonvalid url")
       return
     else
       tags.push(tag)
  input['videos']=tags
  $.ajax 
    url: "/streams/create_stream"
    data: input 
    success: (data)=> @createSuccess(data)
    #error: (error) => @createError(error)
    dataType: "json"

  
