# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "load_type validator", type: :service do
    let(:exception) { ExcelDataServices::Validators::ValidationErrors::TypeValidity::LoadTypeType }

    context "with valid string input" do
      let(:load_type_value) { "cargo_item" }

      it_behaves_like "passing validator"
    end

    context "with invalid string input" do
      let(:load_type_value) { "horse" }

      it_behaves_like "failing validator"
    end

    context "with invalid float input" do
      let(:load_type_value) { 1.0 }

      it_behaves_like "failing validator"
    end

    context "with invalid integer input" do
      let(:load_type_value) { 1 }

      it_behaves_like "failing validator"
    end

    context "with invalid nil inputs" do
      let(:load_type_value) { nil }

      it_behaves_like "failing validator"
    end
  end
end
