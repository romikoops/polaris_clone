# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "numeric validator", type: :service do
    let(:exception) { ExcelDataServices::Validators::ValidationErrors::TypeValidity::NumericType }

    context "with valid float input" do
      let(:rate_value) { 1.0 }

      it_behaves_like "passing validator"
    end

    context "with valid integer input" do
      let(:rate_value) { 1 }

      it_behaves_like "passing validator"
    end

    context "with invalid string inputs" do
      let(:rate_value) { "abc" }

      it_behaves_like "failing validator"
    end

    context "with invalid nil inputs" do
      let(:rate_value) { nil }

      it_behaves_like "failing validator"
    end
  end
end
