require 'rails_helper'
require_relative '../support/devise'
require 'support/factory_bot'

def login_test_user
  visit new_user_session_path
  @user = FactoryBot.create(:user, admin: false, email: 'user@test.test')
  sign_in @user
end

def create_active_events
  visit new_user_session_path
  @admin = FactoryBot.create(:user, admin: true, email: 'admin@test.test')
  sign_in @admin

  (0..9).each do |_i|
    visit new_event_path
    FactoryBot.create(:event)
  end
end

def create_inactive_events
  visit new_user_session_path
  @admin = FactoryBot.create(:user, admin: true, email: 'admin@test.test')
  sign_in @admin

  (0..11).each do |_i|
    visit new_event_path
    FactoryBot.create(:event, active: false)
  end
end

describe 'Events integration test', type: :feature, js: true do
  context 'when logged in as admin with correct navigation' do
    login_admin
    create_event_type
    create_event

    it 'creates an event' do
      expect(page).to have_content('Event created successfully.')
      expect(page).to have_content('New Event Integration Test')
    end

    it 'navigates the events pages on active events' do
      create_active_events
      visit events_path
      expect(page).to have_content('Next')
      expect(page).to have_content('Test Event')

      click_link('Next')
      expect(page).to have_content('Previous')
      expect(page).to have_content('Test Event')

      expect(page).to have_link('', href: events_path(page: 0))
      expect(page).to have_link('', href: events_path(page: 1))

      click_link('2')
      expect(page).to have_current_path(events_path(page: 1))

      click_link('2')
      expect(page).to have_no_content('Next')
      click_link('1')
      expect(page).to have_no_content('Previous')
    end

    it 'navigates the events pages on inactive evets' do
      create_inactive_events

      visit events_past_path
      expect(page).to have_content('Next')
      expect(page).to have_content('Test Event')

      click_link('Next')
      expect(page).to have_content('Previous')
      expect(page).to have_content('Test Event')

      expect(page).to have_link('', href: events_past_path(page: 0))
      expect(page).to have_link('', href: events_past_path(page: 1))

      click_link('2')
      expect(page).to have_current_path(events_past_path(page: 1))

      click_link('2')
      expect(page).to have_no_content('Next')
      click_link('1')
      expect(page).to have_no_content('Previous')
    end

    it 'selects event on events/index and edits event name' do
      card = page.find(:xpath, '//body/div/div/div', text: 'New Event Integration Test')
      card.click_link('Edit')

      expect(page).to have_content('Edit Event')
      fill_in 'Name', with: 'Updated Event Type Integration Test'
      click_button('Update')

      expect(page).to have_content('Updated Event Type Integration Test')
    end

    it 'selects event on events/index and decreases event max capacity' do
      card = page.find(:xpath, '//body/div/div/div', text: 'New Event Integration Test')
      card.click_link('Edit')

      expect(page).to have_content('Edit Event')
      fill_in 'Max capacity', with: 0
      click_button('Update')

      expect(page).to have_content('Event failed to update. Max capacity cannot be decreased.')
    end

    it 'selects event on events/index and deletes event' do
      card = page.find(:xpath, '//body/div/div/div', text: 'New Event Integration Test')
      card.click_link('Delete')

      expect(page).to have_content('Confirm Delete')
      click_button('Delete')

      expect(page).to have_content('Event deleted successfully.')
    end

    it 'selects event on events/index and de-activates it' do
      card = page.find(:xpath, '//body/div/div/div', text: 'New Event Integration Test')
      card.click_link('Edit')

      expect(page).to have_content('Edit Event')
      card = page.find('label', text: 'Active')
      card.set(false)
      click_button('Update')

      expect(page).to have_content('Event updated successfully.')
    end

    it 'views detail in inactive events' do
      card = page.find(:xpath, '//body/div/div/div', text: 'New Event Integration Test')
      card.click_link('Edit')

      expect(page).to have_content('Edit Event')
      card = page.find('label', text: 'Active')
      card.set(false)
      click_button('Update')
      visit events_past_path

      card = page.find(:xpath, '//body/div/div/div', text: 'New Event Integration Test')
      card.click_link('Details')

      expect(page).to have_content('Event Details')
    end

    it 'deletes event in inactive events' do
      card = page.find(:xpath, '//body/div/div/div', text: 'New Event Integration Test')
      card.click_link('Edit')

      expect(page).to have_content('Edit Event')
      card = page.find('label', text: 'Active')
      card.set(false)
      click_button('Update')
      visit events_past_path

      card = page.find(:xpath, '//body/div/div/div', text: 'New Event Integration Test')
      card.click_link('Delete')
      expect(page).to have_content('Delete')
      click_button('Delete')
    end

    it 'deducts the registered users\' points and hours after deleting the event' do
      sign_out @admin
      login_test_user
      visit events_path

      card = page.find(:xpath, '//body/div/div/div', text: 'New Event Integration Test')
      card.click_link('Register')
      expect(page).to have_content('New Event Integration Test')
      expect(page).to have_button('Register')
      click_button('Register')

      expect(page).to have_content('You have registered successfully.')
      expect(page).to have_content('New Event Integration Test')
      expect(page).to have_content('Points: 3')
      expect(page).to have_content('Volunteer Hours: 0')

      sign_out @user

      sign_in @admin
      visit events_path
      card = page.find(:xpath, '//body/div/div/div', text: 'New Event Integration Test')
      card.click_link('Delete')
      expect(page).to have_content('Confirm Delete')
      click_button('Delete')
      expect(page).to have_content('Event deleted successfully.')
      sign_out @admin

      sign_in @user
      visit welcome_index_path
      click_link('My Upcoming Events')
      expect(page).to have_content('Points: 0')
      expect(page).to have_content('Volunteer Hours: 0')
    end
  end

  context 'when logged in admin with incorrect event creation' do
    login_admin
    create_event_type
    it 'incorrect data type for event points' do
      visit new_event_path
      fill_in 'Name', with: 'New Event Integration Test'
      fill_in 'Date', with: '01/01/2021'
      fill_in 'Location', with: 'Location Test'
      fill_in 'Description', with: 'Description of Event Test'
      fill_in 'Max capacity', with: 5
      # Left default event_type
      click_button('Create')

      expect(page).to have_content('Create Event')
    end

    it 'incorrect data type for volunteer hours' do
      visit new_event_path
      expect(page).to have_content('Create Event')
      fill_in 'Name', with: 'New Event Integration Test'
      fill_in 'Date', with: '01/01/2021'
      fill_in 'Location', with: 'Location Test'
      fill_in 'Description', with: 'Description of Event Test'
      fill_in 'Max capacity', with: 5
      # Left default event_type
      click_button('Create')

      expect(page).to have_content('Create Event')
    end
  end

  context 'when logged in as user with correct navigation' do
    login_user
    it 'views events page' do
      visit events_path
      expect(page).to have_content('Upcoming Events')
    end
  end
end
