class LeaderboardsController < ApplicationController
  def index
    redirect_to users_path if current_user.admin? # admins have the Manage Users page
    @top_ten_users = User.where(admin: false).order(points: :desc).limit(10)
    @user = User.find_by_id(current_user.id)
    @all_users = User.where(admin: false).order(points: :desc)
  end
end
