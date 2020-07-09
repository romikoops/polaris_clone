RSpec.shared_context "false_itinerary" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:faux_origin_country) { FactoryBot.create(:country_de)}
  let(:faux_destination_country) { FactoryBot.create(:country_uk)}
  let(:faux_origin_address) { FactoryBot.create(:hamburg_address, country: faux_origin_country) }
  let(:faux_destination_address) { FactoryBot.create(:felixstowe_address, country: faux_destination_country) }
  let(:faux_origin_name) { 'Gothenburg' }
  let(:faux_destination_name) { 'Shanghai' }
  let(:faux_origin_locode) { 'DEGOT' }
  let(:faux_destination_locode) { 'GBSHA' }
  let(:faux_mot) { 'ocean' }
  let(:faux_origin_stop) do
    FactoryBot.build(:legacy_stop,
      itinerary_id: nil,
      index: 0,
      hub: faux_origin_hub)
  end
  let(:faux_origin_hub) {
    Legacy::Hub.find_by(
      name: faux_origin_name,
      hub_code: faux_origin_locode,
      organization: organization,
      hub_type: faux_mot
    ) || FactoryBot.create(:legacy_hub,
      organization: organization,
      name: faux_origin_name,
      hub_type: "ocean",
      hub_code: faux_origin_locode,
      address: faux_origin_address,
      nexus: faux_origin_nexus)
  }
  let(:faux_origin_nexus) {
    Legacy::Nexus.find_by(
      name: faux_origin_name,
      locode: faux_origin_locode,
      organization: organization
    ) || FactoryBot.create(:legacy_nexus,
        name: faux_origin_name,
        locode: faux_origin_locode,
        country: faux_origin_address.country,
        organization: organization)
  }
  let(:faux_destination_hub) {
    Legacy::Hub.find_by(
      name: faux_destination_name,
      hub_code: faux_destination_locode,
      organization: organization,
      hub_type: faux_mot
    ) || FactoryBot.create(:legacy_hub,
      organization: organization,
      name: faux_destination_name,
      hub_type: "ocean",
      hub_code: faux_destination_locode,
      address: faux_destination_address,
      nexus: faux_destination_nexus)
  }
  let(:faux_destination_nexus) {
    Legacy::Nexus.find_by(
      name: faux_destination_name,
      locode: faux_destination_locode,
      organization: organization
    ) || FactoryBot.create(:legacy_nexus,
        name: faux_destination_name,
        locode: faux_destination_locode,
        country: faux_destination_address.country,
        organization: organization)
  }
  let(:faux_destination_stop) do
    FactoryBot.build(:legacy_stop,
      itinerary_id: nil,
      index: 1,
      hub: faux_destination_hub)
  end
  let(:faux_stops) do
    [
      faux_origin_stop,
      faux_destination_stop
    ]
  end
  let!(:faux_itinerary) do
    FactoryBot.create(:default_itinerary,
      organization: organization,
      name: "Gothenburg - Shanghai",
      stops: faux_stops)
  end
end
