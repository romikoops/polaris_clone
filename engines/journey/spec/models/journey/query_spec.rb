# frozen_string_literal: true
require "rails_helper"

module Journey
  RSpec.describe Query, type: :model do
    let(:query) do
      FactoryBot.build(:journey_query,
        cargo_ready_date: cargo_ready_date,
        delivery_date: delivery_date)
    end
    let(:cargo_ready_date) { Time.zone.tomorrow }
    let(:delivery_date) { 2.weeks.from_now }

    context "when cargo ready date preceeds delivery date" do
      it "passes validation" do
        expect(query).to be_valid
      end
    end

    context "when cargo ready date follows delivery date" do
      let(:delivery_date) { Time.zone.yesterday }

      it "fails validation" do
        expect(query).not_to be_valid
      end
    end

    context "when cargo ready date is in the past" do
      let(:cargo_ready_date) { Time.zone.yesterday }

      it "fails validation" do
        expect(query).not_to be_valid
      end
    end
  end
end
