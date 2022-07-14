# frozen_string_literal: true

require "rails_helper"

module Ledger
  RSpec.describe CurrentBook, type: :model do
    describe "validations" do
      it { expect(FactoryBot.build(:ledger_current_book)).to be_valid }
    end
  end
end
