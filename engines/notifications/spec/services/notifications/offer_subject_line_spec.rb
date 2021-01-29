# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::OfferSubjectLine do
  let(:offer) { FactoryBot.build(:journey_offer) }
  let(:query) { offer.query }
  let(:scope) { Organizations::DEFAULT_SCOPE.with_indifferent_access }
  let(:subject_line_service) { described_class.new(offer: offer, scope: scope) }
  let(:subject_line) { subject_line_service.subject_line }
  let(:origin_city) { "Hamburg" }
  let(:destination_city) { "Shanghai" }
  before do
    ::Organizations.current_id = query.organization_id
    Geocoder::Lookup::Test.add_stub([query.origin_coordinates.y, query.origin_coordinates.x], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => query.origin,
      "city" => origin_city,
      "country" => "",
      "country_code" => factory_country_from_code(code: "DE").code,
      "postal_code" => ""
    ])
    Geocoder::Lookup::Test.add_stub([query.destination_coordinates.y, query.destination_coordinates.x], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => query.destination,
      "city" => destination_city,
      "country" => "",
      "country_code" => factory_country_from_code(code: "CN").code,
      "postal_code" => ""
    ])
  end

  describe ".subject_line" do
    context "with default settings" do
      it "returns the subject line in standard format" do
        expect(subject_line).to include("FCL")
        expect(subject_line).to include(query.origin)
        expect(subject_line).to include(query.destination)
      end
    end

    context "with escaping" do
      before do
        allow(Journey::ImcReference).to receive(:new).and_return(double(reference: dummy_reference))
        offer.results.first.route_sections << FactoryBot.build(:journey_route_section,
          order: 0,
          mode_of_transport: "carriage")
      end

      let(:dummy_reference) { "XXXXX" }
      let(:scope) { Organizations::DEFAULT_SCOPE.with_indifferent_access.merge(email_subject_template: liquid_template) }
      let(:liquid_template) {
        [
          'ItsMyCargo Quotation Tool: {{imc_reference}} - from: \'{{origin_city}}\' "{{origin}}" - to:',
          '\'{{destination_city}}\' "{{destination}}" / {{total_weight}}kg / {{total_volume}}cbm'
        ].join(" ")
      }
      let(:result) {
        [
          "ItsMyCargo Quotation Tool: #{dummy_reference} - from:",
          "'#{origin_city}' \"DEHAM\" - to: '#{query.destination}' \"DEHAM..."
        ].join(" ")
      }

      it "renders properly with escaped values" do
        expect(subject_line).to eq(result)
      end
    end

    context "with on and pre carriage" do
      before do
        offer.results.first.route_sections << FactoryBot.build(:journey_route_section,
          order: 0,
          mode_of_transport: "carriage")
        offer.results.first.route_sections << FactoryBot.build(:journey_route_section,
          order: 5,
          mode_of_transport: "carriage")
      end
      let(:scope) { Organizations::DEFAULT_SCOPE.with_indifferent_access.merge(email_subject_template: liquid_template) }
      let(:liquid_template) { "From: {{origin_city}} to: {{destination_city}}" }

      it "returns the subject with the city names when there is pre and on carriage" do
        expect(subject_line).to eq("From: Hamburg to: Shanghai")
      end
    end
  end
end
