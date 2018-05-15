FactoryBot.define do
  factory :hub_trucking do
  	association :hub
  	association :trucking_pricing
  	association :trucking_destination
  end
end