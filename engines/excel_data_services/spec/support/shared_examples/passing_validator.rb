# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "passing validator" do
    it "returns no validation errors" do
      expect(errors).to be_empty
    end
  end
end
