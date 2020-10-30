# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.shared_examples "boolean validator", type: :service do
    context "with valid boolean input" do
      let(:boolean_value) { false }

      it_behaves_like "passing validator"
    end

    context "with valid string input" do
      let(:boolean_value) { "true" }

      it_behaves_like "passing validator"
    end

    context "with valid float input" do
      let(:boolean_value) { 1.0 }

      it_behaves_like "passing validator"
    end

    context "with invalid integer input" do
      let(:boolean_value) { 1 }

      it_behaves_like "passing validator"
    end

    context "with nil inputs" do
      let(:boolean_value) { nil }

      it_behaves_like "passing validator"
    end
  end
end
