# frozen_string_literal: true

require "rails_helper"

module Ledger
  RSpec.describe Upload, type: :model do
    describe "validations" do
      it { expect(FactoryBot.build(:ledger_upload)).to be_valid }

      context "when blank processing errors" do
        let(:upload) { FactoryBot.build(:ledger_upload, processing_errors: nil) }

        it { expect(upload).to be_valid }
      end

      context "when processing errors present" do
        context "when match schema" do
          let(:upload) { FactoryBot.build(:ledger_upload, :with_processing_errors) }

          it { expect(upload).to be_valid }
        end

        context "when does not match schema" do
          let(:incorrect_errors) { { reason: "some reason" } }
          let(:upload) { FactoryBot.build(:ledger_upload, processing_errors: incorrect_errors) }

          it "is invalid with proper error text", :aggregate_failures do
            expect(upload).to be_invalid
            expect(upload.errors[:processing_errors]).to eq(["invalid json"])
          end
        end
      end
    end
  end
end
