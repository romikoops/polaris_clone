# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "optional_numeric validator", type: :service do
    let(:exception) { ExcelDataServices::Validators::ValidationErrors::TypeValidity::OptionalNumericType }

    context "with valid float input" do
      let(:optional_numeric_value) { 1.0 }

      it_behaves_like "passing validator"
    end

    context "with valid integer input" do
      let(:optional_numeric_value) { 1 }

      it_behaves_like "passing validator"
    end

    context "with invalid string inputs" do
      let(:optional_numeric_value) { "abc" }

      it_behaves_like "failing validator"
    end

    context "with invalid nil inputs" do
      let(:optional_numeric_value) { nil }

      it_behaves_like "passing validator"
    end
  end
end
