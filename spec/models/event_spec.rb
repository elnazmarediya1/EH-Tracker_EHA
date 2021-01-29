require 'spec_helper'
require 'support/factory_bot'
require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :truncation

RSpec.describe Event, type: :model do
  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    @event_type1 = create(:event_type)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  describe 'An Event ' do
    context 'with valid input' do
      it 'is valid' do
        event = build(:event, event_type_id: @event_type1.id)
        expect(event).to be_valid
      end
    end

    context 'with empty name' do
      it 'is invalid' do
        event = build(:event, event_type_id: @event_type1.id, name: nil)
        expect(event).not_to  be_valid
      end
    end

    context 'with empty date' do
      it 'is invalid' do
        event = build(:event, event_type_id: @event_type1.id, date: nil)
        expect(event).not_to  be_valid
      end
    end

    context 'with empty location' do
      it 'is invalid' do
        event = build(:event, event_type_id: @event_type1.id, location: nil)
        expect(event).not_to  be_valid
      end
    end

    context 'with empty event type id' do
      it 'is invalid' do
        event = build(:event, event_type_id: nil)
        expect(event).not_to  be_valid
      end
    end

    context 'with empty uin' do
      it 'is invalid' do
        event = build(:event, event_type_id: @event_type1.id, created_by_uin: nil)
        expect(event).not_to  be_valid
      end
    end
  end
end
