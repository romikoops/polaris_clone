FactoryBot.define do
  factory :routing_terminal, class: 'Routing::Terminal' do
    association :location, factory: :routing_location
    center { FactoryBot.build(:point, lat: 53.558572, lng: 9.9278215) }
    terminal_code { 'DEHAMPS' }
    default { false }
  end
end
