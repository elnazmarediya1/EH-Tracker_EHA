require 'rails_helper'
require_relative '../support/devise'
require 'support/factory_bot'

def register_for_event(name = 'Test Event')
  visit events_path
  card = page.find(:xpath, '//body/div/div/div', text: name)
  card.click_link('Register')
  expect(page).to have_content(name)
  expect(page).to have_button('Register')
  click_button('Register')

  expect(page).to have_content('You have registered successfully.')
  expect(page).to have_content(name)
  expect(page).to have_content('Points: 3')
  expect(page).to have_content('Volunteer Hours: 0')
end

def create_event(name = 'New Event Integration Test')
  visit new_event_path
  expect(page).to have_content('Create Event')
  fill_in 'Name', with: name
  fill_in 'Date', with: '01/01/2021'
  fill_in 'Location', with: 'Location Test'
  fill_in 'Description', with: 'Description of Event Test'
  fill_in 'Max capacity', with: 5
  # Left default event_type
  click_button('Create')
end

# should only be seen by user with admin priveleges
describe 'Event types integration test', type: :feature, js: true do
  context 'when admin is logged in' do
    login_admin
    create_event_type

    it 'creates event type' do
      expect(page).to have_content('Test Event Type')
    end

    it 'edits event type' do
      tr = page.find(:xpath, '//tr', text: 'Test Event Type')
      tr.click_link('Edit')

      fill_in 'Name', with: 'Test Event Update'
      click_button('Update')
      expect(page).to have_content('Test Event Update')
    end

    it 'adjusts the registered users\' points and hours after editing the event type' do
      create_event('Test Event 1')
      create_event('Test Event 2')
      sign_out @admin

      visit new_user_session_path
      @user1 = FactoryBot.create(:user, admin: false, email: 'user1@test.test')
      sign_in @user1

      register_for_event('Test Event 1')

      sign_out @user1

      visit new_user_session_path
      @user2 = FactoryBot.create(:user, admin: false, email: 'user2@test.test')
      sign_in @user2

      register_for_event('Test Event 2')
      sign_out @user2

      sign_in @admin
      visit event_types_path
      click_link('Edit')
      fill_in 'Points', with: 5.0
      click_button('Update')
      sign_out @admin

      sign_in @user1
      visit welcome_index_path
      click_link('My Upcoming Events')
      expect(page).to have_content('Points: 5')
      expect(page).to have_content('Volunteer Hours: 0')
      sign_out @user1

      sign_in @user2
      visit welcome_index_path
      click_link('My Upcoming Events')
      expect(page).to have_content('Points: 5')
      expect(page).to have_content('Volunteer Hours: 0')
      sign_out @user2
    end

    it 'deletes event type' do
      tr = page.find(:xpath, '//tr', text: 'Test Event Type')
      tr.click_link('Delete')

      expect(page).to have_content('Confirm Delete')
      click_button('Delete')
      expect(page).to have_no_content('Test Event Type')
    end

    it 'deducts the registered users\' points and hours after deleting the event type' do
      create_event('Test Event 1')
      create_event('Test Event 2')
      sign_out @admin

      visit new_user_session_path
      @user1 = FactoryBot.create(:user, admin: false, email: 'user1@test.test')
      sign_in @user1

      register_for_event('Test Event 1')

      sign_out @user1

      visit new_user_session_path
      @user2 = FactoryBot.create(:user, admin: false, email: 'user2@test.test')
      sign_in @user2

      register_for_event('Test Event 2')
      sign_out @user2

      sign_in @admin
      visit event_types_path
      click_link('Delete')
      expect(page).to have_content('Confirm Delete')
      click_button('Delete')
      expect(page).to have_content('Event type deleted successfully.')
      sign_out @admin

      sign_in @user1
      visit welcome_index_path
      click_link('My Upcoming Events')
      expect(page).to have_content('Points: 0')
      expect(page).to have_content('Volunteer Hours: 0')
      sign_out @user1

      sign_in @user2
      visit welcome_index_path
      click_link('My Upcoming Events')
      expect(page).to have_content('Points: 0')
      expect(page).to have_content('Volunteer Hours: 0')
      sign_out @user2
    end

    it 'directs to event_types/new and goes back to event_types/index' do
      visit new_event_type_path
      expect(page).to have_content('Create Event Type')
      page.click_link('Go Back')
      expect(page).to have_content('Available Event Types')
    end

    it 'directs to event_types/id/edit and goes back to event_types/index' do
      tr = page.find(:xpath, '//tr', text: 'Test Event Type')
      tr.click_link('Edit')

      page.click_link('Go Back')
      expect(page).to have_content('Test Event Type')
    end

    it 'directs to event_types/id/delete and goes back to event_types/index' do
      tr = page.find(:xpath, '//tr', text: 'Test Event Type')
      tr.click_link('Delete')

      page.click_link('Go Back')
      expect(page).to have_content('Test Event Type')
    end
  end
end
