# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Import do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:stats) { described_class.import(model: model, data: data, type: "charge_categories", options: options) }
  let(:options) { {} }
  let(:model) { Legacy::ChargeCategory }
  let(:data) do
    [{
      "code" => "bas",
      "name" => "Basic Freight",
      "organization_id" => organization.id
    }]
  end

  before do
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    context "when inserting is successful" do
      it "returns a DataFrame of extracted values", :aggregate_failures do
        expect(stats.created).to eq(1)
      end
    end

    context "when inserting encounters a validation error" do
      let(:data) do
        [{
          "code" => "bas",
          "name" => "Basic Freight",
          "organization_id" => organization.id
        }, {
          "code" => "bas",
          "name" => "Basic_Freight",
          "organization_id" => organization.id
        }]
      end
      let(:options) { { on_duplicate_key_ignore: false } }

      it "returns a DataFrame of extracted values" do
        expect(stats.failed).to eq(2)
      end
    end

    context "when inserting encounters an unexpected error" do
      before { allow(model).to receive(:import).and_raise(ActiveRecord::StatementInvalid) }

      it "catches the error and returns a default set of Stats", :aggregate_failures do
        expect(stats.failed).to eq(1)
        expect(stats.errors.pluck(:reason)).to include("We were not able to insert your Charge categories correctly.")
      end
    end
  end
end
