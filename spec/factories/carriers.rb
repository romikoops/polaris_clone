FactoryBot.define do
  factory :carrier do
    association :tenant_vehicles
    name 'Hapag Lloyd'
  end
end
