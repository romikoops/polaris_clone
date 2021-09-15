# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Loaders::LegacyUploader do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:uploader) do
    described_class.new(
      organization: organization,
      file_or_path: xlsx
    )
  end
  let(:xlsx) { file_fixture("dummy.xlsx") }
  let(:results) { uploader.perform }

  describe "#perform" do
    context "when the uploader performs correctly" do
      let(:header_validator) { instance_double("HeaderChecker") }
      let(:flavor_based_validator_klass) { instance_double("FlavorBasedValidator") }
      let(:flavor_based_validator) { instance_double("FlavorBasedValidator") }
      let(:inserter_klass) { instance_double("Inserter") }
      let(:type_validator_class) { class_double(ExcelDataServices::Validators::TypeValidity::Base) }
      let(:type_validator_instance) { instance_double(ExcelDataServices::Validators::TypeValidity::Base) }

      before do
        allow(ExcelDataServices::Validators::TypeValidity::Base).to receive(:get).and_return(type_validator_class)
        allow(type_validator_class).to receive(:new).and_return(type_validator_instance)
        allow(type_validator_instance).to receive(:type_errors).and_return([])
        allow(ExcelDataServices::Validators::HeaderChecker).to receive(:new).twice.and_return(header_validator)
        allow(header_validator).to receive(:perform).twice
        allow(header_validator).to receive(:valid?).twice.and_return(true)
        allow(header_validator).to receive(:valid?).twice.and_return(true)
        allow(header_validator).to receive(:restructurer_name).twice.and_return("")
        allow(ExcelDataServices::FileParser).to receive(:parse).and_return([{ sheet_name: "DummySheet" }])
        allow(ExcelDataServices::Restructurers::Base).to receive(:restructure).and_return(DummyInsertionType: [])
        allow(ExcelDataServices::Validators::Base).to receive(:get)
          .exactly(3).times.and_return(flavor_based_validator_klass)
        allow(flavor_based_validator_klass).to receive(:new).exactly(3).times.and_return(flavor_based_validator)
        allow(flavor_based_validator).to receive(:perform).exactly(3).times
        allow(flavor_based_validator).to receive(:valid?).exactly(3).times.and_return(true)
        allow(ExcelDataServices::Inserters::Base).to receive(:get).and_return(inserter_klass)
        allow(inserter_klass).to receive(:insert).and_return({})
        allow(uploader).to receive(:valid_excel_filetype?).and_return(true)
      end

      it "reads the excel file in and calls the correct methods." do
        expect(results.count).to eq(0)
      end
    end

    context "with an incorrect filetype" do
      let(:header_validator) { instance_double("HeaderChecker") }
      let(:flavor_based_validator_klass) { instance_double("FlavorBasedValidator") }
      let(:flavor_based_validator) { instance_double("FlavorBasedValidator") }
      let(:inserter_klass) { instance_double("Inserter") }
      let(:type_validator_class) { class_double(ExcelDataServices::Validators::TypeValidity::Base) }
      let(:type_validator_instance) { instance_double(ExcelDataServices::Validators::TypeValidity::Base) }
      let(:expected_errors) do
        [{
          type: :error,
          row_nr: 1,
          sheet_name: "",
          reason: "The file uploaded was of an unsupported file type. Please use .xlsx or .xls filetypes.",
          exception_class: ExcelDataServices::Validators::ValidationErrors::UnsupportedFiletype
        }]
      end

      before do
        allow(MimeMagic).to receive(:by_magic).and_return(nil)
        allow(MimeMagic).to receive(:by_path).and_return(nil)
      end

      it "reads the excel file in and calls the correct methods." do
        expect(results[:errors]).to eq(expected_errors)
      end
    end

    context "when it is a trucking file" do
      let(:xlsx) { File.open(file_fixture("excel/example_trucking.xlsx")) }

      before do
        allow(ExcelDataServices::DataFrames::Runners::Blocks).to receive(:run).and_return(true)
        uploader.perform
      end

      it "detects the file type and triggers the Trucking Uploader" do
        expect(ExcelDataServices::DataFrames::Runners::Blocks).to have_received(:run)
      end
    end
  end
end
