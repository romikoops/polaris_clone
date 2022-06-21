# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Separator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:query) { FactoryBot.create(:journey_query, client: user, organization: organization, cargo_count: 0) }
  let(:request) { FactoryBot.build(:offer_calculator_request, client: user, organization: organization, query: query) }
  let(:fee_contexts) { described_class.new(fee_frame: Rover::DataFrame.new(simplified_fee_rows), margin_frame: Rover::DataFrame.new(margin_rows)).perform }
  let(:margin_rows) do
    {
      "code" => [],
      "effective_date" => [],
      "expiration_date" => [],
      "id" => []
    }
  end

  let(:simplified_fee_rows) do
    [{
      "cargo_class" => "lcl",
      "effective_date" => Time.zone.today,
      "expiration_date" => 2.weeks.from_now.to_date,
      "context_id" => "3f31408a-c579-4b28-9ef6-e4d462d20154",
      "code" => "bas"
    }]
  end

  describe "#perform" do
    context "when there a single fee context present" do
      it "returns the valid contexts to be used in the process" do
        expect(fee_contexts).to eq(simplified_fee_rows)
      end
    end

    context "when there are multiple fee contexts present" do
      let(:simplified_fee_rows) do
        [
          {
            "cargo_class" => "lcl",
            "effective_date" => Time.zone.today,
            "expiration_date" => 2.weeks.from_now.to_date,
            "context_id" => "3f31408a-c579-4b28-9ef6-e4d462d20154",
            "code" => "bas"
          },
          {
            "cargo_class" => "lcl",
            "effective_date" => Time.zone.today,
            "expiration_date" => 2.weeks.from_now.to_date,
            "context_id" => "3f31408a-c579-4b28-9ef6-e4d462d20154",
            "code" => "baf"
          }
        ]
      end

      it "returns the valid contexts to be used in the process" do
        expect(fee_contexts).to eq(simplified_fee_rows)
      end
    end

    context "when there are multiple fee contexts present, one with matching margin row data" do
      let(:simplified_fee_rows) do
        [
          {
            "cargo_class" => "lcl",
            "effective_date" => Time.zone.today,
            "expiration_date" => 2.weeks.from_now.to_date,
            "context_id" => "3f31408a-c579-4b28-9ef6-e4d462d20154",
            "code" => "bas"
          },
          {
            "cargo_class" => "lcl",
            "effective_date" => Time.zone.today,
            "expiration_date" => 2.weeks.from_now.to_date,
            "context_id" => "3f31408a-c579-4b28-9ef6-e4d462d20154",
            "code" => "baf"
          }
        ]
      end

      let(:margin_rows) do
        [{
          "cargo_class" => "lcl",
          "effective_date" => Time.zone.today,
          "expiration_date" => 2.weeks.from_now.to_date,
          "code" => "bas"
        }]
      end

      it "returns the valid contexts to be used in the process" do
        expect(fee_contexts).to eq(simplified_fee_rows)
      end
    end

    context "when there are fee contexts present, one with non matching margin row data" do
      let(:simplified_fee_rows) do
        [
          {
            "cargo_class" => "lcl",
            "effective_date" => Time.zone.today,
            "expiration_date" => 2.weeks.from_now.to_date,
            "context_id" => "3f31408a-c579-4b28-9ef6-e4d462d20154",
            "code" => "bas"
          }
        ]
      end

      let(:margin_rows) do
        [{
          "cargo_class" => "lcl",
          "effective_date" => Time.zone.today,
          "expiration_date" => 2.weeks.from_now.to_date,
          "code" => "vat"
        }]
      end

      expected_contexts = [
        {
          "cargo_class" => "lcl",
          "effective_date" => Time.zone.today,
          "expiration_date" => 2.weeks.from_now.to_date,
          "context_id" => "3f31408a-c579-4b28-9ef6-e4d462d20154",
          "code" => "bas"
        },
        {
          "cargo_class" => "lcl",
          "effective_date" => Time.zone.today,
          "expiration_date" => 2.weeks.from_now.to_date,
          "code" => "vat",
          "context_id" => "3f31408a-c579-4b28-9ef6-e4d462d20154"
        }
      ]

      it "returns the valid contexts to be used in the process" do
        expect(fee_contexts).to match_array(expected_contexts)
      end
    end
  end
end
