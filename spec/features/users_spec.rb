require 'rails_helper'
require_relative '../support/devise'
require 'support/factory_bot'

# should only be seen by user with admin priveleges
describe 'Admin-facing users integration test', type: :feature, js: true do
  login_admin
  context 'when logged in as admin' do
    it 'views user list' do
      click_link 'Manage Users'
      expect(page).to have_content('test, test')
    end

    it 'views user' do
      click_link 'Manage Users'
      click_link 'Details'

      expect(page).to have_content('Volunteer Hours') # Hours only seen in details
    end

    it 'directs to users/id/edit and goes back to users/index' do
      click_link 'Manage Users'
      click_link 'Edit'

      page.click_link('Go Back')
      expect(page).to have_content('test, test')
    end

    it 'change user points (edit user)' do
      click_link 'Manage Users'
      click_link 'Edit'

      fill_in 'user_points', with: '11'
      click_button('Update')
      expect(page).to have_content('User updated successfully.')
      expect(page).to have_content('11')
    end

    it 'change user volunteer hours (edit user)' do
      click_link 'Manage Users'
      click_link 'Edit'

      fill_in 'user_volunteer_hours', with: '6'
      click_button('Update')
      expect(page).to have_content('User updated successfully.')
      expect(page).to have_content('6')
    end

    it 'change user first name (edit user)' do
      click_link 'Manage Users'
      click_link 'Edit'

      fill_in 'user_first_name', with: 'Ashtaga'
      click_button('Update')
      expect(page).to have_content('User updated successfully.')
      expect(page).to have_content('Ashtaga')
    end

    it 'change user last name (edit user)' do
      click_link 'Manage Users'
      click_link 'Edit'

      fill_in 'user_last_name', with: 'Budihardjo'
      click_button('Update')
      expect(page).to have_content('User updated successfully.')
      expect(page).to have_content('Budihardjo')
    end

    it 'change user UIN (edit user)' do
      click_link 'Manage Users'
      click_link 'Edit'

      fill_in 'user_uin', with: '321654987'
      click_button('Update')
      expect(page).to have_content('User updated successfully.')
      expect(page).to have_content('321654987')
    end

    it 'sorts users by hours using hours link' do
      click_link 'Manage Users'
      link = page.find('p', text: 'Sort By')
      link.click_link 'Hours'
      expect(page).to have_current_path('/users?direction=asc&sort=volunteer_hours')
      link.click_link 'Hours'
      expect(page).to have_current_path('/users?direction=desc&sort=volunteer_hours')
    end

    it 'sorts users by points using points link' do
      click_link 'Manage Users'
      link = page.find('p', text: 'Sort By')
      link.click_link 'Points'
      expect(page).to have_current_path('/users?direction=desc&sort=points')
      link.click_link 'Points'
      expect(page).to have_current_path('/users?direction=asc&sort=points')
    end

    it 'sorts users by hours using navigation tab' do
      click_link 'Manage Users'
      link = page.find('table', text: 'Hours')
      link.click_link 'Hours'
      expect(page).to have_current_path('/users?direction=asc&sort=volunteer_hours')
      link.click_link 'Hours'
      expect(page).to have_current_path('/users?direction=desc&sort=volunteer_hours')
    end

    it 'sorts users by points navigation tab' do
      click_link 'Manage Users'
      link = page.find('table', text: 'Points')
      link.click_link 'Points'
      expect(page).to have_current_path('/users?direction=desc&sort=points')
      link.click_link 'Points'
      expect(page).to have_current_path('/users?direction=asc&sort=points')
    end
  end
end

describe 'Superadmin-facing users integration test, as a superadmin', type: :feature, js: true do
  insert_dummy_user
  login_superadmin
  context 'when logged in as superadmin' do
    it 'promote a user to admin (edit user)' do
      click_link 'Manage Users'
      click_link('Edit', match: :first)

      check 'user_admin'
      click_button('Update')
      expect(page).to have_content('Admin')
    end

    it 'deletes user (itself), forcing him to log out' do
      click_link 'Manage Users'
      click_link 'Delete'

      expect(page).to have_content('Confirm Delete')
      click_button('Delete')
      expect(page).to have_content('User deleted successfully.')
    end
  end
end
