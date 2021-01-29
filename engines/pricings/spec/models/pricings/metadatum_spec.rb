# frozen_string_literal: true

require "rails_helper"

module Pricings
  RSpec.describe Metadatum, type: :model do
    let(:metadatum) { FactoryBot.build(:pricings_metadatum, result_id: result.id) }
    let(:result) { FactoryBot.create(:journey_result) }

    describe "#valid?" do
      context "when valid" do
        it "build valid object" do
          expect(metadatum).to be_valid
        end
      end

      context "when valid with other metadata" do
        let(:metadatum) {
          FactoryBot.build(:pricings_metadatum, organization: organization, charge_breakdown: charge_breakdown)
        }
        let(:charge_breakdown) { FactoryBot.build(:legacy_charge_breakdown) }
        let(:organization) { FactoryBot.build(:organizations_organization) }

        before { FactoryBot.create(:pricings_metadatum, charge_breakdown: charge_breakdown) }

        it "build valid object" do
          expect(metadatum).to be_valid
        end
      end

      context "when invalid" do
        let(:metadatum) {
          FactoryBot.build(:pricings_metadatum, organization: organization, result_id: result.id)
        }
        let(:organization) { FactoryBot.build(:organizations_organization) }

        before do
          FactoryBot.create(:pricings_metadatum, organization: organization, result_id: result.id)
        end

        it "build valid object" do
          expect(metadatum).not_to be_valid
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: pricings_metadata
#
#  id                  :uuid             not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  cargo_unit_id       :integer
#  charge_breakdown_id :integer
#  organization_id     :uuid
#  pricing_id          :uuid
#  tenant_id           :uuid
#
# Indexes
#
#  index_pricings_metadata_on_charge_breakdown_id  (charge_breakdown_id)
#  index_pricings_metadata_on_organization_id      (organization_id)
#  index_pricings_metadata_on_tenant_id            (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
