# frozen_string_literal: true

RSpec.shared_context "journey_pricing_metadatum" do
  before do
    result.save
  end

  let(:metadatum) { FactoryBot.create(:pricings_metadatum, result_id: result.id) }
  let(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization) }
  let(:breakdown) do
    FactoryBot.create(:pricings_breakdown,
      metadatum: metadatum,
      rate_origin: {type: "Pricings::Pricing", id: pricing.id},
      order: 0,
      line_item_id: freight_line_items_with_cargo.first.id)
  end
end
