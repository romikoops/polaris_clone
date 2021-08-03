# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ChargeSerializer do
    let(:line_item) { FactoryBot.create(:journey_line_item) }
    let(:decorated_line_item) { Api::V2::LineItemDecorator.new(line_item) }
    let(:serialized_line_item) { described_class.new(decorated_line_item).serializable_hash }
    let(:target) { serialized_line_item.dig(:data, :attributes) }
    let(:organization) { line_item.result.query.organization }
    let(:line_item_total) do
      {
        value: line_item.total.cents / 100.0,
        currency: line_item.total.currency.iso_code
      }
    end
    let(:expected_serialized_line_item) do
      {
        id: line_item.id,
        feeCode: line_item.fee_code,
        description: line_item.description,
        originalValue: nil,
        value: line_item_total,
        order: line_item.order,
        section: decorated_line_item.section,
        unitPrice: {
          value: line_item.unit_price.cents / 100.0,
          currency: line_item.unit_price.currency.iso_code
        },
        units: line_item.units
      }
    end

    before do
      FactoryBot.create(:legacy_charge_categories, code: "cargo", organization: organization)
      FactoryBot.create(:legacy_charge_categories, code: line_item.fee_code, organization: organization)
      Organizations.current_id = line_item.result.query.organization_id
    end

    it "returns the correct origin name for the object passed" do
      expect(target).to eq(expected_serialized_line_item)
    end
  end
end
