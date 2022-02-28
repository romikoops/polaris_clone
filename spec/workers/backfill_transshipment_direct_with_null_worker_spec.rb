# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackfillTransshipmentDirectWithNullWorker, type: :worker do
  let!(:pricing) { FactoryBot.create(:pricings_pricing, transshipment: "DiReKt") }
  let!(:route_section) { FactoryBot.create(:journey_route_section, transshipment: "DIRECT") }
  let(:backfill_instance) { described_class.new }

  describe "#perform" do
    it "backfills models transshipment with null" do
      backfill_instance.perform
      pricing.reload
      route_section.reload
      expect(pricing.transshipment).to be_nil
      expect(route_section.transshipment).to be_nil
    end

    context "when transshipment with `direct` is present after perform" do
      before do
        allow(backfill_instance).to receive(:unsupported_type_exist?).and_return(true)
      end

      it "raises `FailedTransshipmentBackFill`" do
        expect { backfill_instance.perform }.to raise_error(BackfillTransshipmentDirectWithNullWorker::FailedTransshipmentBackFill)
      end
    end
  end
end
