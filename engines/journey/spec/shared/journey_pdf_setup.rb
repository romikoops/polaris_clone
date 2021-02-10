# frozen_string_literal: true

RSpec.shared_context "journey_pdf_setup" do
  include_context "journey_complete_request"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:charge_categories) do
    %w[
      trucking_pre
      trucking_on
      cargo
      export
      import
    ]
  end

  let(:route_sections) {
    [
      pre_carriage_section,
      origin_transfer_section,
      freight_section,
      destination_transfer_section,
      on_carriage_section
    ]
  }
  let(:line_items) {
    [
      pre_carriage_line_items_with_cargo,
      origin_transfer_line_items_with_cargo,
      freight_line_items_with_cargo,
      destination_transfer_line_items_with_cargo,
      on_carriage_line_items_with_cargo
    ].flatten
  }

  before do
    charge_categories.each do |code|
      FactoryBot.create(:legacy_charge_categories, code: code, name: code.humanize, organization: organization)
    end
    breakdown
    Geocoder::Lookup::Test.add_stub([origin_latitude, origin_longitude], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => origin_text,
      "city" => "",
      "country" => "",
      "country_code" => factory_country_from_code(code: "SE").code,
      "postal_code" => ""
    ])
    Geocoder::Lookup::Test.add_stub([destination_latitude, destination_longitude], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => destination_text,
      "city" => "",
      "country" => "",
      "country_code" => factory_country_from_code(code: "CN").code,
      "postal_code" => ""
    ])
    FactoryBot.create(:legacy_hub, hub_type: "ocean", hub_code: origin_locode, organization: organization )
    FactoryBot.create(:legacy_hub, hub_type: "ocean", hub_code: destination_locode, organization: organization )
    FactoryBot.create(:treasury_exchange_rate, from: "EUR", to: "USD", created_at: result.issued_at - 2.seconds)
  end
end
