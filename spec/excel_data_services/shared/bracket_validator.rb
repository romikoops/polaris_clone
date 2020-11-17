# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "bracket validator", type: :service do
    let(:exception) { ExcelDataServices::Validators::ValidationErrors::TypeValidity::BracketType }

    context "with valid string input" do
      let(:value) { "0.0 - 100.0" }

      it_behaves_like "passing validator"
    end

    context "with invalid float input" do
      let(:value) { 1.0 }

      it_behaves_like "failing validator"
    end

    context "with invalid integer input" do
      let(:value) { 1 }

      it_behaves_like "failing validator"
    end

    context "with invalid string inputs" do
      let(:value) { "abc" }

      it_behaves_like "failing validator"
    end

    context "with invalid nil inputs" do
      let(:value) { nil }

      it_behaves_like "failing validator"
    end
  end
end
