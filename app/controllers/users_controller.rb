class UsersController < ApplicationController
  before_action :authorize_admin
  helper_method :sort_column, :sort_direction

  def export_csv
    @users = User.all
    respond_to do |export_csv|
      export_csv.html
      export_csv.csv do
        send_data @users.to_csv, filename: "All_Users_#{Date.today}.csv"
      end
    end
  end

  def index
    @members = User.where(admin: false).order(sort_column => sort_direction)
    @admins = User.where(admin: true)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(users_params)
      flash[:notice] = 'User updated successfully.'
      redirect_to(user_path(@user))
    else
      flash[:danger] = @user.errors.full_messages
      render('edit')
    end
  end

  def new; end

  def delete
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])

    if @user.destroy
      flash[:success] = 'User deleted successfully.'
      redirect_to(users_path)
    else
      flash[:danger] = 'Failed to delete user.'
      render('delete')
    end
  end

  private

  def users_params
    params.require(:user).permit(:admin, :points, :volunteer_hours, :first_name, :last_name, :uin)
  end

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : 'points'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
