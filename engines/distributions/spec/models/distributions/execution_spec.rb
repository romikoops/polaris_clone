# frozen_string_literal: true

require "rails_helper"

module Distributions
  RSpec.describe Execution, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:distributions_execution)).to be_valid
    end

    it "is invalid when the file_id is missing" do
      expect(FactoryBot.build(:distributions_execution, file_id: nil)).not_to be_valid
    end
  end
end
