# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Restructurers::MaxDimensions do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { {organization: organization, data: input_data} }

  before do
    FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization)
  end

  describe ".restructure" do
    let(:input_data) { FactoryBot.build(:excel_data_parsed_correct_max_dimensions).first }
    let(:output_data) { {"MaxDimensions" => FactoryBot.build(:excel_data_restructured_max_dimensions)} }

    it "restructures the data correctly" do
      expect(described_class.restructure(options)).to eq(output_data)
    end
  end
end
