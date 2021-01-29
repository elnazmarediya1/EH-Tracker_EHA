require 'factory_bot_rails'

module Features
  module SessionHelpers
    def login_superadmin
      before do
        visit new_user_session_path
        @admin = FactoryBot.create(:user, admin: true, superadmin: true)
        sign_in @admin
        visit welcome_index_path
      end
    end

    def login_admin
      before do
        visit new_user_session_path
        @admin = FactoryBot.create(:user, admin: true, superadmin: false)
        sign_in @admin
        visit welcome_index_path
      end
    end

    def login_user
      before do
        visit new_user_session_path
        @user = FactoryBot.create(:user, admin: false, superadmin: false)
        sign_in @user
      end
    end

    def insert_dummy_user
      before do
        visit new_user_session_path
        @user = FactoryBot.create(:user, admin: false, superadmin: false)
        sign_in @user
        sign_out @user
      end
    end

    def create_event_type
      before do
        visit new_event_type_path
        fill_in 'Name', with: 'Test Event Type'
        fill_in 'Points', with: 3.0
        click_button 'Create'
      end
    end

    def create_event
      before do
        visit new_event_path
        fill_in 'Name', with: 'New Event Integration Test'
        fill_in 'Date', with: '01/01/2021'
        fill_in 'Location', with: 'Location Test'
        fill_in 'Description', with: 'Description of Event Test'
        fill_in 'Max capacity', with: 5
        # Left default event_type
        click_button('Create')
      end
    end

    def register_for_event
      before do
        @event_type1 = create(:event_type)
        @event1 = FactoryBot.create(:event, event_type_id: @event_type1.id)
        visit new_user_event_path(@event1.id)
        click_button('Register')
      end
    end

    def register_for_volunteer_event
      before do
        @event_type2 = create(:event_type, name: 'Test Volunteer Event Type ')
        @event2 = FactoryBot.create(:event, event_type_id: @event_type2.id)
        visit new_user_event_path(@event2.id)
        fill_in 'Volunteer hours', with: 2.0
        click_button('Register')
      end
    end

    def register_for_inactive_event
      before do
        @event_type3 = create(:event_type)
        @inactive_event = FactoryBot.create(:event, event_type_id: @event_type3.id, name: 'Test Event')
        visit new_user_event_path(@inactive_event.id)
        click_button('Register')
        @inactive_event.update(active: false)
      end
    end
  end
end
