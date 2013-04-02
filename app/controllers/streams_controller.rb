class StreamsController < ApplicationController

before_filter :require_login

def get_user_id
   result=User.where(email: current_user.email)
   return result[0][:_id]
end
helper_method :get_user_id

def create_stream
   user= params[:user]
   name= params[:name]
   videos= params[:videos]
   Stream.create!( {:_id=> {:u =>user, :id =>name},
     :bw =>[], :du => {:ps => 0, :sx => 0, :sx2 => 0,
     :m => 0, :sd => 0}, :mw =>0, :cs => [], :v => []})
end

end
