# frozen_string_literal: true

require "rails_helper"

module Ledger
  RSpec.describe Conflict, type: :model do
    describe "validations" do
      it { expect(FactoryBot.build(:ledger_conflict)).to be_valid }
      it { expect(FactoryBot.build(:ledger_conflict, :with_merged_rate)).to be_valid }
    end
  end
end
