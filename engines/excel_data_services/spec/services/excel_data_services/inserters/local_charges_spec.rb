# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::LocalCharges do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:german_address) { FactoryBot.create(:hamburg_address) }
  let!(:hubs) do
    [FactoryBot.create(:legacy_hub, organization: organization, name: "Bremerhaven", hub_type: "ocean", address: german_address),
      FactoryBot.create(:legacy_hub, organization: organization, name: "Antwerp", hub_type: "ocean",
                                     address: FactoryBot.create(:legacy_address,
                                       country: FactoryBot.create(:legacy_country, code: "BE", name: "Belgium"))),
      FactoryBot.create(:legacy_hub, organization: organization, name: "Le Havre", hub_type: "ocean",
                                     address: FactoryBot.create(:legacy_address, country: FactoryBot.create(:legacy_country, code: "FR", name: "France")))]
  end
  let(:options) { {organization: organization, data: input_data, options: {}} }

  describe ".insert" do
    let!(:carriers) do
      [FactoryBot.create(:legacy_carrier, code: "saco shipping", name: "SACO Shipping"),
        FactoryBot.create(:legacy_carrier, code: "msc", name: "MSC")]
    end
    let!(:tenant_vehicles) do
      [FactoryBot.create(:legacy_tenant_vehicle, organization: organization, carrier: carriers.first),
        FactoryBot.create(:legacy_tenant_vehicle, organization: organization, carrier: carriers.second)]
    end
    let!(:exising_overlapping_local_charge) do
      FactoryBot.create(
        :legacy_local_charge,
        mode_of_transport: "ocean",
        load_type: "lcl",
        hub: hubs.first,
        organization: organization,
        tenant_vehicle: tenant_vehicles.first,
        counterpart_hub_id: nil,
        direction: "export",
        fees: {"DOC" => {"key" => "DOC", "max" => nil, "min" => nil, "name" => "Documentation", "value" => 20, "currency" => "EUR", "rate_basis" => "PER_BILL"}},
        dangerous: nil,
        effective_date: Date.parse("Thu, 24 Jan 2019"),
        expiration_date: Date.parse("Fri, 24 Jan 2020"),
        user_id: nil
      )
    end
    let(:input_data) { FactoryBot.build(:excel_data_restructured_correct_local_charges) }
    let(:expected_stats) do
      {'legacy/local_charges': {number_created: 4, number_updated: 0, number_deleted: 1}, errors: []}
    end
    let(:expected_partial_db_data) do
      [
        [DateTime.parse("Thu, 24 Jan 2019 00:00:00"),
          DateTime.parse("Fri, 24 Jan 2020 23:59:59"),
          "ocean",
          "lcl",
          "export",
          {"DOC" => {"key" => "DOC", "max" => nil, "min" => nil, "name" => "Documentation", "value" => 20, "currency" => "EUR", "rate_basis" => "PER_BILL"}}],
        [DateTime.parse("Thu, 24 Jan 2019 00:00:00"),
          DateTime.parse("Fri, 24 Jan 2020 23:59:59"),
          "ocean",
          "lcl",
          "export",
          {"DOC" => {"key" => "DOC", "max" => nil, "min" => nil, "name" => "Documentation", "range" => [{"max" => 100, "min" => 0, "value" => 20, "currency" => "EUR"}], "currency" => "EUR", "rate_basis" => "PER_BILL"}}],
        [DateTime.parse("Thu, 24 Jan 2019 00:00:00"),
          DateTime.parse("Fri, 24 Jan 2020 23:59:59"),
          "ocean",
          "lcl",
          "export",
          {"DOC" => {"key" => "DOC", "max" => nil, "min" => nil, "name" => "Documentation", "value" => 20, "currency" => "EUR", "rate_basis" => "PER_BILL"}}],
        [DateTime.parse("Thu, 24 Jan 2019 00:00:00"),
          DateTime.parse("Fri, 24 Jan 2020 23:59:59"),
          "ocean",
          "lcl",
          "export",
          {"DOC" => {"key" => "DOC", "max" => nil, "min" => nil, "name" => "Documentation", "value" => 20, "currency" => "EUR", "rate_basis" => "PER_BILL"}}]
      ]
    end

    it "inserts correctly and returns correct stats" do
      stats = described_class.insert(options)

      expect(::Legacy::LocalCharge.all.map { |lc| lc.slice(:effective_date, :expiration_date, :mode_of_transport, :load_type, :direction, :fees).values }).to match_array(expected_partial_db_data)
      expect(stats).to eq(expected_stats)
    end
  end
end
