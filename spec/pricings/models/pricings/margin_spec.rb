# frozen_string_literal: true

require "rails_helper"

module Pricings
  RSpec.describe Margin, type: :model do
    let!(:organization) { FactoryBot.create(:organizations_organization) }
    let(:vehicle) { FactoryBot.create(:vehicle, tenant_vehicles: [tenant_vehicle_1]) }
    let(:hub) { FactoryBot.create(:legacy_hub, organization: organization, name: "Gothenburg") }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:pricing) {
      FactoryBot.create(:lcl_pricing,
        tenant_vehicle: tenant_vehicle_1, organization: organization, itinerary: itinerary)
    }
    let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly", organization: organization) }

    context "instance methods" do
      let!(:no_pricing_margin) do
        FactoryBot.create(:pricings_margin,
          tenant_vehicle: tenant_vehicle_1,
          cargo_class: "lcl",
          itinerary: pricing.itinerary,
          organization: organization,
          applicable: organization)
      end
      let!(:pricing_margin) do
        FactoryBot.create(:pricings_margin,
          pricing: pricing,
          organization: organization,
          applicable: organization)
      end
      let!(:dates_margin) do
        FactoryBot.create(:pricings_margin,
          pricing: pricing,
          effective_date: Date.parse("2019/01/01"),
          expiration_date: Date.parse("2019/01/31"),
          organization: organization,
          applicable: organization)
      end
      let!(:margin) do
        FactoryBot.create(:pricings_margin,
          pricing: pricing,
          organization: organization,
          applicable: organization)
      end
      let!(:origin_hub_margin) do
        FactoryBot.create(:pricings_margin,
          origin_hub: hub,
          organization: organization,
          applicable: organization)
      end
      let!(:destination_hub_margin) do
        FactoryBot.create(:pricings_margin,
          destination_hub: hub,
          organization: organization,
          applicable: organization)
      end
      let!(:all_hub_margin) do
        FactoryBot.create(:pricings_margin,
          destination_hub: hub,
          origin_hub: hub,
          organization: organization,
          applicable: organization)
      end
      let!(:all_margin) do
        FactoryBot.create(:pricings_margin,
          itinerary: nil,
          cargo_class: nil,
          tenant_vehicle: nil,
          destination_hub: nil,
          origin_hub: nil,
          organization: organization,
          applicable: organization)
      end

      let!(:margin_detail) { FactoryBot.create(:bas_margin_detail, margin: margin) }

      describe ".get_pricing" do
        it "finds the pricing with pricing attached" do
          expect(pricing_margin.get_pricing).to eq(pricing)
        end
        it "finds the pricing with no pricing attached" do
          expect(no_pricing_margin.get_pricing).to eq(pricing)
        end
      end

      describe ".fee_code" do
        it "renders the fee_code with pricing attached" do
          expect(pricing_margin.fee_code).to eq("N/A")
        end
        it "renders the fee_code with no pricing attached" do
          expect(no_pricing_margin.fee_code).to eq("N/A")
        end
      end

      describe ".service_level" do
        it "renders the service level with pricing attached" do
          expect(pricing_margin.service_level).to eq("slowly")
        end
        it "renders the service level with no pricing attached" do
          expect(no_pricing_margin.service_level).to eq("slowly")
        end
      end

      describe ".cargo_class" do
        it "renders the cargo_class with pricing attached" do
          expect(pricing_margin.cargo_class).to eq("lcl")
        end
        it "renders the cargo_class with no pricing attached" do
          expect(no_pricing_margin.cargo_class).to eq("lcl")
        end
      end

      describe ".itinerary_name" do
        it "renders the itinerary_name with pricing attached" do
          expect(pricing_margin.itinerary_name).to eq("Gothenburg - Shanghai")
        end
        it "renders the itinerary_name with no pricing attached" do
          expect(no_pricing_margin.itinerary_name).to eq("Gothenburg - Shanghai")
        end
        it "renders the itinerary_name with origin hub attached" do
          expect(origin_hub_margin.itinerary_name).to eq("Departing Gothenburg")
        end
        it "renders the itinerary_name with destination hub attached" do
          expect(destination_hub_margin.itinerary_name).to eq("Entering Gothenburg")
        end
        it "renders the itinerary_name with destination hub attached" do
          expect(all_hub_margin.itinerary_name).to eq("Gothenburg")
        end
        it "renders the itinerary_name with destination hub attached" do
          expect(all_margin.itinerary_name).to eq("All")
        end
      end

      describe ".mode_of_transport" do
        it "renders the mode_of_transport with pricing attached" do
          expect(pricing_margin.mode_of_transport).to eq("ocean")
        end
        it "renders the mode_of_transport with no pricing attached" do
          expect(no_pricing_margin.mode_of_transport).to eq("ocean")
        end
      end
    end

    context "class methods" do
      let!(:lcl_margin) do
        FactoryBot.create(:pricings_margin,
          cargo_class: "lcl",
          organization: organization,
          applicable: organization)
      end
      let!(:fcl_20_margin) do
        FactoryBot.create(:pricings_margin,
          cargo_class: "fcl_20",
          organization: organization,
          applicable: organization)
      end
      let!(:fcl_40_margin) do
        FactoryBot.create(:pricings_margin,
          cargo_class: "fcl_40",
          organization: organization,
          applicable: organization)
      end
      let!(:fcl_40_hq_margin) do
        FactoryBot.create(:pricings_margin,
          cargo_class: "fcl_40_hq",
          organization: organization,
          applicable: organization)
      end

      describe ".for_cargo_classes" do
        it "finds margins for lcl cargo class" do
          margins = ::Pricings::Margin.for_cargo_classes(["lcl"])
          expect(margins).to eq([lcl_margin])
        end
        it "finds no margins for two of three fcl classes" do
          margins = ::Pricings::Margin.for_cargo_classes(%w[fcl_20 fcl_40_hq])
          expect(margins).to eq([fcl_20_margin, fcl_40_hq_margin])
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: pricings_margins
#
#  id                 :uuid             not null, primary key
#  applicable_type    :string
#  application_order  :integer          default(0)
#  cargo_class        :string
#  default_for        :string
#  effective_date     :datetime
#  expiration_date    :datetime
#  margin_type        :integer
#  operator           :string
#  validity           :daterange
#  value              :decimal(, )
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  applicable_id      :uuid
#  destination_hub_id :integer
#  itinerary_id       :integer
#  organization_id    :uuid
#  origin_hub_id      :integer
#  pricing_id         :uuid
#  sandbox_id         :uuid
#  tenant_id          :uuid
#  tenant_vehicle_id  :integer
#
# Indexes
#
#  index_pricings_margins_on_applicable_type_and_applicable_id  (applicable_type,applicable_id)
#  index_pricings_margins_on_application_order                  (application_order)
#  index_pricings_margins_on_cargo_class                        (cargo_class)
#  index_pricings_margins_on_destination_hub_id                 (destination_hub_id)
#  index_pricings_margins_on_effective_date                     (effective_date)
#  index_pricings_margins_on_expiration_date                    (expiration_date)
#  index_pricings_margins_on_itinerary_id                       (itinerary_id)
#  index_pricings_margins_on_margin_type                        (margin_type)
#  index_pricings_margins_on_organization_id                    (organization_id)
#  index_pricings_margins_on_origin_hub_id                      (origin_hub_id)
#  index_pricings_margins_on_pricing_id                         (pricing_id)
#  index_pricings_margins_on_sandbox_id                         (sandbox_id)
#  index_pricings_margins_on_tenant_id                          (tenant_id)
#  index_pricings_margins_on_tenant_vehicle_id                  (tenant_vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
