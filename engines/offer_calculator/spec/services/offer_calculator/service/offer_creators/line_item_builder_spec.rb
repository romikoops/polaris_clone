# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::LineItemBuilder do
  include_context "full_offer"

  let(:offers) { [offer] }
  let(:line_items) { described_class.line_items(offer: offer, request: request, route_sections: route_sections) }
  let(:route_sections) { FactoryBot.build_list(:journey_route_section, 5) }

  describe ".line_items" do
    before do
      Organizations.current_id = organization.id
      allow(Carta::Client).to receive(:suggest).and_return(FactoryBot.build(:carta_result))
    end

    it "returns the correct number of results for the number of offers" do
      expect(line_items.length).to eq(offer.charges.count)
    end
  end
end
