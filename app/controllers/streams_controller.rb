class StreamsController < ApplicationController

before_filter :require_login

def get_user_id
   result=User.where(email: current_user.email)
   return result[0][:_id]
end
helper_method :get_user_id
end
