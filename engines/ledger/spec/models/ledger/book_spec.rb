# frozen_string_literal: true

require "rails_helper"

module Ledger
  RSpec.describe Book, type: :model do
    describe "validations" do
      it { expect(FactoryBot.build(:ledger_book)).to be_valid }
      it { expect(FactoryBot.build(:ledger_book, :with_basis_book)).to be_valid }

      context "when basis book is current book" do
        let(:book) do
          FactoryBot.create(:ledger_book).tap { |book| book.basis_book = book }
        end

        it "is invalid with proper error text", :aggregate_failures do
          expect(book).to be_invalid
          expect(book.errors[:basis_book_id]).to eq(["must be different with the book id"])
        end
      end
    end
  end
end
