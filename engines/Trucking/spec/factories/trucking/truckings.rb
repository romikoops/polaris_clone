FactoryBot.define do
  factory :trucking_trucking, class: 'Trucking' do
    association :hub
    association :trucking_rate
    association :trucking_location
  end
end
