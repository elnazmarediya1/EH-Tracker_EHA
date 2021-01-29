class EventsController < ApplicationController
  before_action :authorize_admin, except: %i[index past show]
  helper_method :sort_column, :sort_direction

  EVENTS_PER_PAGE = 10

  def index
    Event.expired.update_all(active: false)
    @page = params.fetch(:page, 0).to_i.abs
    @total_pages = (Event.active.count.to_f / EVENTS_PER_PAGE).ceil
    @events = Event.active.order(sort_column => sort_direction).limit(EVENTS_PER_PAGE).offset(EVENTS_PER_PAGE * @page)
    @user_events = current_user.user_events
  end

  def past
    Event.expired.update_all(active: false)
    @page = params.fetch(:page, 0).to_i.abs
    @total_pages = (Event.not_active.count.to_f / EVENTS_PER_PAGE).ceil
    @events = Event.not_active.order(sort_column => sort_direction).limit(EVENTS_PER_PAGE).offset(EVENTS_PER_PAGE * @page)
    @user_events = current_user.user_events
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
    @types = EventType.all
  end

  def create
    @event = Event.new(event_params)
    @event.created_by_uin = current_user.uin

    if @event.save
      flash[:success] = 'Event created successfully.'
      redirect_to(events_path)
    else
      flash[:danger] = @event.errors.full_messages
      render('new')
    end
  end

  def edit
    @event = Event.find(params[:id])
    @types = EventType.all
  end

  def update
    @event = Event.find(params[:id])

    current_max = @event.max_capacity.to_i
    new_max = event_params[:max_capacity].to_i

    if new_max < current_max
      flash[:danger] = 'Event failed to update. Max capacity cannot be decreased.'
      redirect_to(event_path(@event))

      return
    end

    if @event.update_attributes(event_params)
      flash[:success] = 'Event updated successfully.'
      redirect_to(event_path(@event))
    else
      flash[:danger] = @event.errors.full_messages
      render('edit')
    end
  end

  def delete
    @event = Event.find(params[:id])
  end

  def destroy
    @event = Event.find(params[:id])

    if @event.destroy
      flash[:success] = 'Event deleted successfully.'
      redirect_to(events_path)
    else
      flash[:danger] = 'Failed to delete event.'
      render('delete')
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :date, :location, :description, :event_type_id, :active, :max_capacity, :event_type_id)
  end

  def sort_column
    Event.column_names.include?(params[:sort]) ? params[:sort] : 'name'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
