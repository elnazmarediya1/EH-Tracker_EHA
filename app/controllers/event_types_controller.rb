class EventTypesController < ApplicationController
  before_action :authorize_admin

  def index
    @event_types = EventType.all
  end

  def show
    @event_type = EventType.find(params[:id])
  end

  def new
    @event_type = EventType.new
  end

  def create
    @event_type = EventType.new(event_type_params)

    if @event_type.save
      flash[:success] = 'Event type created successfully.'
      redirect_to(event_types_path)
    else
      flash[:danger] = @event_type.errors.full_messages
      render('new')
    end
  end

  def edit
    @event_type = EventType.find(params[:id])
  end

  def update
    @event_type = EventType.find(params[:id])
    subtract_old_points

    if @event_type.update_attributes(event_type_params)
      flash[:success] = 'Event type updated successfully.'
      redirect_to(event_types_path)
    else
      flash[:danger] = @event_type.errors.full_messages
      render('edit')
    end

    add_points_back
  end

  def delete
    @event_type = EventType.find(params[:id])
  end

  def destroy
    @event_type = EventType.find(params[:id])

    if @event_type.destroy
      flash[:success] = 'Event type deleted successfully.'
      redirect_to(event_types_path)
    else
      flash[:danger] = 'Failed to delete event type.'
      render('delete')
    end
  end

  private

  def subtract_old_points
    events = @event_type.events

    events.each do |event|
      user_events = event.user_events

      user_events.each do |user_event|
        user = user_event.user
        user.update_column(:points, user.points - @event_type.points)
        user.update_column(:volunteer_hours, user.volunteer_hours - user_event.volunteer_hours)
      end
    end
  end

  def add_points_back
    events = @event_type.events

    events.each do |event|
      user_events = event.user_events

      user_events.each do |user_event|
        user = user_event.user
        user.update_column(:points, user.points + @event_type.points)
        user.update_column(:volunteer_hours, user.volunteer_hours + user_event.volunteer_hours)
      end
    end
  end

  def event_type_params
    params.require(:event_type).permit(:name, :points)
  end
end
