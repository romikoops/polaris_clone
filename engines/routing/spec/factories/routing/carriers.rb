FactoryBot.define do
  factory :routing_carrier, class: 'Routing::Carrier' do
    sequence(:name) { |n| "Carrier - #{n}"}
    sequence(:abbreviated_name) { |n| "C#{n}"}
  end
end
