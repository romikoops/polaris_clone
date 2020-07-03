RSpec.shared_context "false_itinerary" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:faux_origin_address) { FactoryBot.create(:hamburg_address) }
  let(:faux_destination_address) { FactoryBot.create(:felixstowe_address) }
  let(:faux_origin_stop) do
    FactoryBot.build(:legacy_stop,
      itinerary_id: nil,
      index: 0,
      hub: FactoryBot.create(:legacy_hub,
        organization: organization,
        name: "Gothenburg",
        hub_type: "ocean",
        hub_code: "DEGOT",
        address: faux_origin_address,
        nexus: FactoryBot.create(:legacy_nexus,
          name: "Gothenburg",
          locode: "DEGOT",
          country: faux_origin_address.country,
          organization: organization)))
  end
  let(:faux_destination_stop) do
    FactoryBot.build(:legacy_stop,
      itinerary_id: nil,
      index: 1,
      hub: FactoryBot.create(:legacy_hub,
        organization: organization,
        name: "Shanghai",
        hub_type: "ocean",
        hub_code: "GBSHA",
        address: faux_destination_address,
        nexus: FactoryBot.create(:legacy_nexus,
          name: "Shanghai",
          locode: "GBSHA",
          country: faux_destination_address.country,
          organization: organization)))
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
