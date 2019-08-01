module Routing
  class TransitTime < ApplicationRecord
    belongs_to :route_line_service, class_name: 'Routing::RouteLineService'
    # belongs_to :line_service, through: :route_line_service
  end
end

# == Schema Information
#
# Table name: routing_transit_times
#
#  id                    :uuid             not null, primary key
#  route_line_service_id :uuid
#  days                  :decimal(, )
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
