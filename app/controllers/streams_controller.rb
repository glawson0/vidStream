class StreamsController < ApplicationController
ActionController::Base.logger = Logger.new(STDOUT)
require 'open-uri'
before_filter :require_login

def get_vids
   user= current_user.email
   name= params[:name]
   stream=Stream.where({:_id =>{:u =>user, :id =>name}}).first
   vids= stream[:w]

   if vids.length == 0
      render :json => {:vids => [{:v =>(stream[:l].keys.shuffle)[0], :l=>true}] , :rec => true}
   elsif vids.length <6
      render :json => {:vids => (vids[0,(vids.length<3? vids.length-1: 3)]).map{|x| {:v=>x,:l =>stream[:l].has_key?(x)} }, :rec => true}
   else
      render :json => {:vids => (vids[0,3]).map{|x| {:v=> x,:l=> stream[:l].has_key?(x)} }, :rec => false}
   end
end
helper_method :get_vids
def get_user_id
   print "hello\n"
   result=User.where(email: current_user.email).only(:_id)
   render :json => result[0]
end
helper_method :get_user_id

def get_streams
   user= current_user.email
   streams=Stream.where({'_id.u'=> user}).sort({'_id.id'=> 1})
   render :json => {:streams =>streams}
end
helper_method :get_streams
def del_stream
   user= current_user.email
   name= params[:name]
   val=Stream.where({:_id =>{:u =>user, :id =>name}}).delete_all
   render :json => {:status => val}
end

def create_stream
   user= current_user.email
   name= params[:name]
   videos= params[:videos]
   if Stream.where({:_id=> {:u =>user, :id =>name}}).exists?
     render :json => {:success => false}
     return
   end
   stream=( {:_id=> {'u' =>user, 'id' =>name},
     :bw =>{}, :du => {'ps' => 0, 'sx' => 0, 'sx2' => 0,
     'm' => 0, 'sd' => 0}, :mw =>{}, :cs => {}, :v => [], 
     :l => {},:d => {}, :w =>[], :curr => false, :rec =>true })

   for id in videos
      add_video(id, stream)
   end
   Stream.create!(stream)
   render :json => {:success => true}
   rec_vids(name)
end

def like 
   name=params[:name]
   user= current_user.email
   id=params[:id]
   stream=Stream.where({'_id' =>{'u' =>user, 'id' =>name}}).first
   updated=add_video(id,stream)
   stream2=Stream.where({'_id' =>{'u' =>user, 'id' =>name}}).first
   val=stream2.update_attributes(cs: updated[:cs],du: updated[:du],bw: updated[:bw], mw: updated[:mw],l: updated[:l])
   render :json => {:success =>val}
end
   
def dislike
   name=params[:name]
   user= current_user.email
   id=params[:id]
   stream=Stream.where({'_id' =>{'u' =>user, 'id' =>name}}).first
   if(stream[:l].has_key?(id) or stream[:d].has_key?(id))
      logger.info "skipped"
      render :json => {:success =>true}
      return
   end
   video=Video.where({:_id => id}).first
   for word in video[:k]
      if stream[:bw].has_key?(word)
         stream["bw"][word]-=1
         if stream[:bw][word]<=0
            stream["bw"].delete(word)
         end
      elsif stream[:mw].has_key?(word)
         stream["mw"][word]+=1
      else
         stream["mw"][word]=1
      end
   end
   stream["d"][video["_id"]]=1
   stream2 = Stream.where({'_id' =>{'u' =>user, 'id' =>name}}).first
   val = stream2.update_attributes(bw: stream[:bw], mw: stream[:mw], d: stream[:d])

   render :json => {:success =>val}
end


def add_video (id, stream)
   if(stream[:l].has_key?(id) or stream[:d].has_key?(id))
      logger.info "skipped"
      return stream
   end

   stream[:l][id]=1

   video=Video.where({:_id => id}).first
   if not video
      video=get_video(id)
      Video.create!(video)
   end
   #category info
   if stream[:cs].has_key?(video[:c])
      stream[:cs][video[:c]]+=1
   else
      stream[:cs][video[:c]]=1
   end
   #keyword stuff
   for word in video[:k]
      if stream[:mw].has_key?(word)
         stream[:mw][word]-=1
         if stream[:mw][word]<=0
            stream["mw"].delete(word)
         end
      elsif stream[:bw].has_key?(word)
         stream[:bw][word]+=1
      else
         stream[:bw][word]=1
      end
   end
   time= video[:du]

   #logger.info stream 
   stream[:du]['ps'] += 1
   stream[:du]['sx'] += time
   stream[:du]['m']=stream[:du]['sx']/Float(stream[:du]['ps'])
   stream[:du]['sx2'] += (time*time)
   stream[:du]['sd']=Math.sqrt(((stream[:du]['ps']*stream[:du]['sx2'])-(stream[:du]['sx']*stream[:du]['sx']))/
                              (stream[:du]['ps']*stream[:du]['ps']))
   return stream
