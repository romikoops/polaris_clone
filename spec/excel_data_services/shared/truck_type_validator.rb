# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "truck_type validator", type: :service do
    let(:exception) { ExcelDataServices::Validators::ValidationErrors::TypeValidity::TruckTypeType }

    context "with valid string input" do
      let(:truck_type_value) { "default" }

      it_behaves_like "passing validator"
    end

    context "with invalid string input" do
      let(:truck_type_value) { "deafult" }

      it_behaves_like "failing validator"
    end

    context "with invalid float input" do
      let(:truck_type_value) { 1.0 }

      it_behaves_like "failing validator"
    end

    context "with invalid integer input" do
      let(:truck_type_value) { 1 }

      it_behaves_like "failing validator"
    end

    context "with invalid nil inputs" do
      let(:truck_type_value) { nil }

      it_behaves_like "failing validator"
    end
  end
end
