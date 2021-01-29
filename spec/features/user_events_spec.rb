require 'rails_helper'
require_relative '../support/devise'
require 'support/factory_bot'

def cancel_registration_for_event
  visit user_events_path
  click_link('Cancel Registration')
  click_button('Cancel Registration')
end

def admin_cancel_registration_for_event
  click_link('Cancel Registration')
  click_button('Cancel Registration')
end

def login_admin
  visit new_user_session_path
  @admin = FactoryBot.create(:user, admin: true)
  sign_in @admin
  visit welcome_index_path
end

describe 'User events integration test', type: :feature, js: true do
  login_user
  context 'when registering for an event' do
    it 'allows users to view their current participation' do
      visit user_events_path
      expect(page).to have_content('My Statistics')
      expect(page).to have_content('Points: 0.0')
      expect(page).to have_content('Volunteer Hours: 0.0')
    end

    it 'allows admin to view the user\'s current participation' do
      sign_out @user
      login_admin
      click_link 'Manage Users'
      expect(page).to have_content('View Upcoming')
      click_link('View Upcoming', match: :first)
      expect(page).to have_content('Viewing test test\'s Participation')
      expect(page).to have_content('Points: 0.0')
      expect(page).to have_content('Volunteer Hours: 0.0')
    end
  end

  context 'when user registers for an event' do
    register_for_event

    it 'sends an event confirmation email to the user' do
      open_email(@user.email)
      expect(current_email.subject).to eq 'Confirm Event Registration'
      expect(current_email).to have_content "Hello, #{@user.first_name}!"
      expect(current_email).to have_content "Thank you for signing up to attend #{@event1.name}."
      expect(current_email).to have_content 'Below, you may find some information regarding the event you signed up for.'
      expect(current_email).to have_content "Event Name: #{@event1.name}."
      expect(current_email).to have_content "Event Date: #{@event1.date.strftime('%m/%d/%Y%l:%M %p')}."
      expect(current_email).to have_content "Event Location: #{@event1.location}."
      expect(current_email).to have_content "Event Description: #{@event1.description}."
      expect(current_email).to have_content "Event Type: #{@event1.event_type.name}."
    end

    it 'lets the user view their updated participation' do
      expect(page).to have_content('You have registered successfully.')
      expect(page).to have_content('My Statistics')
      expect(page).to have_content('Points: 1.0')
      expect(page).to have_content('Volunteer Hours: 0.0')
    end

    it 'lets the admin view their updated participation' do
      sign_out @user
      login_admin
      click_link 'Manage Users'
      expect(page).to have_content('View Upcoming')
      click_link('View Upcoming', match: :first)
      expect(page).to have_content('Viewing test test\'s Participation')
      expect(page).to have_content('Points: 1.0')
      expect(page).to have_content('Volunteer Hours: 0.0')
      expect(page).to have_link('Cancel Registration')
    end

    it 'lets the user view the new event\'s details' do
      card = page.find(:xpath, '//body', text: 'Test Event', wait: 50)
      card.click_link('Details')
      expect(page).to have_content('Event Details')
    end

    it 'no longer has the option to register' do
      visit user_events_path
      expect(page).not_to have_link('Register')
    end

    it 'now has the option to cancel registration' do
      visit user_events_path
      expect(page).to have_link('Cancel Registration')
    end

    it 'increments total number of registered users' do
      card = page.find(:xpath, '//body', text: 'Test Event', wait: 50)
      card.click_link('Details')
      expect(page).to have_content('Total Registered 1')
    end

    it 'lets the admin cancel registration for the user\'s event' do
      sign_out @user
      login_admin
      click_link 'Manage Users'
      expect(page).to have_content('View Upcoming')
      click_link('View Upcoming', match: :first)
      expect(page).to have_content('Viewing test test\'s Participation')
      expect(page).to have_content('Points: 1.0')
      expect(page).to have_content('Volunteer Hours: 0.0')
      expect(page).to have_link('Cancel Registration')
      admin_cancel_registration_for_event
      expect(page).to have_content('You have successfully cancelled registration for this event.')
      expect(page).to have_content('Viewing test test\'s Participation')
      expect(page).to have_content('Points: 0.0')
      expect(page).to have_content('Volunteer Hours: 0.0')
    end
  end

  context 'when user registers for a new event' do
    login_user

    (0..11).each do |_i|
      register_for_event
      register_for_inactive_event
    end

    it 'lets the user navigate their other events' do
      visit user_events_path

      expect(page).to have_content('Next')
      expect(page).to have_content('Test Event')

      click_link('Next')
      expect(page).to have_content('Previous')
      expect(page).to have_content('Test Event')

      expect(page).to have_link('', href: user_events_path(page: 0))
      expect(page).to have_link('', href: user_events_path(page: 1))

      click_link('2')
      expect(page).to have_current_path(user_events_path(page: 1))

      click_link('2')

      expect(page).to have_no_content('Next')
      click_link('1')
      expect(page).to have_no_content('Previous')
    end

    it 'lets the user navigate their past events' do
      visit user_events_past_path

      expect(page).to have_content('Next')

      expect(page).to have_content('Test Event')

      click_link('Next')
      expect(page).to have_content('Previous')
      expect(page).to have_content('Test Event')

      expect(page).to have_link('', href: user_events_past_path(page: 0))
      expect(page).to have_link('', href: user_events_past_path(page: 1))

      click_link('2')
      expect(page).to have_current_path(user_events_past_path(page: 1))

      click_link('2')
      expect(page).to have_no_content('Next')
      click_link('1')
      expect(page).to have_no_content('Previous')
    end
  end

  context 'when user registers for a volunteering event' do
    register_for_volunteer_event
    it 'lets users view their updated participation' do
      expect(page).to have_content('You have registered successfully.')
      expect(page).to have_content('My Statistics')
      expect(page).to have_content('Points: 3.0')
      expect(page).to have_content('Volunteer Hours: 2.0')
    end

    it 'lets admins view their updated participation' do
      sign_out @user
      login_admin
      click_link 'Manage Users'
      expect(page).to have_content('View Upcoming')
      click_link('View Upcoming', match: :first)
      expect(page).to have_content('Viewing test test\'s Participation')
      expect(page).to have_content('Points: 3.0')
      expect(page).to have_content('Volunteer Hours: 2.0')
      expect(page).to have_link('Cancel Registration')
    end

    it 'lets users view the new event\'s details' do
      card = page.find(:xpath, '//body', text: 'Test Volunteer Event')
      card.click_link('Details')
      expect(page).to have_content('Event Details')
    end

    it 'no longer has the option to register' do
      visit user_events_path
      expect(page).not_to have_link('Register')
    end

    it 'now has the option to cancel registration' do
      visit user_events_path
      expect(page).to have_link('Cancel Registration')
    end

    it 'lets the admin cancel registration for the user\'s event' do
      sign_out @user
      login_admin
      click_link 'Manage Users'
      expect(page).to have_content('View Upcoming')
      click_link('View Upcoming', match: :first)
      expect(page).to have_content('Viewing test test\'s Participation')
      expect(page).to have_content('Points: 3.0')
      expect(page).to have_content('Volunteer Hours: 2.0')
      expect(page).to have_link('Cancel Registration')
      admin_cancel_registration_for_event
      expect(page).to have_content('You have successfully cancelled registration for this event.')
      expect(page).to have_content('Viewing test test\'s Participation')
      expect(page).to have_content('Points: 0.0')
      expect(page).to have_content('Volunteer Hours: 0.0')
    end
  end

  context 'when user cancels registration for an event' do
    register_for_event
    it 'lets the user view their updated participation with accurate points and volunteer hours' do
      cancel_registration_for_event
      expect(page).to have_content('You have successfully cancelled registration for this event.')
      expect(page).to have_content('My Statistics')
      expect(page).to have_content('Points: 0.0')
      expect(page).to have_content('Volunteer Hours: 0.0')
    end

    it 'lets admins view their updated participation with accurate points and volunteer hours' do
      cancel_registration_for_event
      sign_out @user
      login_admin
      click_link 'Manage Users'
      expect(page).to have_content('View Upcoming')
      click_link('View Upcoming', match: :first)
      expect(page).to have_content('Viewing test test\'s Participation')
      expect(page).to have_content('Points: 0.0')
      expect(page).to have_content('Volunteer Hours: 0.0')
    end

    it 'no longer has the option to cancel registration' do
      cancel_registration_for_event
      visit events_path
      expect(page).not_to have_link('Cancel Registration')
    end

    it 'now has the option to register' do
      cancel_registration_for_event
      visit events_path
      expect(page).to have_link('Register')
    end
  end

  context 'when user cancels registration for a volunteering event' do
    register_for_volunteer_event
    it 'lets the user view their updated participation with accurate points and volunteer hours' do
      cancel_registration_for_event
      expect(page).to have_content('You have successfully cancelled registration for this event.')
      expect(page).to have_content('My Statistics')
      expect(page).to have_content('Points: 0.0')
      expect(page).to have_content('Volunteer Hours: 0.0')
    end

    it 'lets admins view their updated participation with accurate points and volunteer hours' do
      cancel_registration_for_event
      sign_out @user
      login_admin
      click_link 'Manage Users'
      expect(page).to have_content('View Upcoming')
      click_link('View Upcoming', match: :first)
      expect(page).to have_content('Viewing test test\'s Participation')
      expect(page).to have_content('Points: 0.0')
      expect(page).to have_content('Volunteer Hours: 0.0')
    end

    it 'no longer has the option to cancel registration' do
      cancel_registration_for_event
      visit events_path
      expect(page).not_to have_link('Cancel Registration')
    end

    it 'now has the option to register' do
      cancel_registration_for_event
      visit events_path
      expect(page).to have_link('Register')
    end

    it 'increments total number of registered users' do
      card = page.find(:xpath, '//body', text: 'Test Volunteer Event', wait: 50)
      card.click_link('Details')
      expect(page).to have_content('Total Registered 1')
    end
  end

  context 'when registering for event that is at max capacity' do
    it 'redirects the user to the events page' do
      @event_type1 = create(:event_type)
      @event1 = create(:event, event_type_id: @event_type1.id, max_capacity: 0)
      visit new_user_event_path(@event1.id)
      click_button('Register')

      expect(page).to have_current_path(events_path)
      expect(page).to have_content('This event has already reached a maximum capacity.')
    end
  end

  context 'when registering for event that is not at max capacity' do
    it 'signs the user up and increments the total registered' do
      @event_type1 = create(:event_type)
      @event1 = create(:event, event_type_id: @event_type1.id, max_capacity: 2)
      visit new_user_event_path(@event1.id)
      click_button('Register')

      expect(page).to have_current_path(user_events_path)
      expect(page).to have_content('You have registered successfully.')
      expect(page).to have_content('Total Registered: 1 / 2')
    end
  end
end
