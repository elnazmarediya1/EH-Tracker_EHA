require_relative './controller_macros' # or require_relative './controller_macros' if write in `spec/support/devise.rb`
require_relative './session_helpers'
RSpec.configure do |config|
  # For Devise > 4.1.1
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :feature
  # Use the following instead if you are on Devise <= 4.1.1
  # config.include Devise::TestHelpers, :type => :controller
  config.extend ControllerMacros, type: :controller
  config.extend Features::SessionHelpers, type: :feature
end
