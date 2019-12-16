# frozen_string_literal: true

FactoryBot.define do
  factory :routing_route_line_service, class: 'Routing::RouteLineService' do
    association :route, factory: :freight_route
    association :line_service, factory: :routing_line_service
    transit_time { 2 }
  end
end
