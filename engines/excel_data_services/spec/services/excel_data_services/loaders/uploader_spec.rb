# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Loaders::Uploader do
  let(:organization) { FactoryBot.create(:organizations_organization, scope: FactoryBot.build(:organizations_scope, content: scope_content)) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:scope_content) { Organizations::DEFAULT_SCOPE }
  let(:upload) { FactoryBot.create(:excel_data_services_upload, user: user, file: file, organization: organization) }
  let!(:file) do
    FactoryBot.create(:legacy_file, organization: organization, doc_type: "pricings").tap do |file_object|
      file_object.file.attach(io: xlsx, filename: "test-sheet.xlsx", content_type: "vnd.ms-excel")
    end
  end
  let(:options) { {} }
  let(:v2_uploader) do
    ExcelDataServices::V2::Upload.new(
      file: file,
      arguments: options
    )
  end
  let(:uploader) do
    described_class.new(
      file: file,
      options: options
    )
  end
  let(:dummy_result) do
    { has_errors: false, errors: [] }
  end
  let(:legacy_spy) { instance_double("LegacyUploader", perform: dummy_result) }
  let(:v2_spy) { instance_double("ExcelDataServices::V2::Files::SheetType", valid?: true, perform: dummy_state) }
  let(:dummy_state) { instance_double("ExcelDataServices::V2::State", stats: [stat], errors: []) }
  let(:stat) { FactoryBot.build(:excel_data_services_stats) }

  before do
    Organizations.current_id = organization.id
    FactoryBot.create(:excel_data_services_upload, user: user, file: file, organization: organization)
    allow(ExcelDataServices::V2::Files::SheetType).to receive(:new).and_return(v2_spy)
    allow(ExcelDataServices::Loaders::LegacyUploader).to receive(:new).and_return(legacy_spy)
    uploader.perform
  end

  describe "#perform" do
    shared_examples_for "triggering the V2 upload path" do
      it "calls the perform method of the V2 uploader" do
        expect(v2_spy).to have_received(:perform)
      end
    end

    shared_examples_for "triggering the Legacy upload path" do
      it "calls the perform method of the Legacy uploader" do
        expect(legacy_spy).to have_received(:perform)
      end
    end

    context "when V2 is enabled" do
      context "when it is a Pricings Sheet" do
        let(:xlsx) { File.open(file_fixture("excel/example_pricings.xlsx")) }
        let(:scope_content) { { upload_v2_enabled: true } }

        it_behaves_like "triggering the V2 upload path"
      end
    end

    context "when V2 is not enabled" do
      context "when it is a Pricings Sheet" do
        let(:xlsx) { File.open(file_fixture("excel/example_pricings.xlsx")) }

        it_behaves_like "triggering the Legacy upload path"
      end

      context "when it is a Hub Sheet" do
        let(:xlsx) { File.open(file_fixture("excel/example_hubs.xlsx")) }

        it_behaves_like "triggering the Legacy upload path"
      end
    end
  end
end
