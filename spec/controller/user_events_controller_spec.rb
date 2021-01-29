require 'rails_helper'
require_relative '../support/devise'
require 'support/factory_bot'

RSpec.describe UserEventsController, type: :controller do
  describe 'GET /' do
    login_admin
    context 'when admin is logged in' do
      it 'returns 200:OK' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET index' do
    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :index
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders user_events/id/index page' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'renders user_events/id/index page' do
        get :index
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET show' do
    before(:context) do
      @event_type1 = create(:event_type)
      @event1 = create(:event, event_type_id: @event_type1.id)
      @user1 = create(:user)
      @user_event1 = @user1.user_events.where(event_id: @event1.id, user_id: @user1.id).first
    end

    context 'with params' do
      it 'show item' do
        get :show, params: { id: @user1.id }
        expect(response).not_to have_http_status(:success)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :show, params: { id: @user1.id }
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  describe 'GET create' do
    before(:context) do
      @event_type1 = create(:event_type)
      @event1 = create(:event, event_type_id: @event_type1.id)
      @user1 = create(:user)
      @user_event1 = @user1.user_events.where(event_id: @event1.id, user_id: @user1.id).first
    end

    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :create
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  describe 'POST create' do
    before(:context) do
      @event_type1 = create(:event_type)
      @user1 = create(:user)
    end

    context 'when registering for an active event when save succeeds' do
      login_user
      it 'redirects the user to the user events view' do
        @event1 = create(:event, event_type_id: @event_type1.id, active: true)

        post :create, params: { user_event: { event_id: @event1.id, volunteer_hours: 5 }, event_id: @event1.id }
        expect(response).to redirect_to(user_events_path)
      end
    end

    context 'when registering for an active event when save fails' do
      login_user
      it 'redirects the user to the events view' do
        @event1 = create(:event, event_type_id: @event_type1.id, active: true)

        post :create, params: { user_event: { event_id: @event1.id, volunteer_hours: nil }, event_id: @event1.id }
        expect(response).to redirect_to(events_path)
      end
    end

    context 'when registering for an inactive event' do
      login_user
      it 'redirects the user to the events view' do
        @event1 = create(:event, event_type_id: @event_type1.id, active: false)

        post :create, params: { user_event: { event_id: @event1.id, volunteer_hours: 5 }, event_id: @event1.id }
        expect(response).to redirect_to(events_path)
      end
    end
  end

  describe 'GET new' do
    before(:context) do
      @event_type1 = create(:event_type)
      @event1 = create(:event, event_type_id: @event_type1.id)
      @user1 = create(:user)
      @user_event1 = @user1.user_events.where(event_id: @event1.id, user_id: @user1.id).first
    end

    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :new, params: { event_id: @event1.id }
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders user_events/id/new page ' do
        get :new, params: { id: @user_event1, event_id: @event1.id, user_id: @user1 }
        expect(response).to render_template(:new)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'renders user_events/id/new page ' do
        get :new, params: { id: @user_event1, event_id: @event1.id, user_id: @user1 }
        expect(response).to render_template(:new)
      end
    end

    context 'when registering for an inactive event' do
      login_user

      it 'redirects the user to the events view' do
        @event_type1 = create(:event_type)
        @event1 = create(:event, event_type_id: @event_type1.id, active: false)

        get :new, params: { event_id: @event1.id }
        expect(response).to redirect_to(events_path)
      end
    end
  end

  describe 'DELETE destroy' do
    before(:context) do
      @event_type1 = create(:event_type)
      @event1 = create(:event, event_type_id: @event_type1.id)
      @user1 = create(:user)
    end

    context 'with valid data' do
      let(:user_event1) { create(:user_event, event_id: @event1.id, user_id: @user1.id) }

      before do
        allow(user_event1).to receive(:destroy).and_return(true)
        allow(UserEvent).to receive(:find).and_return(user_event1)
      end

      it 'renders the event types view' do
        @admin = FactoryBot.create(:user, admin: true, superadmin: false)
        sign_in @admin
        delete :destroy, params: { id: user_event1.id }
        expect(response).to redirect_to(user_events_path(@admin.id, view_id: @user1.id))
      end
    end

    context 'with invalid data' do
      login_admin

      let(:user_event1) { create(:user_event, event_id: @event1.id, user_id: @user1.id) }

      before do
        allow(user_event1).to receive(:destroy).and_return(false)
        allow(UserEvent).to receive(:find).and_return(user_event1)
      end

      it 'renders the delete view' do
        delete :destroy, params: { id: user_event1.id }
        expect(response).to render_template(:delete)
      end
    end
  end
end
