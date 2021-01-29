# frozen_string_literal: true

RSpec.shared_context "journey_legacy_models" do
  let(:origin_country) { factory_country_from_code(code: origin_locode[0..1]) }
  let(:destination_country) { factory_country_from_code(code: destination_locode[0..1]) }
  let(:origin_nexus) {
    FactoryBot.create(:legacy_nexus,
      locode: origin_locode,
      organization: organization,
      country: origin_country)
  }
  let(:destination_nexus) {
    FactoryBot.create(:legacy_nexus,
      locode: destination_locode,
      organization: organization,
      country: destination_country)
  }
  let(:pickup_address) {
    FactoryBot.create(:legacy_address,
      latitude: origin_coordinates.y,
      longitude: origin_coordinates.x,
      geocoded_address: origin_text,
      country: origin_country)
  }
  let(:delivery_address) {
    FactoryBot.create(:legacy_address,
      latitude: destination_coordinates.y,
      longitude: destination_coordinates.x,
      geocoded_address: destination_text,
      country: destination_country)
  }
  let(:origin_hub) {
    FactoryBot.create(:legacy_hub,
      hub_code: origin_locode,
      organization: organization,
      address: FactoryBot.create(:legacy_address, country: origin_country))
  }
  let(:destination_hub) {
    FactoryBot.create(:legacy_hub,
      hub_code: destination_locode,
      organization: organization,
      address: FactoryBot.create(:legacy_address, country: origin_country))
  }
  let(:itinerary) {
    FactoryBot.create(:legacy_itinerary,
      organization: organization,
      origin_hub: origin_hub,
      destination_hub: destination_hub,
      stops: [
        FactoryBot.build(:legacy_stop, hub: origin_hub, index: 0),
        FactoryBot.build(:legacy_stop, hub: destination_hub, index: 1)
      ]
    )
  }
  let(:tenant_vehicle) {
    FactoryBot.create(:legacy_tenant_vehicle, organization: organization, name: freight_carriage_service, carrier: freight_carrier)
  }
  let(:freight_carrier) {
    FactoryBot.create(:legacy_carrier, name: freight_carriage_carrier, code: freight_carriage_carrier.downcase)
  }
  let(:pricing) {
    FactoryBot.create(:pricings_pricing,
      :lcl,
      tenant_vehicle: tenant_vehicle,
      itinerary: itinerary,
      organization: organization)
  }
  let(:default_group) { Groups::Group.find_by(name: "default", organization: organization) }
  let!(:default_margin) {
    FactoryBot.create(:pricings_margin,
      margin_type: "freight_margin",
      applicable: default_group,
      value: 0,
      organization: organization)
  }
end
