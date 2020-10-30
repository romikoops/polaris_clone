# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "country_code validator", type: :service do
    let(:exception) { ExcelDataServices::Validators::ValidationErrors::TypeValidity::CountryCodeType }

    context "with valid string input" do
      let(:country_code_value) { "DE" }

      it_behaves_like "passing validator"
    end

    context "with invalid string input" do
      let(:country_code_value) { "horse" }

      it_behaves_like "failing validator"
    end

    context "with invalid float input" do
      let(:country_code_value) { 1.0 }

      it_behaves_like "failing validator"
    end

    context "with invalid integer input" do
      let(:country_code_value) { 1 }

      it_behaves_like "failing validator"
    end

    context "with invalid nil inputs" do
      let(:country_code_value) { nil }

      it_behaves_like "failing validator"
    end
  end
end
