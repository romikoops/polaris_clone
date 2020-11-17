RSpec.configure do |config|
  config.around(:each, allow_forgery_protection: true) do |example|
    original_forgery_protection = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    begin
      example.run
    ensure
      ActionController::Base.allow_forgery_protection = original_forgery_protection
    end
  end
end
