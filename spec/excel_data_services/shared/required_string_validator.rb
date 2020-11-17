# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "required_string validator", type: :service do
    let(:exception) { ExcelDataServices::Validators::ValidationErrors::TypeValidity::StringType }

    context "with valid string input" do
      let(:required_string_value) { "0.0" }

      it_behaves_like "passing validator"
    end

    context "with invalid float input" do
      let(:required_string_value) { 1.0 }

      it_behaves_like "failing validator"
    end

    context "with invalid integer input" do
      let(:required_string_value) { 1 }

      it_behaves_like "failing validator"
    end

    context "with valid nil inputs" do
      let(:required_string_value) { nil }

      it_behaves_like "failing validator"
    end
  end
end