end
def a_add_video
   name=params[:name]
   id= params[:id]
   user= current_user.email
   stream=Stream.where({'_id' =>{'u' =>user, 'id' =>name}}).first
   add_video(id, stream)
   render :json => {:success => true}
end

def get_video (id)
   contents = URI.parse(
         'https://gdata.youtube.com/feeds/api/videos/%s?v=2&alt=json'%id).read
      vidData=JSON.parse(contents)
      logger.info vidData["entry"].keys
      text=vidData["entry"]["media$group"]["media$description"]["$t"].split
      text= text.concat(vidData["entry"]["title"]["$t"].split)
      text= text.map{ |x| x.downcase.gsub(/[^a-z'\s]/, '')}
      text=text.uniq
      keywords= Set.new(text)
      stopwrds= Stopword.each().collect{|x| x['_id']}
      keywords= keywords.subtract(stopwrds)
      video={
         :_id => id,
         :t => vidData["entry"]["title"]["$t"],
         :u => vidData["entry"]["link"][0]["href"],
         :k => keywords.to_a(),
         :v => vidData["entry"]["yt$statistics"]["viewCount"],
         :f => vidData["entry"]["yt$statistics"]["favoriteCount"],
         :ch => vidData["entry"]["author"][0]["name"]["$t"].downcase,
         :d => vidData["entry"]["media$group"]["media$description"]["$t"],
         :du => Integer(vidData["entry"]["media$group"]["yt$duration"]["seconds"]),
         :c => vidData["entry"]["media$group"]["media$category"][0]["$t"]
      }
      Channel.create({:_id=> video[:ch]})
      return video
end

def a_rec_vids
   name=params[:name]
   ret=rec_vids(name)
   render :json => {:success => ret}
end

def rec_vids (name)
   user=current_user.email
   strm= Stream.where({:_id=> {:u =>user, :id =>name}}).first
   strm.set(:rec, true)
   if not strm["cur"]
      strm.set(:cur, false)
   end
   strm.save
   if fork.nil?
      logger.info "\nFORKING NOW\n"
      exec("~glawson/vidStream/recScript/recomender.py")
      abort("proc done")
   end
   return true
=begin
   if (strm[:w].length >6)
      return -1
   end
   videos=Video.where({"$and" => [{:k =>{"$in" => strm[:bw].keys}},{:_id =>{"$nin" => strm[:d].keys}}, { :_id =>{"$nin" => strm[:w]}}, { :_id =>{"$nin" => strm[:v]}}]}) 
   logger.info videos.count
   sd= strm[:du]["sd"]
   if sd<3
      nsd= strm[:du]["m"]*0.1
      if nsd>sd
         sd=nsd
      end
   end
   maxt=strm[:du]["m"]+sd
   mint=strm[:du]["m"]-sd
   scores=[]
   for video in videos
      if(video[:du]<maxt and video[:du]>mint)
         next
      end
      count =0

      for word in video[:k]
         if strm[:bw].member?word
            count+=strm[:bw][word]
         elsif strm[:mw].member?word
            count -=1
         end
      end

      if strm[:cs].keys.include?(video[:c])
         count+=5
      end
      scores.push({:count => count,:video => video})
   end
   scores=scores.sort{|a,b| b[:count] <=> a[:count] }
  
   rec = Stream.where({:_id=> {:u =>user, :id =>name}}).first
   if (rec[:w].length<6)
      Stream.where({:_id=> {:u =>user, :id =>name}}).push_all(:w, scores[0,5].map{|a| a[:video]["_id"]})
   end
   return scores[0,6]
=end
end

def watched 
   user=current_user.email
   name=params[:name]
   stream= Stream.where({:_id =>{:u => user, :id => name}}).first
   vid=stream.w.shift
   if (!vid)
      render :json => {"return" => false}
   else
      stream.v.push(vid)
      while stream.v.length >60
         stream.v.shift
      end
      val=stream.save!
      render :json => {"return" => val}
   end
end

end
