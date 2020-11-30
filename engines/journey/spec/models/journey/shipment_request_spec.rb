require "rails_helper"

module Journey
  RSpec.describe ShipmentRequest, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_shipment_request)).to be_valid
    end
  end
end
