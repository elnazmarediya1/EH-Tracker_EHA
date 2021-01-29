require 'rails_helper'
require_relative '../support/devise'
require 'support/factory_bot'

def register_new_user(uin = valid_attributes[:uin])
  visit '/'
  click_link 'Register', match: :first
  fill_in 'First name', with: valid_attributes[:first_name]
  fill_in 'Last name', with: valid_attributes[:last_name]
  fill_in 'TAMU UIN', with: uin
  fill_in 'Email', with: valid_attributes[:email]
  fill_in 'Password', with: valid_attributes[:password]
  fill_in 'Password confirmation', with: valid_attributes[:password]
  click_button 'Sign Up'
end

RSpec::Matchers.define :be_logged_in do |user_first_name|
  match do |page|
    expect(page).to have_current_path '/'
    expect(page).to have_content "Hello, #{user_first_name}!"
  end
end

describe 'User registration', type: :feature, js: true do
  let!(:user) do
    FactoryBot.create(:user)
  end

  let(:valid_attributes) do
    FactoryBot.attributes_for(:user)
  end

  context 'when creating a new account' do
    it 'registers a new user account' do
      register_new_user

      expect(page).to have_content 'A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.'
      expect(page).to have_current_path '/'
    end

    it 'rejects user registration if UIN is already taken' do
      register_new_user(123_456_789)
      expect(page).to have_content 'A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.'
      expect(page).to have_current_path '/'

      register_new_user(123_456_789)
      expect(page).to have_content 'Uin has already been taken'
      expect(page).to have_current_path '/users'
    end

    it 'sends an email confirmation to the user' do
      register_new_user

      open_email(valid_attributes[:email])
      expect(current_email.subject).to eq 'Confirmation instructions'
      expect(current_email).to have_content 'Welcome to TAMU Engineering Honors!'
      expect(current_email).to have_content 'To gain access to our site, please confirm your email by clicking below.'

      current_email.click_link 'Confirm my account'
      expect(page).to have_content 'Your email address has been successfully confirmed.'
    end
  end
end

describe 'User login', type: :feature, js: true do
  let(:user) do
    FactoryBot.create(:user)
  end

  let!(:user_unconfirmed) do
    FactoryBot.create(:user, confirmed_at: nil)
  end

  let(:valid_attributes) do
    FactoryBot.attributes_for(:user)
  end

  context 'when logging into an unconfirmed account' do
    it 'does not log the user into the system' do
      visit new_user_session_path
      fill_in 'Email', with: user_unconfirmed.email
      fill_in 'Password', with: user_unconfirmed.password
      click_button 'Login'

      expect(page).to have_content 'You have to confirm your email address before continuing.'
    end
  end

  context 'when logging into a confirmed account' do
    it 'logs the user into the system' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Login'

      expect(page).to be_logged_in(valid_attributes[:first_name])
    end
  end

  context 'when editing existing account password' do
    it 'updates the account password' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Login'

      expect(page).to be_logged_in(valid_attributes[:first_name])

      click_link 'Edit Account'
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'newpassword'
      fill_in 'Password confirmation', with: 'newpassword'
      fill_in 'Current password', with: user.password
      click_button 'Update'

      expect(page).to be_logged_in(valid_attributes[:first_name])
      click_link 'Logout', match: :first

      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'newpassword'
      click_button 'Login'

      expect(page).to be_logged_in(valid_attributes[:first_name])
    end
  end

  context 'when editing existing account email' do
    it 'edits registered email' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Login'

      expect(page).to be_logged_in(valid_attributes[:first_name])

      click_link 'Edit Account'
      fill_in 'Email', with: 'testemail@gmail.com'
      fill_in 'Current password', with: user.password
      click_button 'Update'

      expect(page).to be_logged_in(valid_attributes[:first_name])

      click_link 'Logout', match: :first

      open_email('testemail@gmail.com')
      expect(current_email.subject).to eq 'Confirmation instructions'
      current_email.click_link 'Confirm my account'

      visit new_user_session_path
      fill_in 'Email', with: 'testemail@gmail.com'
      fill_in 'Password', with: user.password
      click_button 'Login'

      expect(page).to be_logged_in(valid_attributes[:first_name])
    end
  end

  context 'when attempting to logout of the application' do
    it 'directs the user to the root path and reveal a signed out message' do
      visit new_user_session_path
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Login'

      click_link 'Logout', match: :first

      expect(page).to have_content 'Signed out successfully.'
      expect(page).to have_current_path '/'
    end
  end
end

describe 'Administrator alert upon registration', type: :feature, js: true do
  let!(:user) do
    FactoryBot.create(:user)
  end

  let(:valid_attributes) do
    FactoryBot.attributes_for(:user)
  end

  context 'when a user registers and confirms an account' do
    it 'sends an email alert to every administrator registered on the application' do
      admin = FactoryBot.create(:user, admin: true)

      register_new_user

      open_email(valid_attributes[:email])
      expect(current_email.subject).to eq 'Confirmation instructions'
      current_email.click_link 'Confirm my account'

      open_email(admin.email)
      expect(current_email.subject).to eq 'New Member Registration'
      expect(current_email).to have_content 'Hello, TAMU Engineering Honors Administrator!'
      expect(current_email).to have_content 'This message serves as an administrator alert.'
      expect(current_email).to have_content 'A member has just registered for the TAMU Engineering Honors system. Their details may be found below.'
      expect(current_email).to have_content "First Name: #{valid_attributes[:first_name]}."
      expect(current_email).to have_content "Last Name: #{valid_attributes[:last_name]}."
      expect(current_email).to have_content "UIN: #{valid_attributes[:uin]}."
      expect(current_email).to have_content "Email: #{valid_attributes[:email]}."
    end
  end
end
