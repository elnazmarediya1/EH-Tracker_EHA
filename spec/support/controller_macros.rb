require 'factory_bot_rails'

module ControllerMacros
  def login_user
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      user = FactoryBot.create(:user)
      sign_in user
    end
  end

  def login_admin
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      admin = FactoryBot.create(:user, admin: true)
      sign_in admin
    end
  end
end
