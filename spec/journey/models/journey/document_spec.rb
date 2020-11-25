require "rails_helper"

module Journey
  RSpec.describe Document, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_document)).to be_valid
    end
  end
end
