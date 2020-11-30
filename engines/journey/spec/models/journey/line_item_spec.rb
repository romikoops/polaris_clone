require "rails_helper"

module Journey
  RSpec.describe LineItem, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_line_item)).to be_valid
    end
  end
end
