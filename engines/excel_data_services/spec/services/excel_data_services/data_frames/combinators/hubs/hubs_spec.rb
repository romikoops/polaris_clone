# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Combinators::Hubs::Hubs do
  include_context "with hubs_sheet"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:parent_arguments) do
    ExcelDataServices::DataFrames::Runners::State.new(
      file: hub_file,
      errors: [],
      organization_id: organization.id
    )
  end
  let(:hub_file) { FactoryBot.build(:schemas_file_hubs) }
  let(:hub) do
    FactoryBot.build(:legacy_hub,
      :hamburg,
      organization: organization,
      mandatory_charge: mandatory_charge,
      address: address,
      nexus: nexus)
  end
  let(:hubs) { [hub] }
  let(:mandatory_charge) { FactoryBot.create(:legacy_mandatory_charge) }
  let(:address) { FactoryBot.create(:legacy_address) }
  let(:nexus) { FactoryBot.create(:legacy_nexus, :deham, organization: organization) }
  let(:expected_result) do
    [{ "nexus_id" => nexus.id,
       "locode" => hub.hub_code,
       "mandatory_charge_id" => mandatory_charge.id,
       "import_charges" => mandatory_charge.import_charges,
       "export_charges" => mandatory_charge.export_charges,
       "pre_carriage" => mandatory_charge.pre_carriage,
       "on_carriage" => mandatory_charge.on_carriage,
       "status" => hub.hub_status,
       "type" => hub.hub_type,
       "name" => hub.name,
       "terminal" => hub.terminal,
       "terminal_code" => hub.terminal_code,
       "latitude" => hub.latitude,
       "longitude" => hub.longitude,
       "country" => address.country.name,
       "full_address" => address.geocoded_address,
       "free_out" => hub.free_out,
       "alternative_names" => "",
       "address_id" => address.id }]
  end

  before do
    Organizations.current_id = organization.id
    allow(hub_file).to receive(:valid?).and_return(true)
    allow(hub_schema).to receive(:valid?).and_return(true)
    allow(hub_file).to receive(:schema).and_return(hub_schema)
    allow(Legacy::Address).to receive(:new).with(
      latitude: hub.latitude,
      longitude: hub.longitude,
      geocoded_address: address.geocoded_address
    )
      .and_return(address)
    allow(address).to receive(:reverse_geocode).and_return(nil)
  end

  describe ".frame" do
    let!(:result) { described_class.state(coordinator_state: parent_arguments) }

    it "returns successfully" do
      expect(result.frame.to_a).to eq(expected_result)
    end
  end
end
