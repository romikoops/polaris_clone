# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Files::Section do
  include_context "for excel_data_services setup"

  let(:service) { described_class.new(state: state_arguments) }
  let(:sheet_name) { xlsx.sheets.first }
  let(:result_state) { service.perform }
  let(:section_string) { "SacoPricings" }
  let(:xlsx) { File.open(file_fixture("excel/example_saco_pricings.xlsx")) }

  before do
    Organizations.current_id = organization.id
  end

  describe "#valid?" do
    it "returns successfully" do
      expect(service.valid?).to eq(true)
    end
  end

  describe "#perform" do
    Timecop.freeze(DateTime.parse("2021/08/31")) do
      let(:result_state) { service.perform }
      let(:lobito_antwerp) { Legacy::Itinerary.find_by(name: "BEANR - Lobito", transshipment: "AOLAD") }
      let(:lobito_hamburg) { Legacy::Itinerary.find_by(name: "DEHAM - Lobito") }
      let(:msc_service) { Legacy::TenantVehicle.joins(:carrier).find_by(name: "standard", carriers: { code: "msc" }) }
      let(:cabinda_hamburg) { Legacy::Itinerary.find_by(name: "DEHAM - Cabinda", transshipment: "CGPNR") }
      let(:expected_validities) do
        [
          Range.new(Date.parse("2021/09/01"), Date.parse("2021/10/01"), exclude_end: true),
          Range.new(Date.parse("2021/10/01"), Date.parse("2021/11/01"), exclude_end: true),
          Range.new(Date.parse("2021/11/01"), Date.parse("2021/12/01"), exclude_end: true)
        ]
      end
      let(:september_pricings) { Pricings::Pricing.for_dates(DateTime.parse("2021/09/15"), DateTime.parse("2021/09/25")) }
      let(:october_pricings) { Pricings::Pricing.for_dates(DateTime.parse("2021/10/15"), DateTime.parse("2021/10/25")) }

      before do
        angola = FactoryBot.create(:legacy_country, code: "AO", name: "Angola")
        %w[DEHAM BEANR DEBRV NLRTM].each do |locode|
          FactoryBot.create(:legacy_hub, name: locode, hub_code: locode, nexus: FactoryBot.build(:legacy_nexus, name: locode, locode: locode, organization: organization), organization: organization)
        end
        FactoryBot.create(:legacy_hub, name: "Cabinda", hub_code: "AOCAB", nexus: FactoryBot.build(:legacy_nexus, name: "Cabinda", locode: "AOCAB", country: angola, organization: organization), organization: organization)
        FactoryBot.create(:legacy_hub, name: "Lobito", hub_code: "AOLOB", nexus: FactoryBot.build(:legacy_nexus, name: "Lobito", locode: "AOLOB", country: angola, organization: organization), organization: organization)
        FactoryBot.create(:pricings_rate_basis, external_code: "PER_WM")
        FactoryBot.create(:pricings_rate_basis, external_code: "PER_CONTAINER")
        result_state
      end

      it "returns a State object after inserting Data" do
        expect(result_state).to be_a(ExcelDataServices::V2::State)
      end

      it "inserted the correct amount of data", :aggregate_failures do
        expect(Pricings::Pricing.where(cargo_class: "fcl_20").count).to eq(14)
        expect(Pricings::Pricing.where(cargo_class: "fcl_40").count).to eq(14)
        expect(Pricings::Pricing.where(cargo_class: "fcl_40_hq").count).to eq(14)
        expect(Legacy::Itinerary.count).to eq(9)
        expect(Legacy::Carrier.count).to eq(3)
      end

      it "assigns the pricings from the internal row `internal: true`" do
        expect(lobito_hamburg.rates.where(tenant_vehicle: msc_service).pluck(:internal).uniq).to eq([true])
      end

      it "excludes fees designated (NEXT_MONTH) outside of the defined validity period", :aggregate_failures do
        expect(october_pricings.where(itinerary: cabinda_hamburg)).to be_empty
        expect(september_pricings.where(itinerary: cabinda_hamburg).find_by(cargo_class: "fcl_20").fees.joins(:charge_category).find_by(charge_categories: { code: "included_baf" })).to be_present
      end

      it "splits the rates up into three validity periods with correct values", :aggregate_failures do
        expect(lobito_antwerp.rates.pluck(:validity).uniq).to match_array(expected_validities)
        expect(september_pricings.where(itinerary: lobito_antwerp).find_by(cargo_class: "fcl_20").fees.joins(:charge_category).find_by(charge_categories: { code: "baf" }).rate).to eq(235)
        expect(october_pricings.where(itinerary: lobito_antwerp).find_by(cargo_class: "fcl_20").fees.joins(:charge_category).find_by(charge_categories: { code: "baf" }).rate).to eq(255)
        expect(october_pricings.where(itinerary: lobito_antwerp).find_by(cargo_class: "fcl_20").fees.joins(:charge_category).find_by(charge_categories: { code: "baf" }).currency_name).to eq("EUR")
      end

      it "duplicates rates with only the fee code in the header to all time frames and cargo classes", :aggregate_failures do
        expect(Pricings::Fee.joins(:charge_category).where(pricing: lobito_antwerp.rates, charge_categories: { code: "isps" }).count).to eq 9
        expect(september_pricings.where(itinerary: lobito_antwerp).find_by(cargo_class: "fcl_20").fees.joins(:charge_category).find_by(charge_categories: { code: "isps" }).rate).to eq(29)
        expect(october_pricings.where(itinerary: lobito_antwerp).find_by(cargo_class: "fcl_40").fees.joins(:charge_category).find_by(charge_categories: { code: "isps" }).rate).to eq(29)
        expect(october_pricings.where(itinerary: lobito_antwerp).find_by(cargo_class: "fcl_40_hq").fees.joins(:charge_category).find_by(charge_categories: { code: "isps" }).rate).to eq(29)
      end

      it "dynamically add the included prefix on rates sourced from cell with 'incl'" do
        expect(september_pricings.where(itinerary: cabinda_hamburg).find_by(cargo_class: "fcl_20").fees.joins(:charge_category).find_by(charge_categories: { code: "included_baf" }).rate).to eq(0)
      end

      it "dynamically generates a note that is added to the pricing" do
        expect(september_pricings.where(itinerary: cabinda_hamburg).find_by(cargo_class: "fcl_20").notes.count).to eq(2)
      end

      context "when the sheet has errors" do
        let(:xlsx) { File.open(file_fixture("excel/example_pricings.xlsx")) }

        it "collates the errors in the 'errors' object and exits" do
          expect(result_state.errors.map(&:reason)).to include("Required data is missing in column: destination_locode. Please fill in the missing data and try again.")
        end
      end
    end
  end
end
