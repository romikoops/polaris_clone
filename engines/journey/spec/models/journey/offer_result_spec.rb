# frozen_string_literal: true
require "rails_helper"

module Journey
  RSpec.describe OfferResult, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_offer_result)).to be_valid
    end
  end
end
