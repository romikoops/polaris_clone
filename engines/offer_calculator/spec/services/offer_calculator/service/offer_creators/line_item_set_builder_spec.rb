# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::LineItemSetBuilder do
  include_context "full_offer"

  let(:line_item_set) { described_class.line_item_set(offer: offer, request: request, route_sections: route_sections) }
  let(:route_sections) { FactoryBot.build_list(:journey_route_section, 5) }

  describe ".line_item_set" do
    before do
      Organizations.current_id = organization.id
      allow(Carta::Client).to receive(:suggest).and_return(FactoryBot.build(:carta_result))
    end

    it "returns the correct number of results for the number of offers" do
      expect(line_item_set.line_items.length).to eq(offer.charges.count)
    end
  end
end
