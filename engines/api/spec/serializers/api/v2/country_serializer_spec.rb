# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::CountrySerializer do
    let(:country) { FactoryBot.create(:country) }
    let(:serialized_country) { described_class.new(country).serializable_hash }
    let(:target) { serialized_country.dig(:data, :attributes) }
    let(:expected_serialized_country) do
      {
        id: country.id,
        name: country.name,
        code: country.code,
        flag: country.flag
      }
    end

    it "returns the correct object passed" do
      expect(target).to eq(expected_serialized_country)
    end
  end
end
