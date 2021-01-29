# frozen_string_literal: true

RSpec.shared_context "with standard trucking setup" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:xlsx) { instance_double("xlsx") }
  let(:hub) { FactoryBot.create(:legacy_hub, organization: organization, country: country) }
  let(:tenant_vehicle) do
    FactoryBot.create(:legacy_tenant_vehicle,
      organization: organization,
      carrier: carrier,
      mode_of_transport: "truck_carriage")
  end
  let(:carrier_name) { "SACO" }
  let(:carrier) { FactoryBot.create(:legacy_carrier, code: carrier_name.downcase, name: carrier_name) }
  let(:group_id) { nil }
  let(:arguments) do
    {
      applicable: hub,
      group_id: group_id,
      organization_id: organization.id
    }
  end
  let(:frame) { nil }
  let(:parent_arguments) do
    ExcelDataServices::DataFrames::Runners::State.new(
      file: trucking_file,
      errors: [],
      hub_id: hub.id,
      group_id: group_id,
      organization_id: organization.id
    )
  end
  let(:combinator_arguments) do
    ExcelDataServices::DataFrames::Combinators::State.new(
      schema: target_schema,
      errors: [],
      frame: frame,
      hub_id: hub.id,
      group_id: group_id,
      organization_id: organization.id
    )
  end
  let(:cargo_class) { "lcl" }
  let(:load_type) { "cargo_item" }
  let(:carriage) { "pre" }
  let(:country_code) { "GB" }
  let(:country) { factory_country_from_code(code: country_code) }
  let!(:default_group) { FactoryBot.create(:groups_group, organization: organization, name: "default") }
end
