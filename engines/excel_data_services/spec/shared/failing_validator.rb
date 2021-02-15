# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "failing validator" do
    it "returns the validation errors", :aggregate_failures do
      expect(error).to be
      expect(error[:exception_class]).to eq(exception)
    end
  end
end
