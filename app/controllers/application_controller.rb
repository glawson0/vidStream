class ApplicationController < ActionController::Base
  protect_from_forgery



  #skip_before_filter :require_login, :only=>"streams"

  private
  def require_login
    unless current_user
      redirect_to  '/users/sign_in'
    end
  end

  def after_sign_in_path_for(resource)
    '/streams' 
  end


end
