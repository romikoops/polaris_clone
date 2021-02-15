# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "passing validator" do
    it "returns no validation errors" do
      expect(error).to be_blank
    end
  end
end
