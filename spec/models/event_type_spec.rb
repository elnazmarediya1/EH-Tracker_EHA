require 'rails_helper'
require 'support/factory_bot'

RSpec.describe EventType, type: :model do
  describe 'An event type' do
    context 'with valid input' do
      it 'is valid' do
        event_type1 = build(:event_type)
        expect(event_type1).to be_valid
      end
    end

    context 'with empty name' do
      it 'is invalid' do
        event_type2 = build(:event_type, name: '')
        expect(event_type2).not_to be_valid
      end
    end

    context 'with empty points' do
      it 'is invalid' do
        event_type2 = build(:event_type, points: '')
        expect(event_type2).not_to be_valid
      end
    end

    context 'with negative points' do
      it 'is invalid' do
        event_type2 = build(:event_type, points: -2.0)
        expect(event_type2).not_to be_valid
      end
    end
  end
end
