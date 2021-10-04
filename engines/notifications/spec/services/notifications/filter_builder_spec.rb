# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::FilterBuilder do
  subject(:filter_builder) { described_class.new(offer: offer).to_hash }

  let(:offer) { FactoryBot.create(:journey_offer, query: query, line_item_sets: result.line_item_sets) }
  let(:result) { FactoryBot.create(:journey_result) }
  let(:route_point_from) { FactoryBot.create(:journey_route_point, name: "Hamburg", locode: "DEHAM") }
  let(:route_point_to) { FactoryBot.create(:journey_route_point, name: "Shangai", locode: "CHSHN") }
  let!(:route_section) do
    FactoryBot.create(:journey_route_section,
      result: result,
      from: route_point_from,
      to: route_point_to)
  end

  let!(:query) { FactoryBot.create(:journey_query) }

  shared_examples_for "filter hash" do
    %w[origins destinations mode_of_transports groups].each do |filter|
      it { is_expected.to include(filter.to_sym) }
      it { expect(filter_builder[filter.to_sym]).to be_a_kind_of(Array) }
    end

    it "returns the correct origins" do
      expect(filter_builder[:origins]).to include(route_point_from.locode)
    end

    it "returns the correct destinations" do
      expect(filter_builder[:destinations]).to include(route_point_to.locode)
    end

    it "returns the correct mode_of_transports" do
      expect(filter_builder[:mode_of_transports]).to include(route_section.mode_of_transport)
    end
  end

  describe "#to_hash" do
    it_behaves_like "filter hash"

    context "with multiple results" do
      let(:result) { FactoryBot.build(:journey_result) }
      let(:route_point_from) { FactoryBot.build(:journey_route_point, name: "Shangai", locode: "CHSHN") }
      let(:route_point_to) { FactoryBot.build(:journey_route_point, name: "Mumbai", locode: "BOM") }
      let(:route_section) do
        FactoryBot.create(:journey_route_section,
          result: result,
          from: route_point_from,
          to: route_point_to)
      end

      it_behaves_like "filter hash"
    end
  end
end
