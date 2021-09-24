# frozen_string_literal: true

require "rails_helper"

module Journey
  RSpec.describe ShipmentRequest, type: :model do
    it "creates a valid object" do
      expect(FactoryBot.create(:journey_shipment_request)).to be_valid
    end
  end
end
