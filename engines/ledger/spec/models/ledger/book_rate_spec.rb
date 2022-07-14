# frozen_string_literal: true

require "rails_helper"

module Ledger
  RSpec.describe BookRate, type: :model do
    describe "validations" do
      it { expect(FactoryBot.build(:ledger_book_rate)).to be_valid }
    end
  end
end
