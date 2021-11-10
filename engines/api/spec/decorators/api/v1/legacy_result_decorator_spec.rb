# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::LegacyResultDecorator do
  let!(:result) { FactoryBot.build(:journey_result, query: FactoryBot.build(:journey_query, organization: organization)) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:decorated_result) { described_class.new(result, context: { scope: Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }) }
  let(:legacy_format) { decorated_result.legacy_format }
  let(:note) { FactoryBot.create(:legacy_note) }
  let(:note_service_dummy) { instance_double("Notes::Service", fetch: [note]) }
  let(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization) }
  let(:line_item) { FactoryBot.create(:journey_line_item, route_section: result.route_sections.first) }

  before do
    result.line_item_sets.first.line_items << line_item
    line_item.save
    FactoryBot.create(:pricings_breakdown,
      metadatum: FactoryBot.build(:pricings_metadatum, result_id: result.id),
      rate_origin: { type: "Pricings::Pricing", id: pricing.id },
      order: 0,
      line_item_id: line_item.id)
    allow(Notes::Service).to receive(:new).and_return(note_service_dummy)
    FactoryBot.create(:treasury_exchange_rate, from: "EUR", to: "USD")
    %w[
      trucking_pre
      trucking_on
      cargo
      export
      import
    ].each do |code|
      FactoryBot.create(:legacy_charge_categories, code: code, name: code.humanize, organization: organization)
    end
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
        charge_trip_id
        transit_time
      ]
    end

    it "returns the legacy response format", :aggregate_failures do
      expect(legacy_format[:quote]).to match_response_schema("legacy/simple_quote")
      expect(legacy_format[:meta].keys).to match_array(meta_keys)
      expect(legacy_format[:notes]).to eq([note])
    end

    context "when pricing is destroyed" do
      before { pricing.destroy }

      it "returns the legacy response format" do
        expect(legacy_format[:quote]).to match_response_schema("legacy/simple_quote")
      end
    end
  end
end
