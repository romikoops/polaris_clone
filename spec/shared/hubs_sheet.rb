# frozen_string_literal: true

RSpec.shared_context "with hubs_sheet" do
  let(:hub_schema) do
    FactoryBot.build(:schemas_sheets_hubs)
  end
  let(:hubs_frame) { FactoryBot.build(:hubs_frame, hubs: hubs) }
  let(:hubs) { %i[hamburg shanghai felixstowe gothenburg].map { |trait| FactoryBot.build(:legacy_hub, trait, organization: organization) } }
  let(:hubs_state) do
    ExcelDataServices::DataFrames::Combinators::State.new(
      frame: hubs_frame,
      schema: hub_schema,
      errors: [],
      organization_id: organization.id
    )
  end

  before do
    allow(ExcelDataServices::DataFrames::DataProviders::Hubs::Hubs).to receive(:state).and_return(hubs_state)
    hubs.each do |hub|
      Geocoder::Lookup::Test.add_stub([hub.latitude, hub.longitude], [
        "address_components" => [{ "types" => ["premise"] }],
        "address" => address.geocoded_address,
        "city" => address.city,
        "country" => address.country.name,
        "country_code" => address.country.code,
        "postal_code" => address.zip_code
      ])
    end
  end
end
