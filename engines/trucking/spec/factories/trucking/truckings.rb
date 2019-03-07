FactoryBot.define do
  factory :trucking_trucking, class: 'Trucking::Trucking' do
    association :hub, factory: :legacy_hub
    association :rate, factory: :trucking_rate
    association :location, factory: :trucking_location
  end
end
