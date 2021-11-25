# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::LegacyCargoUnitDecorator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:query) { FactoryBot.build(:journey_query, organization: organization) }
  let(:cargo_unit) { FactoryBot.build(:journey_cargo_unit, query: query) }
  let(:decorated_cargo_unit) { described_class.new(cargo_unit, context: { scope: scope }) }
  let(:legacy_cargo_item_type) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
  let(:legacy_format) { decorated_cargo_unit.legacy_format }
  let(:lcl_values) do
    {
      id: cargo_unit.id,
      quantity: cargo_unit.quantity,
      payload_in_kg: cargo_unit.weight_value,
      width: cargo_unit.width_value && cargo_unit.width_value * 100.0,
      height: cargo_unit.height_value && cargo_unit.height_value * 100.0,
      length: cargo_unit.length_value && cargo_unit.length_value * 100.0,
      cargo_class: "lcl"
    }
  end

  before do
    FactoryBot.create(:legacy_tenant_cargo_item_type, cargo_item_type: legacy_cargo_item_type, organization: organization)
  end

  describe "#legacy_format" do
    context "when FCL" do
      let(:cargo_unit) { FactoryBot.build(:journey_cargo_unit, :fcl, query: query) }
      let(:fcl_format) do
        {
          id: cargo_unit.id,
          quantity: cargo_unit.quantity,
          payload_in_kg: cargo_unit.weight_value,
          size_class: cargo_unit.cargo_class
        }
      end

      it "returns fcl format when the units are fcl" do
        expect(legacy_format).to eq(fcl_format)
      end
    end

    context "when LCL" do
      it "returns lcl format when the units are lcl" do
        expect(legacy_format).to eq(lcl_values.merge(
          cargo_item_type: {
            description: cargo_unit.colli_type.humanize
          }
        ))
      end
    end
  end

  describe ".cargo_item_type_id" do
    it "returns the Legacy::CargoItemType from the colli type enum" do
      expect(decorated_cargo_unit.cargo_item_type_id).to eq(legacy_cargo_item_type.id)
    end
  end

  describe "#aggregate_format" do
    let(:cargo_unit) { FactoryBot.build(:journey_cargo_unit, :aggregate_lcl, query: query) }
    let(:agg_values) do
      {
        id: cargo_unit.id,
        weight: cargo_unit.weight_value,
        volume: cargo_unit.volume_value
      }
    end

    it "returns Agg LCL format when the units are aggregated" do
      expect(decorated_cargo_unit.aggregate_format).to eq(agg_values)
    end
  end
end
