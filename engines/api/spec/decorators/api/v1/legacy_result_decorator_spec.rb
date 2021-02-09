# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::LegacyResultDecorator do
  let!(:result) { FactoryBot.build(:journey_result) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
  let(:decorated_query) { described_class.new(result, context: {scope: scope}) }
  let(:legacy_format) { decorated_query.legacy_format }
  let(:note) { FactoryBot.create(:legacy_note) }
  let(:note_service_dummy) { double("Notes::Service", fetch: [note]) }
  let(:metadatum) { FactoryBot.create(:pricings_metadatum, result_id: result.id) }
  let(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization) }
  let(:line_item) { FactoryBot.create(:journey_line_item, route_section: result.route_sections.first) }

  before do
    result.line_item_sets.first.line_items << line_item
    line_item.save
    FactoryBot.create(:pricings_breakdown,
      metadatum: metadatum,
      rate_origin: {type: "Pricings::Pricing", id: pricing.id},
      order: 0,
      line_item_id: line_item.id)
    allow(Notes::Service).to receive(:new).and_return(note_service_dummy)
    FactoryBot.create(:treasury_exchange_rate, from: "EUR", to: "USD")
  end

  describe ".legacy_format" do
    let(:meta_keys) do
      %i[
        mode_of_transport
        service_level
        carrier_name
        pre_carriage_service
        pre_carriage_carrier
        on_carriage_service
        on_carriage_carrier
        origin_hub
        destination_hub
        load_type
        exchange_rates
        validUntil
        pricing_rate_data
        remarkNotes
        tender_id
        ocean_chargeable_weight
        transshipmentVia
      ]
    end

    it "returns the legacy response format" do
      aggregate_failures do
        expect(legacy_format.dig(:quote)).to match_response_schema("legacy/simple_quote")
        expect(legacy_format.dig(:meta).keys).to match_array(meta_keys)
        expect(legacy_format.dig(:notes)).to eq([note])
      end
    end
  end
end
