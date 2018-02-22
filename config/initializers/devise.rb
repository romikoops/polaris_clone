Devise.setup do |config|
	config.navigational_formats = [:json]
	config.secret_key_base = ENV["SECRET_KEY_BASE"]
end