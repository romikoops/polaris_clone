# frozen_string_literal: true

require "rails_helper"

module Ledger
  RSpec.describe Rate, type: :model do
    describe "validations" do
      it { expect(FactoryBot.build(:ledger_rate)).to be_valid }

      context "when validity overlaps with another rate for the same routing book" do
        let(:existing_rate) { FactoryBot.create(:ledger_rate) }
        let(:overlapped_validity) do
          start, finish = existing_rate.validity.minmax
          (start - 1)..finish
        end
        let(:rate) do
          FactoryBot.build(:ledger_rate,
            book_routing: existing_rate.book_routing,
            validity: overlapped_validity)
        end

        it "is invalid with proper error text", :aggregate_failures do
          expect(rate).to be_invalid
          expect(rate.errors[:validity]).to eq(["must not be overlapped with other rates for the book routing"])
        end
      end

      context "when validity overlaps with another rate for different routing book" do
        let(:existing_rate) { FactoryBot.create(:ledger_rate) }
        let(:rate) { FactoryBot.build(:ledger_rate, book_routing: existing_rate.book_routing) }

        it { expect(rate).to be_valid }
      end
    end
  end
end
