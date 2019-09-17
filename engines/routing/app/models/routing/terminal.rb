module Routing
  class Terminal < ApplicationRecord
    belongs_to :location
    enum mode_of_transport: { ocean: 1, air: 2, rail: 3, truck: 4, carriage: 5 }
    validates_uniqueness_of :location_id, scope: %i(mode_of_transport terminal_code)
  end
end

# == Schema Information
#
# Table name: routing_terminals
#
#  id                :uuid             not null, primary key
#  location_id       :uuid
#  center            :geometry({:srid= geometry, 0
#  terminal_code     :string
#  default           :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  mode_of_transport :integer          default(NULL)
#
