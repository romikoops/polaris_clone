require "rails_helper"

module Routing
  RSpec.describe Terminal, type: :model do
    it "creates a valid object" do
      hamburg = FactoryBot.build(:routing_terminal)
      expect(hamburg.terminal_code).to eq("DEHAMPS")
    end
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
