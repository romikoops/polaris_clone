# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::LocalCharges do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:german_address) { FactoryBot.create(:hamburg_address) }
  let(:belgium) { FactoryBot.create(:legacy_country, code: "BE", name: "Belgium") }
  let(:france) { FactoryBot.create(:legacy_country, code: "FR", name: "France") }
  let!(:hubs) do
    [
      FactoryBot.create(
        :legacy_hub,
        organization: organization,
        name: "Bremerhaven",
        nexus: FactoryBot.create(
          :legacy_nexus,
          organization: organization,
          name: "Bremerhaven",
          locode: "DEBRV",
          country: german_address.country
        ),
        hub_type: "ocean",
        address: german_address
      ),
      FactoryBot.create(
        :legacy_hub,
        organization: organization,
        name: "Antwerp",
        hub_code: "BEANR",
        hub_type: "ocean",
        nexus: FactoryBot.create(:legacy_nexus,
          organization: organization,
          name: "Antwerp",
          locode: "BEANR",
          country: belgium),
        address: FactoryBot.create(:legacy_address,
          country: belgium)
      ),
      FactoryBot.create(:legacy_hub,
        organization: organization,
        name: "Le Havre",
        nexus: FactoryBot.create(:legacy_nexus,
          organization: organization,
          name: "Le Havre",
          locode: "FRLEH",
          country: france),
        hub_type: "ocean",
        address: FactoryBot.create(:legacy_address,
          country: france))
    ]
  end
  # rubocop:disable Rails/SkipsModelValidations
  let(:stats) { described_class.insert({ organization: organization, data: input_data, options: {} }) }
  # rubocop:enable Rails/SkipsModelValidations
  let(:input_data) { FactoryBot.build(:excel_data_restructured_correct_local_charges) }
  let!(:tenant_vehicles) do
    [
      FactoryBot.create(:legacy_tenant_vehicle,
        organization: organization,
        carrier: FactoryBot.create(:legacy_carrier, code: "saco shipping", name: "SACO Shipping")),
      FactoryBot.create(:legacy_tenant_vehicle,
        organization: organization,
        carrier: FactoryBot.create(:legacy_carrier, code: "msc", name: "MSC"))
    ]
  end

  before do
    FactoryBot.create(:groups_group, :default, organization: organization)
    FactoryBot.create(:routing_carrier, code: "msc", name: "MSC")
  end

  describe ".insert" do
    before do
      FactoryBot.create(
        :legacy_local_charge,
        mode_of_transport: "ocean",
        load_type: "lcl",
        hub: hubs.first,
        organization: organization,
        tenant_vehicle: tenant_vehicles.first,
        counterpart_hub_id: nil,
        direction: "export",
        fees: {
          "DOC" => { "key" => "DOC", "max" => nil, "min" => nil, "base" => nil,
                     "name" => "Documentation", "value" => 20, "currency" => "EUR",
                     "rate_basis" => "PER_BILL" }
        },
        dangerous: nil,
        effective_date: Date.parse("Thu, 24 Jan 2019"),
        expiration_date: Date.parse("Fri, 24 Jan 2020"),
      )
      FactoryBot.create(
        :legacy_local_charge,
        mode_of_transport: "ocean",
        load_type: "lcl",
        hub: hubs.first,
        organization: organization,
        tenant_vehicle: tenant_vehicles.first,
        counterpart_hub_id: nil,
        direction: "export",
        fees: {
          "DOC" => { "key" => "DOC", "max" => nil, "min" => nil, "base" => nil,
                     "name" => "Documentation", "value" => 20, "currency" => "EUR",
                     "rate_basis" => "PER_BILL" }
        },
        dangerous: nil,
        effective_date: Date.parse("1 Jan 2019"),
        expiration_date: Date.parse("23 Jan 2019"),
        user_id: nil
      )
    end

    let(:input_data) { FactoryBot.build(:excel_data_restructured_correct_local_charges) }
    let(:expected_stats) do
      { 'legacy/local_charges': { number_created: 8, number_updated: 0, number_deleted: 5 }, errors: [] }
    end
    let(:expected_partial_db_data) do
      [
        {
          effective_date: DateTime.parse("Thu, 24 Jan 2019 00:00:00"),
          expiration_date: DateTime.parse("Fri, 24 Jan 2020 23:59:59"),
          mode_of_transport: "ocean",
          load_type: "lcl",
          direction: "export",
          fees: { "DOC" => {
            "key" => "DOC", "max" => nil, "min" => nil, "base" => nil,
            "name" => "Documentation", "value" => 20, "currency" => "EUR",
            "rate_basis" => "PER_BILL"
          } },
          counterpart_hub_name: nil
        },
        {
          effective_date: DateTime.parse("Thu, 24 Jan 2019 00:00:00"),
          expiration_date: DateTime.parse("Fri, 24 Jan 2020 23:59:59"),
          mode_of_transport: "ocean",
          load_type: "lcl",
          direction: "export",
          fees: { "DOC" => {
            "key" => "DOC", "max" => nil, "min" => nil, "base" => nil,
            "name" => "Documentation", "range" => [{ "max" => 100, "min" => 0,
                                                     "value" => 20, "currency" => "EUR" }], "currency" => "EUR",
            "rate_basis" => "PER_BILL"
          } },
          counterpart_hub_name: nil
        },
        {
          effective_date: DateTime.parse("Thu, 24 Jan 2019 00:00:00"),
          expiration_date: DateTime.parse("Fri, 24 Jan 2020 23:59:59"),
          mode_of_transport: "ocean",
          load_type: "lcl",
          direction: "export",
          fees: { "DOC" => {
            "key" => "DOC", "max" => nil, "min" => nil, "base" => nil,
            "name" => "Documentation", "value" => 20, "currency" => "EUR",
            "rate_basis" => "PER_BILL"
          } },
          counterpart_hub_name: "Antwerp"
        },
        {
          effective_date: DateTime.parse("Thu, 24 Jan 2019 00:00:00"),
          expiration_date: DateTime.parse("Fri, 24 Jan 2020 23:59:59"),
          mode_of_transport: "ocean",
          load_type: "lcl",
          hub: hubs.first,
          organization: organization,
          tenant_vehicle: tenant_vehicles.first,
          counterpart_hub_id: nil,
          direction: "export",
          fees: { "DOC" => {
            "key" => "DOC", "max" => nil, "min" => nil, "base" => nil,
            "name" => "Documentation", "value" => 20, "currency" => "EUR",
            "rate_basis" => "PER_BILL"
          } },
          counterpart_hub_name: "Antwerp"
        }
      ]
    end
    let(:result_partial_db_data) do
      ::Legacy::LocalCharge.includes(:counterpart_hub).map do |local_charge|
        local_charge.slice(
          :effective_date,
          :expiration_date,
          :mode_of_transport,
          :load_type,
          :direction,
          :fees
        ).merge(counterpart_hub_name: local_charge.counterpart_hub&.name)
      end
      let(:expected_partial_db_data) do
        [
          {
            effective_date: DateTime.parse("Thu, 24 Jan 2019 00:00:00"),
            expiration_date: DateTime.parse("Fri, 24 Jan 2020 23:59:59"),
            mode_of_transport: "ocean",
            load_type: "lcl",
            direction: "export",
            fees: { "DOC" => {
              "key" => "DOC", "max" => nil, "min" => nil,
              "name" => "Documentation", "value" => 20, "currency" => "EUR",
              "rate_basis" => "PER_BILL"
            } },
            counterpart_hub_name: nil
          },
          {
            effective_date: DateTime.parse("Thu, 24 Jan 2019 00:00:00"),
            expiration_date: DateTime.parse("Fri, 24 Jan 2020 23:59:59"),
            mode_of_transport: "ocean",
            load_type: "lcl",
            direction: "export",
            fees: { "DOC" => {
              "key" => "DOC", "max" => nil, "min" => nil,
              "name" => "Documentation", "range" => [{ "max" => 100, "min" => 0,
                                                       "value" => 20, "currency" => "EUR" }], "currency" => "EUR",
              "rate_basis" => "PER_BILL"
            } },
            counterpart_hub_name: nil
          },
          {
            effective_date: DateTime.parse("Thu, 24 Jan 2019 00:00:00"),
            expiration_date: DateTime.parse("Fri, 24 Jan 2020 23:59:59"),
            mode_of_transport: "ocean",
            load_type: "lcl",
            direction: "export",
            fees: { "DOC" => {
              "key" => "DOC", "max" => nil, "min" => nil,
              "name" => "Documentation", "value" => 20, "currency" => "EUR",
              "rate_basis" => "PER_BILL"
            } },
            counterpart_hub_name: "Antwerp"
          },
          {
            effective_date: DateTime.parse("Thu, 24 Jan 2019 00:00:00"),
            expiration_date: DateTime.parse("Fri, 24 Jan 2020 23:59:59"),
            mode_of_transport: "ocean",
            load_type: "lcl",
            direction: "export",
            fees: { "DOC" => {
              "key" => "DOC", "max" => nil, "min" => nil,
              "name" => "Documentation", "value" => 20, "currency" => "EUR",
              "rate_basis" => "PER_BILL"
            } },
            counterpart_hub_name: "Antwerp"
          }
        ]
      end
      let(:result_partial_db_data) do
        ::Legacy::LocalCharge.includes(:counterpart_hub).map do |local_charge|
          local_charge.slice(
            :effective_date,
            :expiration_date,
            :mode_of_transport,
            :load_type,
            :direction,
            :fees
          ).merge(counterpart_hub_name: local_charge.counterpart_hub&.name)
        end
      end

      aggregate_failures do
        expect(result_partial_db_data).to match_array(expected_partial_db_data)
      end
    end

    context "when creating Legacy and Routing Carrier's in tandem" do
      before { stats }

      it "ensures there is a Routing::Carrier for every Legacy::Carrier" do
        expect(Routing::Carrier.all.pluck(:code)).to match_array(Legacy::Carrier.all.pluck(:code))
      end
    end
  end
end
