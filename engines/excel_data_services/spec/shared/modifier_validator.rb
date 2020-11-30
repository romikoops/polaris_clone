# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "modifier validator", type: :service do
    let(:exception) { ExcelDataServices::Validators::ValidationErrors::TypeValidity::ModifierType }

    context "with valid string input" do
      let(:modifier_value) { "kg" }

      it_behaves_like "passing validator"
    end

    context "with valid string input" do
      let(:modifier_value) { "cbm_kg" }

      it_behaves_like "passing validator"
    end

    context "with invalid string input" do
      let(:modifier_value) { "horse" }

      it_behaves_like "failing validator"
    end

    context "with invalid float input" do
      let(:modifier_value) { 1.0 }

      it_behaves_like "failing validator"
    end

    context "with invalid integer input" do
      let(:modifier_value) { 1 }

      it_behaves_like "failing validator"
    end

    context "with invalid nil inputs" do
      let(:modifier_value) { nil }

      it_behaves_like "failing validator"
    end
  end
end
