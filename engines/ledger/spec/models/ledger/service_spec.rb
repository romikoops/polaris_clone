# frozen_string_literal: true

require "rails_helper"

module Ledger
  RSpec.describe Service, type: :model do
    describe "validations" do
      it { expect(FactoryBot.build(:ledger_service)).to be_valid }
    end
  end
end
