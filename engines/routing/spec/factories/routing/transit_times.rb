# frozen_string_literal: true

FactoryBot.define do
  factory :routing_transit_time, class: 'Routing::TransitTime' do
    association :route_line_service, factory: :routing_route_line_service
    days { 2 }
  end
end
