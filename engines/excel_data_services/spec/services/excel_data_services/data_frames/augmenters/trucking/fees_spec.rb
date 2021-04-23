# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Augmenters::Trucking::Fees do
  include_context "with standard trucking setup"
  include_context "with trucking_fees_sheet"

  before do
    Organizations.current_id = organization.id
  end

  describe ".frame" do
    let!(:result) { described_class.state(state: trucking_fees_state) }

    it "creates the charge_categories" do
      expect(Legacy::ChargeCategory.exists?(organization: organization, code: "fsc")).to be_present
    end

    it "removes the sheet_name" do
      expect(result.frame).to include("sheet_name")
    end
  end
end
