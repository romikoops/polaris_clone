# frozen_string_literal: true

module Routing
  class Route < ApplicationRecord
    include Bitfields

    belongs_to :origin, class_name: "Routing::Location"
    belongs_to :destination, class_name: "Routing::Location"
    belongs_to :origin_terminal, class_name: "Routing::Terminal", optional: true
    belongs_to :destination_terminal, class_name: "Routing::Terminal", optional: true
    has_many :route_line_services
    enum mode_of_transport: {ocean: 1, air: 2, rail: 3, truck: 4, carriage: 5}
    bitfield :allowed_cargo, 1 => :lcl, 2 => :fcl, 4 => :fcl_reefer
  end
end

# == Schema Information
#
# Table name: routing_routes
#
#  id                      :uuid             not null, primary key
#  allowed_cargo           :integer          default(0), not null
#  mode_of_transport       :integer          default(NULL), not null
#  price_factor            :decimal(, )
#  time_factor             :decimal(, )
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  destination_id          :uuid
#  destination_terminal_id :uuid
#  origin_id               :uuid
#  origin_terminal_id      :uuid
#
# Indexes
#
#  routing_routes_index  (origin_id,destination_id,origin_terminal_id,destination_terminal_id,mode_of_transport) UNIQUE
#
