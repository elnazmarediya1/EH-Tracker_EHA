require 'rails_helper'
require 'spec_helper'
require 'support/factory_bot'
require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :truncation

RSpec.describe UserEvent, type: :model do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start

    @event_type1 = create(:event_type)
    @event1 = create(:event)

    @user1 = create(:user)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe 'A user event sign' do
    context 'with valid input' do
      it 'is valid' do
        user_event = build(:user_event, event_id: @event1.id, user_id: @user1.id, volunteer_hours: 1.5)
        expect(user_event).to be_valid
      end
    end

    context 'with missing event id' do
      it 'is invalid' do
        user_event = build(:user_event, user_id: @user1.id, volunteer_hours: 1.5)
        expect(user_event).not_to be_valid
      end
    end

    context 'with missing user id' do
      it 'is invalid' do
        user_event = build(:user_event, event_id: @event1.id, volunteer_hours: 1.5)
        expect(user_event).not_to be_valid
      end
    end

    context 'with missing volunteer hours' do
      it 'is invalid' do
        user_event = build(:user_event, event_id: @event1.id, user_id: @user1.id)
        expect(user_event).to be_valid
      end
    end
  end
end
