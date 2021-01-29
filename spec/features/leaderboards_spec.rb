require 'rails_helper'
require_relative '../support/devise'
require 'support/factory_bot'

# should only be seen by user without admin priveleges
describe 'Leaderboards integration test', type: :feature, js: true do
  context 'when user is logged in' do
    login_user

    it 'views Leaderboards' do
      visit welcome_index_path
      expect(page).to have_content('Leaderboard')
      click_on('Leaderboard')
      expect(page).to have_content('test, test')
      expect(page).to have_content('Current rank:')
    end
  end
end
