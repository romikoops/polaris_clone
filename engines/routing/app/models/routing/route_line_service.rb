module Routing
  class RouteLineService < ApplicationRecord
    belongs_to :route, class_name: 'Routing::Route'
    belongs_to :line_service, class_name: 'Routing::LineService'
  end
end

# == Schema Information
#
# Table name: routing_route_line_services
#
#  id              :uuid             not null, primary key
#  route_id        :uuid
#  line_service_id :uuid
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
