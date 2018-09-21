# Load Rails Environment
require "#{File.dirname(__FILE__)}/config/environment"

# Do stuff
p = DataValidator::PricingValidator.new(_user: User.find(1), tenant: 1)
p.perform