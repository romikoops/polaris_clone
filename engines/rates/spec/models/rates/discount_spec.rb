# frozen_string_literal: true
require "rails_helper"

module Rates
  RSpec.describe Discount, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:rates_discount)).to be_valid
    end
  end
end
