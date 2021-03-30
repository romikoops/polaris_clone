# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::InsertableChecks::LocalCharges do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { { organization: organization, sheet_name: "Sheet1", data: input_data } }
  let(:bremen) do
    FactoryBot.create(:legacy_hub,
      name: "Bremerhaven",
      organization: organization,
      nexus: FactoryBot.create(
        :legacy_nexus,
        organization: organization,
        name: "Bremerhaven",
        locode: "DEBRV",
        country: german_address.country
      ),
      address: german_address)
  end
  let!(:hubs) { [bremen] }
  let(:german_address) { FactoryBot.create(:hamburg_address) }
  let!(:local_charges) do
    [
      FactoryBot.create(
        :legacy_local_charge,
        organization: organization,
        hub: hubs.first,
        tenant_vehicle: tenant_vehicle,
        mode_of_transport: "ocean",
        load_type: "lcl",
        counterpart_hub_id: nil,
        direction: "export",
        fees: {
          "CMP" => { "key" => "CMP", "max" => nil, "min" => nil,
                     "name" => "Compliance Fee", "value" => 2.7, "currency" => "EUR",
                     "rate_basis" => "PER_SHIPMENT" },
          "DOC" => { "key" => "DOC", "max" => nil, "min" => nil,
                     "name" => "Documentation", "value" => 20, "currency" => "EUR",
                     "rate_basis" => "PER_BILL" },
          "ISP" => { "key" => "ISP", "max" => nil, "min" => nil,
                     "name" => "ISPS", "value" => 4.5, "currency" => "EUR",
                     "rate_basis" => "PER_SHIPMENT" },
          "QDF" => { "key" => "QDF", "max" => 125, "min" => 55, "ton" => 40,
                     "name" => "Quay dues", "currency" => "EUR",
                     "rate_basis" => "PER_TON" },
          "SOL" => { "key" => "SOL", "max" => nil, "min" => nil, "name" => "SOLAS Fee",
                     "value" => 7.5, "currency" => "EUR",
                     "rate_basis" => "PER_SHIPMENT" },
          "ZAP" => { "key" => "ZAP", "max" => nil, "min" => nil, "name" => "Zapp",
                     "value" => 13, "currency" => "EUR", "rate_basis" => "PER_BILL" }
        },
        dangerous: nil,
        effective_date: Date.parse("Thu, 24 Jan 2019").beginning_of_day,
        expiration_date: Date.parse("Fri, 24 Jan 2020").end_of_day.change(usec: 0)
      )
    ]
  end
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, carrier_id: nil, organization: organization) }

  context "with faulty data" do
    let(:input_data) { FactoryBot.build(:excel_data_restructured_faulty_local_charges) }

    describe ".validate" do
      it "logs the errors" do
        validator = described_class.new(options)
        validator.perform

        expect(validator.results).to eq(
          [{ exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
             reason: 'When the rate basis is "PER_UNIT_TON_CBM_RANGE", there must be '\
            "exactly one value, either for TON or for CBM.",
             row_nr: "2",
             sheet_name: "Sheet1",
             type: :error },
            { exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
              reason: "Overlapping effective period.\n (Old is covered by new: "\
              "[2019-01-24 00:00 - 2020-01-24 23:59] <-> [2019-01-24 00:00 - 2020-01-24 23:59]).",
              row_nr: "2",
              sheet_name: "Sheet1",
              type: :warning },
            { exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
              reason: 'Hub "BremerERRORhaven, Germany" (Ocean) not found!',
              row_nr: "3",
              sheet_name: "Sheet1",
              type: :error }]
        )
      end
    end
  end
end
