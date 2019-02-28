FactoryBot.define do
  factory :trucking_hub_availability, class: 'Trucking::HubAvailability' do
    association :hub, factory: :legacy_hub
    association :type_availability, factory: :trucking_type_availability
  end
end
