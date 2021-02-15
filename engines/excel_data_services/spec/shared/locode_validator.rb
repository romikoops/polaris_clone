# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "locode validator", type: :service do
    let(:exception) { ExcelDataServices::Validators::ValidationErrors::TypeValidity::LocodeType }
    context "with valid string input" do
      let(:locode_value) { "DEHAM" }

      it_behaves_like "passing validator"
    end

    context "with invalid float input" do
      let(:locode_value) { 1.0 }

      it_behaves_like "failing validator"
    end

    context "with invalid integer input" do
      let(:locode_value) { 1 }

      it_behaves_like "failing validator"
    end

    context "with invalid nil inputs" do
      let(:locode_value) { nil }

      it_behaves_like "failing validator"
    end
  end
end
