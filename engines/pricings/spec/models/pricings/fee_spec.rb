# frozen_string_literal: true

require "rails_helper"

module Pricings
  RSpec.describe Fee, type: :model do
    context "instance methods" do
      let!(:organization) { FactoryBot.create(:organizations_organization) }
      let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
      let!(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization, itinerary: itinerary) }
      let!(:fee) { FactoryBot.create(:fee_per_wm, pricing: pricing) }

      describe ".to_fee_hash" do
        let(:result) { fee.to_fee_hash }

        it "returns the fee as a hash" do
          aggregate_failures do
            expect(result.keys).to eq(["bas"])
            expect(result["bas"]["rate"]).to eq(fee.rate)
            expect(result["bas"]["base"]).to eq(fee.base)
            expect(result["bas"]["rate_basis"]).to eq("PER_WM")
            expect(result["bas"]["currency"]).to eq("EUR")
          end
        end
      end

      describe ".fee_name_and_code" do
        it "returns the fee name and code" do
          expect(fee.fee_name_and_code).to eq("BAS - Basic Ocean Freight")
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: pricings_fees
#
#  id                 :uuid             not null, primary key
#  base               :decimal(, )
#  currency_name      :string
#  hw_threshold       :decimal(, )
#  metadata           :jsonb
#  min                :decimal(, )
#  range              :jsonb
#  rate               :decimal(, )
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  charge_category_id :integer
#  currency_id        :bigint
#  hw_rate_basis_id   :uuid
#  legacy_id          :integer
#  organization_id    :uuid
#  pricing_id         :uuid
#  rate_basis_id      :uuid
#  sandbox_id         :uuid
#  tenant_id          :bigint
#
# Indexes
#
#  index_pricings_fees_on_organization_id  (organization_id)
#  index_pricings_fees_on_pricing_id       (pricing_id)
#  index_pricings_fees_on_sandbox_id       (sandbox_id)
#  index_pricings_fees_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
