# frozen_string_literal: true

require "rails_helper"

RSpec.describe Locations::Name, type: :model do
  context "validations" do
    it "is valid with valid attributes" do
      expect(FactoryBot.build(:locations_name)).to be_valid
    end
  end
end
