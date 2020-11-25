require "rails_helper"

module Journey
  RSpec.describe CargoUnit, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_cargo_unit)).to be_valid
    end
  end
end
