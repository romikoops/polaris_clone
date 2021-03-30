# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::LineItemBuilder do
  include_context "full_offer"

  let(:offers) { [offer] }
  let(:line_item_builder) { described_class.new(offer: offer, request: request, route_sections: route_sections) }
  let(:line_items) { line_item_builder.line_items }
  let(:route_sections) { FactoryBot.build_list(:journey_route_section, 5) }

  describe ".line_items" do
    before do
      Organizations.current_id = organization.id
      allow(Carta::Client).to receive(:suggest).and_return(FactoryBot.build(:carta_result))
      allow(line_item_builder).to receive(:currency).and_return("USD")
    end

    it "returns the correct number of results for the number of offers" do
      expect(line_items.length).to eq(offer.charges.count)
    end

    it "attaches the correct exchange rate to the line item" do
      line_items.each do |line_item|
        expect(line_item.exchange_rate).to eq(Money.default_bank.get_rate(line_item.total_currency, "USD"))
      end
    end
  end
end
