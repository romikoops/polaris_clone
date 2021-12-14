# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::EmailType do
  describe ".valid?" do
    it "returns true when the email matches the regex" do
      expect(described_class.new("user1@itsmycargo.test")).to be_valid
    end

    it "returns false when the email does not match the regex" do
      expect(described_class.new("user1")).not_to be_valid
    end

    it "returns false when the value provided is not a String" do
      expect(described_class.new(123)).not_to be_valid
    end
  end
end
