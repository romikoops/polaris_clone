require "rails_helper"

module Journey
  RSpec.describe Shipment, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_shipment)).to be_valid
    end
  end
end
