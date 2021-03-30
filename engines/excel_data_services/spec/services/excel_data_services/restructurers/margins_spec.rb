# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Restructurers::Margins do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { { organization: organization, data: input_data } }

  describe ".restructure" do
    let(:input_data) { FactoryBot.build(:excel_data_parsed_correct_margins).first }
    let(:output_data) { { "Margins" => FactoryBot.build(:excel_data_restructured_correct_margins) } }

    it "restructures the data correctly" do
      expect(described_class.restructure(options)).to eq(output_data)
    end

    context "when mot is upper_case" do
      let(:input_data) { FactoryBot.build(:excel_data_parsed_upcase_mot_margins).first }

      it "forces downcase for mot and restructures correctly" do
        expect(described_class.restructure(options)).to eq(output_data)
      end
    end
  end
end
