# frozen_string_literal: true
require "rails_helper"

module Routing
  RSpec.describe Location, type: :model do
    it "creates a valid object" do
      hamburg = FactoryBot.build(:routing_location, locode: "DEHAM")
      expect(hamburg.locode).to eq("DEHAM")
    end
  end
end

# == Schema Information
#
# Table name: routing_locations
#
#  id           :uuid             not null, primary key
#  bounds       :geometry         geometry, 0
#  center       :geometry         geometry, 0
#  country_code :string
#  locode       :string
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_routing_locations_on_bounds  (bounds) USING gist
#  index_routing_locations_on_center  (center)
#  index_routing_locations_on_locode  (locode)
#
