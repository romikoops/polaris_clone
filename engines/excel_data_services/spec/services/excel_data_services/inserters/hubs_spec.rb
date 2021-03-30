# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::Hubs do
  describe ".perform" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:data) do
      [{ original:
         { status: "active",
           type: "ocean",
           name: "Abu Dhabi",
           locode: "AEAUH",
           latitude: 24.806936,
           longitude: 54.644405,
           country: "United Arab Emirates",
           full_address: "Khalifa Port - Abu Dhabi - United Arab Emirates",
           photo: nil,
           free_out: false,
           import_charges: true,
           export_charges: false,
           pre_carriage: false,
           on_carriage: false,
           alternative_names: nil,
           row_nr: 2 },
         address:
         { name: "Abu Dhabi",
           latitude: 24.806936,
           longitude: 54.644405,
           country: { name: "United Arab Emirates" },
           city: "Abu Dhabi",
           geocoded_address: "Khalifa Port - Abu Dhabi - United Arab Emirates" },
         nexus: {
           name: "Abu Dhabi", latitude: 24.806936, longitude: 54.644405, photo: nil,
           locode: "AEAUH", country: { name: "United Arab Emirates" },
           organization_id: organization.id
         },
         mandatory_charge: { pre_carriage: false, on_carriage: false, import_charges: false, export_charges: true },
         hub: {
           organization_id: organization.id,
           hub_type: "ocean",
           latitude: 24.806936,
           longitude: 54.644405,
           name: "Abu Dhabi",
           photo: nil,
           terminal: "ABD",
           terminal_code: "",
           hub_code: "AEAUH"
         } },
        { original:
          { status: "active",
            type: "ocean",
            name: "Adelaide",
            locode: "AUADL",
            latitude: -34.9284989,
            longitude: 138.6007456,
            country: "Australia",
            full_address: "202 Victoria Square, Adelaide SA 5000, Australia",
            photo: nil,
            free_out: false,
            import_charges: true,
            export_charges: false,
            pre_carriage: false,
            on_carriage: false,
            alternative_names: nil,
            row_nr: 3 },
          address:
          { name: "Adelaide",
            latitude: -34.9284989,
            longitude: 138.6007456,
            country: { name: "Australia" },
            city: "Adelaide",
            geocoded_address: "202 Victoria Square, Adelaide SA 5000, Australia" },
          nexus: {
            name: "Adelaide", latitude: -34.9284989, longitude: 138.6007456, photo: nil,
            locode: "AUADL", country: { name: "Australia" },
            organization_id: organization.id
          },
          mandatory_charge: { pre_carriage: false, on_carriage: false,
                              import_charges: true, export_charges: false },
          hub: { organization_id: organization.id, hub_type: "ocean",
                 latitude: -34.9284989, longitude: 138.6007456, name: "Adelaide", photo: nil,
                 hub_code: "AUADL" } }]
    end

    let!(:countries) do
      [
        FactoryBot.create(:legacy_country, name: "Australia", code: "AU"),
        FactoryBot.create(:legacy_country, name: "United Arab Emirates", code: "AE")
      ]
    end
    let!(:mandatory_charges) do
      [
        FactoryBot.create(:legacy_mandatory_charge,
          pre_carriage: false, on_carriage: false, import_charges: true,
          export_charges: false),
        FactoryBot.create(:legacy_mandatory_charge,
          pre_carriage: false, on_carriage: false, import_charges: false,
          export_charges: true)
      ]
    end

    it "creates the correct number of hubs" do
      stats = described_class.insert(organization: organization, data: data, options: {})
      hubs = Legacy::Hub.where(organization_id: organization.id)
      addresses = Legacy::Address.all
      expect(stats.dig(:"legacy/hubs", :number_created)).to eq(2)
      expect(stats.dig(:"legacy/nexuses", :number_created)).to eq(2)
      expect(stats.dig(:"legacy/addresses", :number_created)).to eq(2)
      expect(hubs.count).to eq(2)
      expect(hubs.pluck(:mandatory_charge_id)).to match_array(mandatory_charges.pluck(:id))
      expect(Legacy::Nexus.where(organization_id: organization.id).count).to eq(2)
      expect(addresses.count).to eq(2)
      expect(addresses.map(&:country)).to match_array(countries)
    end

    context "with existing hubs" do
      before do
        FactoryBot.create(:legacy_hub,
          name: "ADL",
          hub_code: "AUADL",
          organization: organization,
          address: FactoryBot.create(:legacy_address, country: countries.first),
          nexus: FactoryBot.create(:legacy_nexus,
            name: "ADL",
            organization: organization,
            locode: "AUADL",
            country: countries.first))
      end

      let(:stats) { described_class.insert(organization: organization, data: data, options: {}) }
      let(:hubs) { Legacy::Hub.where(organization_id: organization.id) }
      let(:addresses) { Legacy::Address.all }

      it "creates the correct number of hubs and updates the rest" do
        aggregate_failures do
          expect(stats.dig(:"legacy/hubs", :number_created)).to eq(1)
          expect(stats.dig(:"legacy/nexuses", :number_created)).to eq(1)
          expect(stats.dig(:"legacy/addresses", :number_created)).to eq(2)
          expect(hubs.count).to eq(2)
          expect(hubs.pluck(:mandatory_charge_id)).to match_array(mandatory_charges.pluck(:id))
          expect(Legacy::Nexus.where(organization_id: organization.id).count).to eq(2)
          expect(addresses.count).to eq(3)
          expect(addresses.map(&:country).uniq).to match_array(countries)
        end
      end
    end

    context "with existing hubs wiht same locode, diff mot" do
      before do
        FactoryBot.create(:legacy_hub,
          name: "Adelaide Airport",
          hub_code: "AUADL",
          hub_type: "air",
          organization: organization,
          address: FactoryBot.create(:legacy_address, country: countries.first),
          nexus: FactoryBot.create(:legacy_nexus,
            name: "ADL",
            organization: organization,
            locode: "AUADL",
            country: countries.first))
      end

      let(:stats) { described_class.insert(organization: organization, data: data, options: {}) }
      let(:hubs) { Legacy::Hub.where(organization_id: organization.id) }
      let(:addresses) { Legacy::Address.all }

      it "creates the correct number of hubs and updates the rest" do
        aggregate_failures do
          expect(stats.dig(:"legacy/hubs", :number_created)).to eq(2)
          expect(stats.dig(:"legacy/nexuses", :number_created)).to eq(1)
          expect(stats.dig(:"legacy/addresses", :number_created)).to eq(2)
          expect(hubs.where(hub_code: "AUADL").count).to eq(2)
          expect(Legacy::Nexus.where(organization_id: organization.id, locode: "AUADL").count).to eq(1)
        end
      end
    end

    context "when uploading with terminals present" do
      let(:data) do
        [{ original:
          { status: "active",
            type: "ocean",
            name: "Abu Dhabi",
            locode: "AEAUH",
            latitude: 24.806936,
            longitude: 54.644405,
            country: "United Arab Emirates",
            full_address: "Khalifa Port - Abu Dhabi - United Arab Emirates",
            photo: nil,
            free_out: false,
            import_charges: true,
            export_charges: false,
            pre_carriage: false,
            on_carriage: false,
            alternative_names: nil,
            terminal: "ABD",
            terminal_code: "",
            row_nr: 2 },
           address:
          { name: "Abu Dhabi",
            latitude: 24.806936,
            longitude: 54.644405,
            country: { name: "United Arab Emirates" },
            city: "Abu Dhabi",
            geocoded_address: "Khalifa Port - Abu Dhabi - United Arab Emirates" },
           nexus: {
             name: "Abu Dhabi", latitude: 24.806936, longitude: 54.644405, photo: nil,
             locode: "AEAUH", country: { name: "United Arab Emirates" },
             organization_id: organization.id
           },
           mandatory_charge: { pre_carriage: false, on_carriage: false, import_charges: false, export_charges: true },
           hub: { organization_id: organization.id,
                  hub_type: "ocean",
                  latitude: 24.806936,
                  longitude: 54.644405,
                  name: "Abu Dhabi",
                  photo: nil,
                  hub_code: "AEAUH",
                  terminal: "ABD",
                  terminal_code: "" } }]
      end

      it "creates the hub with name matching the combined terminal and name" do
        stats = described_class.insert(organization: organization, data: data, options: {})
        aggregate_failures do
          expect(stats.dig(:"legacy/hubs", :number_created)).to eq(1)
          expect(Legacy::Hub.exists?(name: "Abu Dhabi - ABD")).to eq(true)
        end
      end
    end

    context "when inserting sheets with existing hubs (terminal/name) combination" do
      before do
        FactoryBot.create(:legacy_hub,
          name: "Abu Dhabi - ABD",
          hub_code: "AUADL",
          hub_type: "ocean",
          organization: organization,
          address: FactoryBot.create(:legacy_address, country: countries.first),
          nexus: FactoryBot.create(:legacy_nexus,
            name: "ADL",
            organization: organization,
            locode: "AUADL",
            country: countries.first))
        FactoryBot.create(:legacy_hub,
          name: "Abu Dhabi",
          hub_code: "AUADL",
          hub_type: "ocean",
          organization: organization,
          address: FactoryBot.create(:legacy_address, country: countries.first),
          nexus: FactoryBot.create(:legacy_nexus,
            name: "ADL",
            organization: organization,
            locode: "AUADL",
            country: countries.first))
      end

      it "updates hub with the terminal/code combination, ignoring hubs with matching names" do
        stats = described_class.insert(organization: organization, data: data, options: {})
        aggregate_failures do
          expect(stats.dig(:"legacy/hubs", :number_updated)).to eq(2)
          expect(Legacy::Hub.find_by(organization_id: organization.id, name: "Abu Dhabi - ABD").hub_code).to eq("AEAUH")
        end
      end
    end
  end
end
