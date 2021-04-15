# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::OfferSubjectLine do
  include_context "journey_complete_request"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:offer) { FactoryBot.create(:journey_offer, query: query, line_item_sets: result.line_item_sets) }
  let(:scope) { Organizations::DEFAULT_SCOPE.with_indifferent_access }
  let(:subject_line_service) { described_class.new(offer: offer, scope: scope) }
  let(:subject_line) { subject_line_service.subject_line }
  let(:context) { subject_line_service.context }
  let(:origin_city) { "Hamburg" }
  let(:destination_city) { "Shanghai" }
  let(:dummy_reference) { "XXXXX" }

  before do
    ::Organizations.current_id = organization.id
    Geocoder::Lookup::Test.add_stub([query.origin_coordinates.y, query.origin_coordinates.x], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => query.origin,
      "city" => origin_city,
      "country" => "",
      "country_code" => factory_country_from_code(code: "DE").code,
      "postal_code" => "20457"
    ])
    Geocoder::Lookup::Test.add_stub([query.destination_coordinates.y, query.destination_coordinates.x], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => query.destination,
      "city" => destination_city,
      "country" => "",
      "country_code" => factory_country_from_code(code: "CN").code,
      "postal_code" => "22000"
    ])
    allow(Journey::ImcReference).to receive(:new).and_return(instance_double("Journey::ImcReference", reference: dummy_reference))
  end

  describe ".subject_line" do
    context "with default settings" do
      let(:route_sections) { [freight_section] }
      let(:line_items) { freight_line_items_with_cargo }

      it "returns the subject line in standard format", :aggregate_failures do
        expect(subject_line).to include("LCL")
        expect(subject_line).to include(query.origin)
        expect(subject_line).to include(query.destination)
      end
    end

    context "with escaping" do
      let(:route_sections) do
        [
          pre_carriage_section,
          origin_transfer_section,
          freight_section
        ]
      end
      let(:line_items) do
        [
          pre_carriage_line_items_with_cargo,
          origin_transfer_line_items_with_cargo,
          freight_line_items_with_cargo
        ].flatten
      end
      let(:scope) { Organizations::DEFAULT_SCOPE.with_indifferent_access.merge(email_subject_template: liquid_template) }
      let(:liquid_template) do
        [
          'ItsMyCargo Quotation Tool: {{imc_reference}} - from: \'{{origin_city}}\' "{{origin}}" - to:',
          '\'{{destination_city}}\' "{{destination}}" / {{total_weight}}kg / {{total_volume}}cbm'
        ].join(" ")
      end
      let(:expected_string) do
        [
          "ItsMyCargo Quotation Tool: #{dummy_reference} - from:",
          "'#{origin_city}' \"DE-20457\" - to: '#{query.destination[0, 21]}..."
        ].join(" ")
      end

      it "renders properly with escaped values" do
        expect(subject_line).to eq(expected_string)
      end
    end

    context "with on and pre carriage" do
      let(:route_sections) do
        [
          pre_carriage_section,
          origin_transfer_section,
          freight_section,
          destination_transfer_section,
          on_carriage_section
        ]
      end
      let(:line_items) do
        [
          pre_carriage_line_items_with_cargo,
          origin_transfer_line_items_with_cargo,
          freight_line_items_with_cargo,
          destination_transfer_line_items_with_cargo,
          on_carriage_line_items_with_cargo
        ].flatten
      end
      let(:scope) { Organizations::DEFAULT_SCOPE.with_indifferent_access.merge(email_subject_template: liquid_template) }
      let(:liquid_template) { "From: {{origin_city}} to: {{destination_city}}" }

      it "returns the subject with the city names when there is pre and on carriage" do
        expect(subject_line).to eq("From: Hamburg to: Shanghai")
      end
    end
  end

  describe ".context" do
    let(:expected_base) do
      { "imc_reference" => "XXXXX",
        "external_id" => nil,
        "origin_locode" => "DEHAM",
        "origin_city" => "438 80 Landvetter, Sweden",
        "origin" => "DEHAM",
        "destination_locode" => "CNSHA",
        "destination_city" => "88 Henan Middle Road, Shanghai",
        "destination" => "CNSHA",
        "client_name" => query.client.profile.full_name,
        "references" => "Refs: XXXXX",
        "routing" => "438 80 Landvetter, Sweden - 88 Henan Middle Road, Shanghai",
        "noun" => "Quotation" }
    end

    context "with default settings (LCL)" do
      let(:expected) do
        expected_base.merge(
          "total_weight" => 1000.0,
          "total_volume" => 1.0,
          "load_type" => "LCL"
        )
      end
      let(:route_sections) { [freight_section] }
      let(:line_items) { freight_line_items_with_cargo }

      it "returns the subject line in standard format" do
        expect(context).to eq(expected)
      end
    end

    context "with default settings (FCL)" do
      let(:journey_load_type) { "fcl" }
      let(:expected) do
        expected_base.merge(
          "total_weight" => 1000.0,
          "total_volume" => 0.0,
          "load_type" => "FCL"
        )
      end
      let(:route_sections) { [freight_section] }
      let(:line_items) { freight_line_items_with_cargo }
      let(:cargo_unit_params) do
        [
          {
            cargo_class: "fcl_20",
            quantity: 1,
            weight_value: 1000
          }
        ]
      end

      it "returns the subject line in standard format" do
        expect(context).to eq(expected)
      end
    end

    context "with on and pre carriage" do
      let(:route_sections) do
        [
          pre_carriage_section,
          origin_transfer_section,
          freight_section,
          destination_transfer_section,
          on_carriage_section
        ]
      end
      let(:line_items) do
        [
          pre_carriage_line_items_with_cargo,
          origin_transfer_line_items_with_cargo,
          freight_line_items_with_cargo,
          destination_transfer_line_items_with_cargo,
          on_carriage_line_items_with_cargo
        ].flatten
      end
      let(:expected) do
        expected_base.merge(
          "origin_city" => "Hamburg",
          "origin" => "DE-20457",
          "destination_locode" => "CNSHA",
          "destination_city" => "Shanghai",
          "destination" => "CN-22000",
          "total_weight" => 1000.0,
          "total_volume" => 1.0,
          "load_type" => "LCL",
          "references" => "Refs: XXXXX",
          "routing" => "Hamburg - Shanghai"
        )
      end

      it "returns the subject with the city names when there is pre and on carriage" do
        expect(context).to eq(expected)
      end
    end
  end
end
