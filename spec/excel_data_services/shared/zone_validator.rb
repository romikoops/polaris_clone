# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "zone validator", type: :service do
    let(:exception) { ExcelDataServices::Validators::ValidationErrors::TypeValidity::ZoneType }

    context "with valid string input" do
      let(:zone_value) { "0.0" }

      it_behaves_like "passing validator"
    end

    context "with valid float input" do
      let(:zone_value) { 1.0 }

      it_behaves_like "passing validator"
    end

    context "with valid integer input" do
      let(:zone_value) { 1 }

      it_behaves_like "passing validator"
    end

    context "with invalid string inputs" do
      let(:zone_value) { "abc" }

      it_behaves_like "failing validator"
    end

    context "with invalid nil inputs" do
      let(:zone_value) { nil }

      it_behaves_like "failing validator"
    end
  end
end
