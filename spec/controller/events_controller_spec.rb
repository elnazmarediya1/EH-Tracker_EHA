require 'rails_helper'
require_relative '../support/devise'
require 'support/factory_bot'

RSpec.describe EventsController, type: :controller do
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
      it 'renders events/index page' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'renders events/index page' do
        get :index
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET past' do
    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :index
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders events/index page' do
        get :past
        expect(response).to render_template(:past)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'renders events/index page' do
        get :past
        expect(response).to render_template(:past)
      end
    end
  end

  describe 'GET show' do
    before(:context) do
      @event_type1 = create(:event_type)
      @event1 = create(:event, event_type_id: @event_type1.id)
    end

    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :show, params: { id: @event1.id }
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders events/show page' do
        get :show, params: { id: @event1.id }
        expect(response).to render_template(:show)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'renders events/show page' do
        get :show, params: { id: @event1.id }
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'GET new' do
    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :new
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders events/new page ' do
        get :new
        expect(response).to render_template(:new)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not allow access to events/new page' do
        get :new
        expect(response).to redirect_to(controller: 'welcome', action: 'index')
      end
    end
  end

  describe 'GET create' do
    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :create
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not allow access to events/create page' do
        get :create
        expect(response).to redirect_to(controller: 'welcome', action: 'index')
      end
    end
  end

  describe 'POST create' do
    before(:context) do
      @event_type1 = create(:event_type)
    end

    context 'with valid data' do
      login_admin
      it 'creates the event and redirect the admin to the events view' do
        post :create, params: { event: { name: 'test_event', date: DateTime.now, location: 'test_event_location', description: 'test_event_description', event_type_id: @event_type1.id, active: true, max_capacity: 5 } }
        expect(response).to redirect_to(events_path)
      end
    end

    context 'with invalid data' do
      login_admin
      it 'renders the new view' do
        post :create, params: { event: { name: nil, date: nil, location: nil, description: nil, event_type_id: nil, active: nil, max_capacity: nil } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET edit' do
    before(:context) do
      @event_type1 = create(:event_type)
      @event1 = create(:event, event_type_id: @event_type1.id)
    end

    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :edit, params: { id: @event1.id }
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders events/edit page ' do
        get :edit, params: { id: @event1.id }
        expect(response).to render_template(:edit)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not allow access to events/edit page' do
        get :edit, params: { id: @event1.id }
        expect(response).to redirect_to(controller: 'welcome', action: 'index')
      end
    end
  end

  describe 'PATCH update' do
    before(:context) do
      @event_type1 = create(:event_type)
      @event1 = create(:event, event_type_id: @event_type1.id)
    end

    context 'with valid data' do
      login_admin
      it 'updates the event details and redirect the admin to the specific event details view' do
        patch :update, params: { id: @event1.id, event: { name: 'test_event', date: DateTime.now, location: 'test_event_location', description: 'test_event_description', event_type_id: @event_type1.id, active: true, max_capacity: 5 } }
        expect(response).to redirect_to(event_path(@event1))
      end
    end

    context 'with invalid data' do
      login_admin
      it 'renders the edit view' do
        patch :update, params: { id: @event1.id, event: { name: nil, date: nil, location: nil, description: nil, event_type_id: nil, active: nil, max_capacity: 5 } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'GET delete' do
    before(:context) do
      @event_type1 = create(:event_type)
      @event1 = create(:event, event_type_id: @event_type1.id)
    end

    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :delete, params: { id: @event1.id }
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders events/delete page ' do
        get :delete, params: { id: @event1.id }
        expect(response).to render_template(:delete)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not allow access to events/delete page' do
        get :delete, params: { id: @event1.id }
        expect(response).to redirect_to(controller: 'welcome', action: 'index')
      end
    end
  end

  describe 'DELETE destroy' do
    context 'with valid data' do
      login_admin

      let(:event1) { create(:event) }

      before do
        allow(event1).to receive(:destroy).and_return(true)
        allow(Event).to receive(:find).and_return(event1)
      end

      it 'renders the event types view' do
        delete :destroy, params: { id: event1.id }
        expect(response).to redirect_to(events_path)
      end
    end

    context 'with invalid data' do
      login_admin

      let(:event1) { create(:event) }

      before do
        allow(event1).to receive(:destroy).and_return(false)
        allow(Event).to receive(:find).and_return(event1)
      end

      it 'renders the delete view' do
        delete :destroy, params: { id: event1.id }
        expect(response).to render_template(:delete)
      end
    end
  end
end
