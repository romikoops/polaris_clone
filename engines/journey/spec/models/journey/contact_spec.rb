# frozen_string_literal: true
require "rails_helper"

module Journey
  RSpec.describe Contact, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_contact)).to be_valid
    end
  end
end
