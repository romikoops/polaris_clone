module Routing
  class Terminal < ApplicationRecord
    belongs_to :location
    enum mode_of_transport: { ocean: 1, air: 2, rail: 3, truck: 4, carriage: 5 }
    validates_uniqueness_of :location_id, scope: %i(mode_of_transport terminal_code)
    has_many :inbound_routes, class_name: 'Routing::Route', foreign_key: :destination_terminal_id
    has_many :outbound_routes, class_name: 'Routing::Route', foreign_key: :origin_terminal_id
  end
end

# == Schema Information
#
# Table name: routing_terminals
#
#  id                :uuid             not null, primary key
#  center            :geometry         geometry, 0
#  default           :boolean          default(FALSE)
#  mode_of_transport :integer          default(NULL)
#  terminal_code     :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  location_id       :uuid
#
# Indexes
#
#  index_routing_terminals_on_center  (center)
#
