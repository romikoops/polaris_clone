# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::LegacyQueryDecorator do
  include_context "journey_complete_request"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
  let(:decorated_query) { described_class.new(query, context: {scope: scope}) }
  let(:legacy_format) { decorated_query.legacy_json }
  let(:line_item) { result.line_item_sets.first.line_items.first }
  let(:line_items) do
    freight_line_items_with_cargo
  end
  let(:route_sections) do
    [freight_section]
  end

  before do
    FactoryBot.create(:treasury_exchange_rate, from: "EUR", to: "USD")
    breakdown
  end

  describe ".legacy_json" do
    it "returns the legacy response format" do
      aggregate_failures do
        expect(legacy_format.dig(:quotationId)).to eq(query.id)
        expect(legacy_format.dig(:completed)).to be_present
      end
    end
  end
end
