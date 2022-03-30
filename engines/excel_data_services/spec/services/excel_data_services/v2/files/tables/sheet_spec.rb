# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Files::Tables::Sheet, skip: "Deprecated in Favour of V3" do
  include_context "for excel_data_services setup"

  let(:service) { described_class.new(section: section, sheet_name: sheet_name) }
  let(:section) { ExcelDataServices::V2::Files::Section.new(state: state_arguments) }
  let(:sheet_name) { "Sheet1" }
  let(:result_frame) { service.perform }

  before do
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    let(:carrier) { Legacy::Carrier.find_by(name: "MSC", code: "msc") }
    let(:sheet_results) do
      expected_results.to_a.select { |row| row["sheet_name"] == sheet_name }
        .map { |row| row.slice(*(section_keys | %w[row sheet_name organization_id])) }
    end

    shared_examples_for "#perform" do
      it "returns a DataFrame of extracted values for the sheet in question", :aggregate_failures do
        expect(result_frame).to be_a(Rover::DataFrame)
        expect(result_frame.to_a).to match_array(sheet_results)
      end
    end

    context "when section is ChargeCategory" do
      let(:section_string) { "ChargeCategory" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :charge_categories, organization: organization, default_group: default_group) }
      let(:section_keys) { %w[fee_name fee_code] }

      it_behaves_like "#perform"
    end

    context "when section is TenantVehicle" do
      let(:section_string) { "TenantVehicle" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :tenant_vehicles, organization: organization, default_group: default_group) }
      let(:section_keys) { %w[service carrier carrier_code mode_of_transport] }

      it_behaves_like "#perform"
    end

    context "when section is Carrier" do
      let(:section_string) { "Carrier" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :carriers, organization: organization, default_group: default_group) }
      let(:section_keys) { %w[carrier carrier_code] }

      it_behaves_like "#perform"
    end

    context "when section is Itinerary" do
      let(:section_string) { "Itinerary" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :itineraries, organization: organization, default_group: default_group) }
      let(:section_keys) do
        %w[origin_locode
          origin_terminal
          origin_hub
          origin_country
          destination_locode
          destination_terminal
          destination_hub
          destination_country
          mode_of_transport
          transshipment]
      end

      it_behaves_like "#perform"
    end

    context "when section is Pricings" do
      let(:section_string) { "Pricings" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :pricings, organization: organization, default_group: default_group) }
      let(:section_keys) do
        %w[service
          group_id
          group_name
          effective_date
          expiration_date
          origin_locode
          origin_hub
          origin_country
          destination_locode
          destination_hub
          destination_country
          mode_of_transport
          carrier
          carrier_code
          service_level
          cargo_class
          internal
          transshipment
          wm_rate
          vm_rate
          origin_terminal
          destination_terminal
          fee_name
          fee_code
          fee_min
          currency
          rate
          rate_basis
          range_min
          range_max
          base
          validity
          remarks]
      end

      it_behaves_like "#perform"
    end
  end
end
