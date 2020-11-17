# frozen_string_literal: true

FactoryBot.define do
  factory :routing_route_line_service, class: 'Routing::RouteLineService' do
    association :route, factory: :freight_route
    association :line_service, factory: :routing_line_service
    transit_time { 2 }
  end
end

# == Schema Information
#
# Table name: routing_route_line_services
#
#  id              :uuid             not null, primary key
#  transit_time    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  line_service_id :uuid
#  route_id        :uuid
#
# Indexes
#
#  route_line_service_index  (route_id,line_service_id) UNIQUE
#
