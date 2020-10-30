# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "failing validator" do
    it "returns the validation errors", :aggregate_failures do
      expect(errors).not_to be_empty
      expect(errors.first[:exception_class]).to eq(exception)
    end
  end
end
