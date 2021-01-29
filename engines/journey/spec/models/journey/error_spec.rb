require "rails_helper"

module Journey
  RSpec.describe Error, type: :model do
    it "creates a valid error" do
      expect(FactoryBot.build(:journey_error)).to be_valid
    end
  end
end
