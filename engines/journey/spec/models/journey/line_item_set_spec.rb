# frozen_string_literal: true
require "rails_helper"

module Journey
  RSpec.describe LineItemSet, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_line_item_set)).to be_valid
    end
  end
end
