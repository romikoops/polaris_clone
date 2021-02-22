# frozen_string_literal: true
require "rails_helper"

module Journey
  RSpec.describe RouteSection, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_route_section)).to be_valid
    end
  end
end
