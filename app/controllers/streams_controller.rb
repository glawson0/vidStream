class StreamsController < ApplicationController
ActionController::Base.logger = Logger.new(STDOUT)
require 'open-uri'
before_filter :require_login

def get_vids
   user= current_user.email
   name= params[:name]
   stream=Stream.where({:_id =>{:u =>user, :id =>name}}).first
   vids= stream[:w][0,2]
   if stream[:w].length>2
      render :json => {:vids => vids, :rec => false}
   else
      render :json => {:vids => vids, :rec => true}

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
   streams=Stream.where({'_id.u'=> user}).limit(4)
   render :json => {:streams =>streams}
end
helper_method :get_streams

def create_stream
   user= current_user.email
   name= params[:name]
   videos= params[:videos]
   if Stream.where({:_id=> {:u =>user, :id =>name}}).exists?
     render :json => {:success => false}
     return
   end
   stream=( {:_id=> {:u =>user, :id =>name},
     :bw =>{}, :du => {:ps => 0, :sx => 0, :sx2 => 0,
     :m => 0, :sd => 0}, :mw =>{}, :cs => {}, :v => [], 
     :l => {},:d => {}, :w =>[] })

   for id in videos
      add_video(id, stream)
   end
   Stream.create!(stream)
   render :json => {:success => true}
   rec_vids(name)
end

def add_video (id, stream)
   if(stream[:l].has_key?(id) or stream[:d].has_key?(id))
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
      if stream[:bw].has_key?(word)
         stream[:bw][word]+=1
      else
         stream[:bw][word]=1
      end
   end
   time= video[:du]

   logger.info time
   stream[:du][:ps] += 1
   stream[:du][:sx] += time
   stream[:du][:m]=stream[:du][:sx]/Float(stream[:du][:ps])
   stream[:du][:sx2] += (time*time)
   stream[:du][:sd]=Math.sqrt(((stream[:du][:ps]*stream[:du][:sx2])-(stream[:du][:sx]*stream[:du][:sx]))/
                              (stream[:du][:ps]*stream[:du][:ps]))
   stream[:v].unshift(video[:_id])
   if stream[:v].length>20
      stream[:v].pop
   end
   
   return stream
end

def get_video (id)
   contents = URI.parse(
         'https://gdata.youtube.com/feeds/api/videos/%s?v=2&alt=json'%id).read
      vidData=JSON.parse(contents)
      logger.info vidData["entry"]["media$group"].keys
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
      return video
end

def a_rec_vids
   name=params[:name]
   rec_vids(name)
end

def rec_vids (name)
   name=params[:name]
   user=current_user.email
   Stream.where({:_id=> {:u =>user, :id =>name}}).push_all(:w, ["lJu2G1dvTIU","aegRMcI-jnM"])
end

def watched 
   user=current_user.email
   name=params[:name]
   stream= Stream.where({:_id =>{:u => user, :id => name}}).first
   vid=stream[:w].shift
   stream[:v].push(vid)
   while stream[:v].length >30
      stream[:v].shift
   end
   stream.save
   render :nothing => true
end

end
