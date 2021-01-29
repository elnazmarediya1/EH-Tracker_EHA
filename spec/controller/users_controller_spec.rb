require 'rails_helper'
require_relative '../support/devise'
require 'support/factory_bot'

RSpec.describe UsersController, type: :controller do
  describe 'GET index' do
    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :index
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders users/index page ' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not allow access to users/index page' do
        get :index
        expect(response).to redirect_to(controller: 'welcome', action: 'index')
      end
    end
  end

  describe 'GET edit' do
    before(:context) do
      @user1 = create(:user)
    end

    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :edit, params: { id: @user1.id }
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders users/edit page ' do
        get :edit, params: { id: @user1.id }
        expect(response).to render_template(:edit)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not allow access to users/edit page' do
        get :edit, params: { id: @user1.id }
        expect(response).to redirect_to(controller: 'welcome', action: 'index')
      end
    end
  end

  describe 'PATCH update' do
    before(:context) do
      @user1 = create(:user)
    end

    context 'with valid data' do
      login_admin
      it 'updates the user details and redirect the admin to the user details view' do
        patch :update, params: { id: @user1.id, user: { admin: true, points: 1, volunteer_hours: 1, first_name: 'test_user_first_name', last_name: 'test_user_last_name', uin: '123456789' } }
        expect(response).to redirect_to(user_path(@user1))
      end
    end

    context 'with invalid data' do
      login_admin
      it 'renders the edit view' do
        patch :update, params: { id: @user1.id, user: { admin: nil, points: nil, volunteer_hours: nil, first_name: nil, last_name: nil, uin: nil } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'GET show' do
    before(:context) do
      @user1 = create(:user)
    end

    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :show, params: { id: @user1.id }
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders event_types/edit page ' do
        get :show, params: { id: @user1.id }
        expect(response).to render_template(:show)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not allow access to users/edit page' do
        get :show, params: { id: @user1.id }
        expect(response).to redirect_to(controller: 'welcome', action: 'index')
      end
    end
  end

  describe 'GET delete' do
    before(:context) do
      @user1 = create(:user)
    end

    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :delete, params: { id: @user1.id }
        expect(response).to redirect_to(user_session_path)
      end
    end

    context 'when admin is logged in' do
      login_admin
      it 'renders users/delete page ' do
        get :delete, params: { id: @user1.id }
        expect(response).to render_template(:delete)
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not allow access to users/delete page' do
        get :delete, params: { id: @user1.id }
        expect(response).to redirect_to(controller: 'welcome', action: 'index')
      end
    end
  end

  describe 'DELETE destroy' do
    context 'with valid data' do
      login_admin

      let(:user1) { create(:user) }

      before do
        allow(user1).to receive(:destroy).and_return(true)
        allow(User).to receive(:find).and_return(user1)
      end

      it 'renders the delete view' do
        delete :destroy, params: { id: user1.id }
        expect(response).to redirect_to(users_path)
      end
    end

    context 'with invalid data' do
      login_admin

      let(:user1) { create(:user) }

      before do
        allow(user1).to receive(:destroy).and_return(false)
        allow(User).to receive(:find).and_return(user1)
      end

      it 'renders the delete view' do
        delete :destroy, params: { id: user1.id }
        expect(response).to render_template(:delete)
      end
    end
  end

  describe 'Exporting CSV' do
    context 'when admin is logged in' do
      login_admin
      it 'downloads a CSV file' do
        get :export_csv, format: :csv
        expect(response.header['Content-Type']).to include 'text/csv'
      end
    end

    context 'when user is logged in' do
      login_user
      it 'does not download a CSV file' do
        get :export_csv, format: :csv
        expect(response.header['Content-Type']).to include 'text/html'
      end
    end
  end
end
