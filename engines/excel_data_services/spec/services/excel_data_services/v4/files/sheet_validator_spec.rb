# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::SheetValidator do
  include_context "V4 setup"

  let(:service) { described_class.new(state: state_arguments, section_parser: section_parser) }
  let(:section_parser) { instance_double(ExcelDataServices::V4::Files::SectionParser, columns: columns, requirements: requirements) }
  let(:columns) { [instance_double(ExcelDataServices::V4::Files::Tables::Column, required: true, present_on_sheet?: true)] }
  let(:requirements) { [instance_double(ExcelDataServices::V4::Files::Requirement, valid?: true)] }

  describe "#valid?" do
    context "when all Columns are present on the sheet and all requirements are valid?" do
      it "is valid" do
        expect(service).to be_valid
      end
    end

    context "when the required Column cannot be found on the sheet" do
      let(:columns) { [instance_double("ExcelDataServices::V4::Files::Tables::Column", required: true, present_on_sheet?: false)] }

      it "is invalid" do
        expect(service).not_to be_valid
      end
    end

    context "when the Column cannot be found on the sheet, but is not required" do
      let(:columns) { [instance_double("ExcelDataServices::V4::Files::Tables::Column", required: false, present_on_sheet?: false)] }

      it "is valid" do
        expect(service).to be_valid
      end
    end

    context "when the Requirements are not met" do
      let(:requirements) { [instance_double("ExcelDataServices::V4::Files::Requirements", valid?: false)] }

      it "is invalid" do
        expect(service).not_to be_valid
      end
    end

    context "when the Requirements are not met and required Columns are not on the sheet" do
      let(:requirements) { [instance_double("ExcelDataServices::V4::Files::Requirements", valid?: false)] }
      let(:columns) { [instance_double("ExcelDataServices::V4::Files::Tables::Column", required: true, present_on_sheet?: false)] }

      it "is invalid" do
        expect(service).not_to be_valid
      end
    end
  end
end
