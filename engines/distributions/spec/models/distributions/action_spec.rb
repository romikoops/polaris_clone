# frozen_string_literal: true

require "rails_helper"

module Distributions
  RSpec.describe Action, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:distributions_action)).to be_valid
    end

    it "is invalid when the order already exists for the Organization/TargetOrganization pair" do
      expect(FactoryBot.create(:distributions_action).dup).not_to be_valid
    end
  end
end
