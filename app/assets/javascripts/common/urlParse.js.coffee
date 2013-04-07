@getTag= (url)->
  list=url.match(/youtube\.com\/watch\?v=(\w+)/)
  if list
    return list[1]
  else
    return null

