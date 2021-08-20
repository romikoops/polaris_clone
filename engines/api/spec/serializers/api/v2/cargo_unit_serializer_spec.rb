# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::CargoUnitSerializer do
    let(:cargo_unit) { FactoryBot.create(:journey_cargo_unit) }
    let(:serialized_cargo_unit) { described_class.new(cargo_unit).serializable_hash }
    let(:target) { serialized_cargo_unit.dig(:data, :attributes) }

    let!(:commodity_info) { FactoryBot.create(:journey_commodity_info, cargo_unit: cargo_unit) }
    let(:expected_keys) do
      %i[cargoClass
        colliType
        height
        length
        stackable
        quantity
        weight
        width
        volume
        commodities]
    end

    it "returns the ckeys for the serialized Cargo unit", :aggregate_failures do
      expect(target[:commodities].first.except("createdAt", "updatedAt")).to eq(
        commodity_info.attributes.transform_keys { |key| key.camelize(:lower) }.except("createdAt", "updatedAt")
      )
      expect(target.keys).to eq(expected_keys)
    end
  end
end
