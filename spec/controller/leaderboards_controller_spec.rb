require 'rails_helper'
require_relative '../support/devise'
require 'support/factory_bot'

RSpec.describe LeaderboardsController, type: :controller do
  describe 'GET index' do
    context 'when user is not logged in' do
      it 'redirects to the log in page' do
        get :index
        expect(response).to redirect_to(user_session_path)
      end
    end

    # admins have Manage Users instead of Leaderboard
    context 'when admin is logged in' do
      login_admin
      it 'redirects to users/index page' do
        get :index
        expect(response).to redirect_to(controller: 'users', action: 'index')
      end
    end

    context 'when user is logged in' do
      login_user
      it 'renders leaderboards/index page ' do
        get :index
        expect(response).to render_template(:index)
      end
    end
  end
end
