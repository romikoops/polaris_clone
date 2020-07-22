require "rails_helper"

module Rates
  RSpec.describe Margin, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:rates_margin)).to be_valid
    end
  end
end
