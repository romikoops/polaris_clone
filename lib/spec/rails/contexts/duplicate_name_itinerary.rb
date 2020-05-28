RSpec.shared_context "false_itinerary" do
  let(:tenant) { FactoryBot.create(:tenant) }
  let(:faux_origin_address) { FactoryBot.create(:hamburg_address) }
  let(:faux_destination_address) { FactoryBot.create(:felixstowe_address) }
  let(:faux_origin_stop) do
    FactoryBot.build(:legacy_stop,
      itinerary_id: nil,
      index: 0,
      hub: FactoryBot.create(:legacy_hub,
        tenant: tenant,
        name: "Gothenburg Port",
        hub_type: "ocean",
        hub_code: "DEGOT",
        address: faux_origin_address,
        nexus: FactoryBot.create(:legacy_nexus,
          name: "Gothenburg",
          locode: "DEGOT",
          country: faux_origin_address.country,
          tenant: tenant)))
  end
  let(:faux_destination_stop) do
    FactoryBot.build(:legacy_stop,
      itinerary_id: nil,
      index: 1,
      hub: FactoryBot.create(:legacy_hub,
        tenant: tenant,
        name: "Shanghai Port",
        hub_type: "ocean",
        hub_code: "GBSHA",
        address: faux_destination_address,
        nexus: FactoryBot.create(:legacy_nexus,
          name: "Shanghai",
          locode: "GBSHA",
          country: faux_destination_address.country,
          tenant: tenant)))
  end
  let(:faux_stops) do
    [
      faux_origin_stop,
      faux_destination_stop
    ]
  end
  let!(:faux_itinerary) do
    FactoryBot.create(:default_itinerary,
      tenant: tenant,
      name: "Gothenburg - Shanghai",
      stops: faux_stops)
  end
end
