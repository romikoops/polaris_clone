require "rails_helper"

module Journey
  RSpec.describe Offer, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_offer)).to be_valid
    end
  end
end
