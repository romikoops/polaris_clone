require "rails_helper"

module Routing
  RSpec.describe Carrier, type: :model do
    it "creates a valid object" do
      carrier = FactoryBot.build(:routing_carrier)
      expect(carrier).to be_valid
    end
  end
end

# == Schema Information
#
# Table name: routing_carriers
#
#  id               :uuid             not null, primary key
#  abbreviated_name :string
#  code             :string
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  routing_carriers_index  (name,code,abbreviated_name) UNIQUE
#
