# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "cargo_class validator", type: :service do
    let(:exception) { ExcelDataServices::Validators::ValidationErrors::TypeValidity::CargoClassType }

    context "with valid string input" do
      let(:cargo_class_value) { "lcl" }

      it_behaves_like "passing validator"
    end

    context "with invalid string input" do
      let(:cargo_class_value) { "horse" }

      it_behaves_like "failing validator"
    end

    context "with invalid float input" do
      let(:cargo_class_value) { 1.0 }

      it_behaves_like "failing validator"
    end

    context "with invalid integer input" do
      let(:cargo_class_value) { 1 }

      it_behaves_like "failing validator"
    end

    context "with invalid nil inputs" do
      let(:cargo_class_value) { nil }

      it_behaves_like "failing validator"
    end
  end
end
