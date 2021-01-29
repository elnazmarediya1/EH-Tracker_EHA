class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def authorize_admin
    redirect_back fallback_location: root_path, alert: 'Access denied. You must be an Admin to access this resource.' unless current_user.admin?
  end
end
