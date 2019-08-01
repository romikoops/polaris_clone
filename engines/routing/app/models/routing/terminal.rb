module Routing
  class Terminal < ApplicationRecord
    belongs_to :location
  end
end

# == Schema Information
#
# Table name: routing_terminals
#
#  id            :uuid             not null, primary key
#  location_id   :uuid
#  center        :geometry({:srid= geometry, 0
#  terminal_code :string
#  default       :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
