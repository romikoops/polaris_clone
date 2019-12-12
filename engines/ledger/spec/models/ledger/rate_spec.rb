# frozen_string_literal: true

require 'rails_helper'

module Ledger
  RSpec.describe Rate, type: :model do
    it 'builds a valid object' do
      expect(FactoryBot.build(:ledger_rate)).to be_valid
    end
  end
end
