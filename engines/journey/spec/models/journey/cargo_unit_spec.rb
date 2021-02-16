# frozen_string_literal: true

require "rails_helper"

module Journey
  RSpec.describe CargoUnit, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_cargo_unit)).to be_valid
    end

    it "rejects an invalid cargo class" do
      expect(FactoryBot.build(:journey_cargo_unit, cargo_class: "cargo_item")).not_to be_valid
    end
  end
end
