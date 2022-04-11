# frozen_string_literal: true

require "rails_helper"

module Files
  RSpec.describe FileDescriptor, type: :model do
    let(:file_descriptor) { FactoryBot.build(:file_descriptor) }

    shared_examples_for "invalid record" do
      it "raises `ActiveRecord::RecordInvalid`" do
        expect { file_descriptor.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    it "is valid with valid attributes" do
      expect(file_descriptor).to be_valid
    end

    context "when file_path is empty" do
      let(:file_descriptor) { FactoryBot.build(:file_descriptor, file_path: nil) }

      it_behaves_like "invalid record"
    end

    context "when file_type is empty" do
      let(:file_descriptor) { FactoryBot.build(:file_descriptor, file_type: nil) }

      it_behaves_like "invalid record"
    end

    context "when originator is empty" do
      let(:file_descriptor) { FactoryBot.build(:file_descriptor, originator: nil) }

      it_behaves_like "invalid record"
    end

    context "when status is empty" do
      let(:file_descriptor) { FactoryBot.build(:file_descriptor, status: nil) }

      it_behaves_like "invalid record"

      context "with invalid status" do
        let(:file_descriptor) { FactoryBot.build(:file_descriptor, status: "invalid") }

        it "raises `ArgumentError`" do
          expect { file_descriptor.save! }.to raise_error(ArgumentError)
        end
      end
    end

    context "when source is empty" do
      let(:file_descriptor) { FactoryBot.build(:file_descriptor, source: nil) }

      it_behaves_like "invalid record"
    end
  end
end
