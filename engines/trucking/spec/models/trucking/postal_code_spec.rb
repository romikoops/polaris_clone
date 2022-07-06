# frozen_string_literal: true

require "rails_helper"

module Trucking
  RSpec.describe PostalCode, type: :model do
    it "builds a valid PostalCode" do
      expect(FactoryBot.build(:trucking_postal_code)).to be_valid
    end

    it "rejects duplicates for the same country as invalid" do
      country = FactoryBot.create(:legacy_country)
      FactoryBot.create(:trucking_postal_code, country: country, postal_code: "12345")
      expect(FactoryBot.build(:trucking_postal_code, country: country, postal_code: "12345")).to be_invalid
    end
  end
end
