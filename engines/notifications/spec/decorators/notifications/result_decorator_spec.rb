# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::ResultDecorator do
  let(:scope) { {append_query_suffix: false} }
  let(:decorated_query) { described_class.new(result, context: {scope: scope}) }
  let(:result) { FactoryBot.create(:journey_result) }
  let(:address) { FactoryBot.create(:legacy_address, country: factory_country_from_code(code: "SE")) }
  let(:origin_route_point) { result.route_sections.first.from }
  let(:destination_route_point) { result.route_sections.first.to }

  describe ".routing" do
    let(:expected_string) do
      [
        origin_route_point.name,
        destination_route_point.name
      ].join(" - ")
    end

    it "returns the origin and destination names joined together" do
      expect(decorated_query.routing).to eq(expected_string)
    end
  end

  describe ".total" do
    let(:expected_string) do
      result.line_item_sets.first.line_items.inject(Money.new(0, "EUR")) { |sum, item| sum + item.total }
        .format(rounded_infinite_precision: true)
    end

    it "returns the origin and destination names joined together" do
      expect(decorated_query.total).to eq(expected_string)
    end
  end
end
