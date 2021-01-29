require 'rails_helper'
require_relative '../support/devise'
require 'support/factory_bot'

RSpec.describe EventTypesController, type: :controller do
  describe 'GET index' do
    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :index
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders event_types/index page ' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not allow access to event_types/index page' do
        get :index
        expect(response).to redirect_to(controller: 'welcome', action: 'index')
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
      it 'renders event_types/new page ' do
        get :new
        expect(response).to render_template(:new)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not allow access to event_types/new page' do
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
      it 'does not allow access to event_types/create page' do
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
      it 'creates the event type and redirect the admin to the event types view' do
        post :create, params: { event_type: { name: 'test_event_type', points: 1 } }
        expect(response).to redirect_to(event_types_path)
      end
    end

    context 'with invalid data' do
      login_admin
      it 'renders the new view' do
        post :create, params: { event_type: { name: nil, points: nil } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET edit' do
    before(:context) do
      @event_type1 = create(:event_type)
    end

    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :edit, params: { id: @event_type1.id }
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders event_types/edit page ' do
        get :edit, params: { id: @event_type1.id }
        expect(response).to render_template(:edit)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not allow access to event_types/edit page' do
        get :edit, params: { id: @event_type1.id }
        expect(response).to redirect_to(controller: 'welcome', action: 'index')
      end
    end
  end

  describe 'PATCH update' do
    before(:context) do
      @event_type1 = create(:event_type)
    end

    context 'with valid data' do
      login_admin
      it 'updates the event type details and redirect the admin to the event types view' do
        patch :update, params: { id: @event_type1.id, event_type: { name: 'test_event_type', points: 1 } }
        expect(response).to redirect_to(event_types_path)
      end
    end

    context 'with invalid data' do
      login_admin
      it 'renders the edit view' do
        patch :update, params: { id: @event_type1.id, event_type: { name: nil, points: nil } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'GET show' do
    before(:context) do
      @event_type1 = create(:event_type)
    end

    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :show, params: { id: @event_type1.id }
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders event_types/edit page ' do
        get :show, params: { id: @event_type1.id }
        expect(response).to render_template(:show)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not allow access to event_types/edit page' do
        get :show, params: { id: @event_type1.id }
        expect(response).to redirect_to(controller: 'welcome', action: 'index')
      end
    end
  end

  describe 'GET delete' do
    before(:context) do
      @event_type1 = create(:event_type)
    end

    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :delete, params: { id: @event_type1.id }
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders event_types/delete page ' do
        get :delete, params: { id: @event_type1.id }
        expect(response).to render_template(:delete)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not allow access to event_types/delete page' do
        get :delete, params: { id: @event_type1.id }
        expect(response).to redirect_to(controller: 'welcome', action: 'index')
      end
    end
  end

  describe 'DELETE destroy' do
    context 'with valid data' do
      login_admin

      let(:event_type1) { create(:event_type) }

      before do
        allow(event_type1).to receive(:destroy).and_return(true)
        allow(EventType).to receive(:find).and_return(event_type1)
      end

      it 'renders the event types view' do
        delete :destroy, params: { id: event_type1.id }
        expect(response).to redirect_to(event_types_path)
      end
    end

    context 'with invalid data' do
      login_admin

      let(:event_type1) { create(:event_type) }

      before do
        allow(event_type1).to receive(:destroy).and_return(false)
        allow(EventType).to receive(:find).and_return(event_type1)
      end

      it 'renders the delete view' do
        delete :destroy, params: { id: event_type1.id }
        expect(response).to render_template(:delete)
      end
    end
  end
end
