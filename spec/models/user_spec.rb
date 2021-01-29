require 'rails_helper'
require 'support/factory_bot'

RSpec.describe User, type: :model do
  describe 'A user account' do
    context 'with valid input' do
      it 'is valid' do
        user1 = build(:user)
        expect(user1).to be_valid
      end
    end

    context 'with empty first name' do
      it 'is invalid' do
        user1 = build(:user, first_name: '')
        expect(user1).not_to be_valid
      end
    end

    context 'with empty last name' do
      it 'is invalid' do
        user1 = build(:user, last_name: '')
        expect(user1).not_to be_valid
      end
    end

    context 'with empty uin' do
      it 'is invalid' do
        user1 = build(:user, uin: '')
        expect(user1).not_to be_valid
      end
    end

    context 'with non-numerical uin' do
      it 'is invalid' do
        user1 = build(:user, uin: 'abc')
        expect(user1).not_to be_valid
      end
    end

    context 'with longer than 9 digits uin' do
      it 'is invalid' do
        user1 = build(:user, uin: '1234567891')
        expect(user1).not_to be_valid
      end
    end

    context 'with less than 9 digits uin' do
      it 'is invalid' do
        user1 = build(:user, uin: '12345678')
        expect(user1).not_to be_valid
      end
    end

    context 'with empty email' do
      it 'is invalid' do
        user1 = build(:user, email: '')
        expect(user1).not_to be_valid
      end
    end

    context 'with empty password' do
      it 'is invalid' do
        user1 = build(:user, password: '')
        expect(user1).not_to be_valid
      end
    end

    context 'with empty volunteer hourse' do
      it 'is invalid' do
        user1 = build(:user, volunteer_hours: '')
        expect(user1).not_to be_valid
      end
    end

    context 'with negative volunteer hourse' do
      it 'is invalid' do
        user1 = build(:user, volunteer_hours: -2.0)
        expect(user1).not_to be_valid
      end
    end

    context 'with empty points' do
      it 'is invalid' do
        user1 = build(:user, points: '')
        expect(user1).not_to be_valid
      end
    end

    context 'with negative points' do
      it 'is invalid' do
        user1 = build(:user, points: -2.0)
        expect(user1).not_to be_valid
      end
    end
  end
end
