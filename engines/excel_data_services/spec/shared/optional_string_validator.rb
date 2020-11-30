# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "optional_string validator", type: :service do
    let(:exception) { ExcelDataServices::Validators::ValidationErrors::TypeValidity::OptionalStringType }

    context "with valid string input" do
      let(:optional_string_value) { "Fee Label" }

      it_behaves_like "passing validator"
    end

    context "with invalid float input" do
      let(:optional_string_value) { 1.0 }

      it_behaves_like "failing validator"
    end

    context "with invalid integer input" do
      let(:optional_string_value) { 1 }

      it_behaves_like "failing validator"
    end

    context "with valid nil inputs" do
      let(:optional_string_value) { nil }

      it_behaves_like "passing validator"
    end
  end
end
