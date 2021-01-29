# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CargoUnitDecorator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:query) { FactoryBot.build(:journey_query, organization: organization) }
  let(:cargo_unit) { FactoryBot.build(:journey_cargo_unit, query: query) }
  let(:decorated_cargo_unit) { described_class.new(cargo_unit, context: {scope: scope}) }
  let(:legacy_cargo_item_type) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }

  before do
    FactoryBot.create(:legacy_tenant_cargo_item_type, cargo_item_type: legacy_cargo_item_type, organization: organization)
  end

  describe ".dangerous_goods" do
    it "returns false when no imo classes are added" do
      expect(decorated_cargo_unit.dangerous_goods).to be_falsy
    end

    context "with IMO Classes" do
      before do
        FactoryBot.create(:journey_commodity_info, imo_class: "0", cargo_unit: cargo_unit)
      end

      it "returns true when there are IMO classes added" do
        expect(decorated_cargo_unit.dangerous_goods).to be_truthy
      end
    end
  end

  describe ".cargo_item_type_id" do
    it "returns the Legacy::CargoItemType from the colli type enum" do
      expect(decorated_cargo_unit.cargo_item_type_id).to eq(legacy_cargo_item_type.id)
    end
  end
end
