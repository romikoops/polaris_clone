# frozen_string_literal: true

require "rails_helper"

module Journey
  RSpec.describe Document, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_document)).to be_valid
    end

    Journey::Document::VALID_CONTENT_TYPES.each do |extension, content_type|
      context "when the file type is #{extension} and valid" do
        let(:valid_file) { Rack::Test::UploadedFile.new(File.expand_path("../../../factories/fixtures/test.txt", __dir__), content_type) }

        it "is invalid when the file type is #{extension}" do
          expect(FactoryBot.create(:journey_document, file: valid_file)).to be_valid
        end
      end
    end

    context "when the file type is invalid" do
      let(:invalid_file) { Rack::Test::UploadedFile.new(File.expand_path("../../../factories/fixtures/test.txt", __dir__), "application/text") }

      it "is invalid when the file type is not one of the approved file types" do
        expect { FactoryBot.create(:journey_document, file: invalid_file) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when the file is not provided" do
      it "is invalid when the file is not present" do
        expect { FactoryBot.create(:journey_document, file: nil) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when the file is too big" do
      # rubocop:disable RSpec/AnyInstance
      before { allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(21.megabytes) }
      # rubocop:enable RSpec/AnyInstance

      it "is invalid when the file is too big" do
        expect { FactoryBot.create(:journey_document) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
