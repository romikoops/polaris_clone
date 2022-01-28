# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::Section do
  include_context "V3 setup"

  let(:service) { described_class.new(state: state_arguments) }
  let(:sheet_name) { xlsx.sheets.first }
  let(:result_state) { service.perform }
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }

  before do
    Organizations.current_id = organization.id
  end

  describe "#valid?" do
    let(:section_string) { "Pricings" }

    it "returns successfully" do
      expect(service.valid?).to eq(true)
    end
  end

  describe "#data" do
    let(:carrier) { Legacy::Carrier.find_by(name: "MSC", code: "msc") }

    shared_examples_for "returns a DataFrame populated by the columns defined in the configs" do
      it "returns a DataFrame of extracted values" do
        expect(service.data).to match_array(expected_results)
      end
    end

    context "when section is Pricings" do
      let(:section_string) { "Pricings" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :pricings, organization: organization, default_group: default_group) }

      it_behaves_like "returns a DataFrame populated by the columns defined in the configs"
    end
  end
end
