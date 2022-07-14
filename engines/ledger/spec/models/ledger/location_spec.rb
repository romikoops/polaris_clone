# frozen_string_literal: true

require "rails_helper"

module Ledger
  RSpec.describe Location, type: :model do
    describe "validations" do
      it { expect(FactoryBot.build(:ledger_location)).to be_valid }
      it { expect(FactoryBot.build(:ledger_location, :named)).to be_valid }

      context "when country with unknown code" do
        let(:location) { FactoryBot.build(:ledger_location, :named, country: "Unknown") }

        it "is invalid with proper error text", :aggregate_failures do
          expect(location).to be_invalid
          expect(location.errors[:country]).to eq(["is not included in the list"])
        end
      end

      context "when country without region" do
        let(:location) { FactoryBot.build(:ledger_location, :named, region: nil) }

        it "is invalid with proper error text", :aggregate_failures do
          expect(location).to be_invalid
          expect(location.errors[:region]).to eq(["can't be blank"])
        end
      end

      context "when region without country" do
        let(:location) { FactoryBot.build(:ledger_location, :named, country: nil) }

        it "is invalid with proper error text", :aggregate_failures do
          expect(location).to be_invalid
          expect(location.errors[:country]).to eq(["can't be blank"])
        end
      end

      context "when region with unknown code" do
        let(:location) { FactoryBot.build(:ledger_location, :named, region: "Unknown") }

        it "is invalid with proper error text", :aggregate_failures do
          expect(location).to be_invalid
          expect(location.errors[:region]).to eq(["unknown region ('Unknown') for the country ('DE')"])
        end
      end

      context "when region does not belong to country" do
        let(:location) { FactoryBot.build(:ledger_location, :named, country: "NL", region: "BB") }

        it "is invalid with proper error text", :aggregate_failures do
          expect(location).to be_invalid
          expect(location.errors[:region]).to eq(["unknown region ('BB') for the country ('NL')"])
        end
      end
    end
  end
end
