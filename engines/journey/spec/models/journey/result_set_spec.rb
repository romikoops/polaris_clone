# frozen_string_literal: true
require "rails_helper"

module Journey
  RSpec.describe ResultSet, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_result_set)).to be_valid
    end
  end
end
