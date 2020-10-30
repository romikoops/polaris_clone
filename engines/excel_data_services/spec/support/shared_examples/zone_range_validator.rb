# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "zone_range validator", type: :service do
    let(:exception) { ExcelDataServices::Validators::ValidationErrors::TypeValidity::ZoneRangeType }

    context "with valid string input" do
      let(:zone_range_value) { "2000 - 3000" }

      it_behaves_like "passing validator"
    end

    context "with invalid float input" do
      let(:zone_range_value) { 1.0 }

      it_behaves_like "failing validator"
    end

    context "with invalid integer input" do
      let(:zone_range_value) { 1 }

      it_behaves_like "failing validator"
    end

    context "with invalid string inputs" do
      let(:zone_range_value) { "abc" }

      it_behaves_like "failing validator"
    end

    context "with valid nil inputs" do
      let(:zone_range_value) { nil }

      it_behaves_like "passing validator"
    end
  end
end
