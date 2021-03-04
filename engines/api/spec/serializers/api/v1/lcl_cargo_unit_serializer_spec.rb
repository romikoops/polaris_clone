# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::LclCargoUnitSerializer do
    let(:cargo_item) { FactoryBot.create(:journey_cargo_unit) }
    let(:decorated_cargo_item) { Api::V1::CargoUnitDecorator.new(cargo_item) }
    let(:serialized_cargo_item) { described_class.new(decorated_cargo_item).serializable_hash }
    let(:target) { serialized_cargo_item.dig(:data, :attributes) }

    before { FactoryBot.create(:legacy_cargo_item_type) }

    it "returns the cargo Item type properly formatted" do
      expect(target[:cargoItemType]).to eq(
        { id: decorated_cargo_item.cargo_item_type_id, description: cargo_item.colli_type.humanize }
      )
    end
  end
end
