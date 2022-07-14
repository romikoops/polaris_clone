# frozen_string_literal: true

require "rails_helper"

module Ledger
  RSpec.describe BookRouting, type: :model do
    describe "validations" do
      it { expect(FactoryBot.build(:ledger_staged_book_routing)).to be_valid }
      it { expect(FactoryBot.build(:ledger_merged_book_routing)).to be_valid }
    end
  end
end
