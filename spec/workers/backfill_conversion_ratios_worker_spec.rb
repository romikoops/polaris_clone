# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackfillConversionRatiosWorker, type: :worker do
  let!(:pricing) { FactoryBot.create(:lcl_pricing) }

  before { described_class.new.perform }

  describe "#perform" do
    it "assigns the cbm_ratio and vm_ratio to the pricings fee", :aggregate_failures do
      expect(pricing.fees.first.cbm_ratio).to eq(pricing.wm_rate)
      expect(pricing.fees.first.vm_ratio).to eq(pricing.vm_rate)
    end
  end
end
