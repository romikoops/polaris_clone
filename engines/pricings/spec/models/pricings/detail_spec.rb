# frozen_string_literal: true

require "rails_helper"

module Pricings
  RSpec.describe Detail, type: :model do
    context "instance methods" do
      let!(:organization) { FactoryBot.create(:organizations_organization) }
      let(:vehicle) { FactoryBot.create(:vehicle, tenant_vehicles: [tenant_vehicle_1]) }
      let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
      let(:pricing) {
        FactoryBot.create(:lcl_pricing,
          tenant_vehicle: tenant_vehicle_1, organization: organization, itinerary: itinerary)
      }
      let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly", organization: organization) }

      let!(:margin) do
        FactoryBot.create(:pricings_margin,
          pricing: pricing,
          organization: organization,
          applicable: organization)
      end

      let!(:margin_detail) {
        FactoryBot.create(:pricings_detail, margin: margin, charge_category_id: pricing.fees.first.charge_category_id)
      }

      describe ".fee_code" do
        it "renders the fee_code " do
          expect(margin_detail.fee_code).to eq("bas")
        end
      end

      describe ".rate_basis" do
        it "renders the rate_basis" do
          expect(margin_detail.rate_basis).to eq("PER_WM")
        end
      end

      describe ".itinerary_name" do
        it "renders the itinerary_name with pricing attached" do
          expect(margin_detail.itinerary_name).to eq("Gothenburg - Shanghai")
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: pricings_details
#
#  id                 :uuid             not null, primary key
#  operator           :string
#  value              :decimal(, )
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  charge_category_id :integer
#  margin_id          :uuid
#  organization_id    :uuid
#  sandbox_id         :uuid
#  tenant_id          :uuid
#
# Indexes
#
#  index_pricings_details_on_charge_category_id  (charge_category_id)
#  index_pricings_details_on_margin_id           (margin_id)
#  index_pricings_details_on_organization_id     (organization_id)
#  index_pricings_details_on_sandbox_id          (sandbox_id)
#  index_pricings_details_on_tenant_id           (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
