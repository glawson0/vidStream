@getTag= (url)->
   regExp =/^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
   match = url.match(regExp);
   if (match&&match[2].length==11)
       return match[2];
   else
       return null
   

