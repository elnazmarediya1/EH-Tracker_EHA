class UserEventsController < ApplicationController
  helper_method :sort_column, :sort_direction

  EVENTS_PER_PAGE = 10

  def index
    assign_user
    @page = params.fetch(:page, 0).to_i
    @events = @user.events.where(active: true).order(sort_column => sort_direction).limit(EVENTS_PER_PAGE).offset(EVENTS_PER_PAGE * @page)
    @user_events = @user.user_events

    @user_event_count = @user.events.where(active: true).count
    @total_pages = (@user_event_count.to_f / EVENTS_PER_PAGE).ceil

    @all_users = User.where(admin: false).order(points: :desc)

    @username = 'My'
    @username = "#{@user.first_name} #{@user.last_name}'s" if current_user.admin? && (current_user.id != @user.id)
  end

  def past
    assign_user
    @page = params.fetch(:page, 0).to_i
    @events = @user.events.where(active: false).order(sort_column => sort_direction).limit(EVENTS_PER_PAGE).offset(EVENTS_PER_PAGE * @page)
    @user_events = @user.user_events

    @user_event_count = @user.events.where(active: false).count
    @total_pages = (@user_event_count.to_f / EVENTS_PER_PAGE).ceil

    @all_users = User.where(admin: false).order(points: :desc)

    @username = 'My'
    @username = "#{@user.first_name} #{@user.last_name}'s" if current_user.admin? && (current_user.id != @user.id)
  end

  def show
    assign_user

    @event = @user.events.find(params[:id])
    @user_event = @user.user_events.find_by(event_id: @event.id)
  end

  def new
    @event = Event.find(params[:event_id])

    if @event.active?
      @event_type = EventType.find(@event.event_type_id)
      @user_event = UserEvent.new
    else
      flash[:danger] = 'That event is inactive.'
      redirect_to(events_path)
    end
  end

  def create
    assign_user

    @user_event = UserEvent.new(user_event_params)
    @user_event.user_id = @user.id

    @event = Event.find(params[:user_event][:event_id])
    @event_type = EventType.find(@event.event_type_id)

    event_current_capacity = @event.user_events.where(event_id: @event.id).count
    event_max_capacity = @event.max_capacity

    if event_current_capacity >= event_max_capacity
      flash[:danger] = 'This event has already reached a maximum capacity.'
      redirect_to(events_path)
      return
    end

    if @event.active?
      if @user_event.save
        @user.update_column(:points, @user.points + (@event_type.points + @user_event.volunteer_hours))
        @user.update_column(:volunteer_hours, @user.volunteer_hours + @user_event.volunteer_hours)
        flash[:success] = 'You have registered successfully.'
        UserMailer.with(user: @user, event: @event, event_type: @event_type).confirm_event_registration.deliver_now
        redirect_to(user_events_path)
      else
        flash[:danger] = @user_event.errors.full_messages
        redirect_to(events_path)
      end
    else
      flash[:danger] = 'You are not allowed to register for inactive events.'
      redirect_to(events_path)
    end
  end

  def delete
    assign_user

    @event = @user.events.find(params[:id])
    @user_event = @user.user_events.find_by(event_id: @event.id)
  end

  def destroy
    @user_event = UserEvent.find(params[:id])

    @user = @user_event.user
    @event = @user_event.event
    @event_type = @event.event_type

    if @user_event.destroy
      @user.update_column(:points, @user.points - (@event_type.points + @user_event.volunteer_hours))
      @user.update_column(:volunteer_hours, @user.volunteer_hours - @user_event.volunteer_hours)
      flash[:success] = 'You have successfully cancelled registration for this event.'
      if current_user.admin?
        redirect_to(user_events_path(current_user.id, view_id: @user.id))
      else
        redirect_to(user_events_path)
      end
    else
      flash[:danger] = 'Failed to cancel registration.'
      render('delete')
    end
  end

  private

  def assign_user
    @user = if current_user.admin?
              if params.key?(:view_id)
                User.find(params[:view_id])
              else
                User.find(current_user.id)
              end
            else
              User.find(current_user.id)
            end
  end

  def user_event_params
    params.require(:user_event).permit(:event_id, :volunteer_hours)
  end

  def sort_column
    Event.column_names.include?(params[:sort]) ? params[:sort] : 'name'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
