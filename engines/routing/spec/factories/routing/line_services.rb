FactoryBot.define do
  factory :routing_line_service, class: 'Routing::LineService' do
    name { 'Far East 1' }
    association :carrier, factory: :routing_carrier
    category { 2 }
  end
end
