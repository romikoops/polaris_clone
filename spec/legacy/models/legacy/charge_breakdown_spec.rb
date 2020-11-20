# frozen_string_literal: true

require "rails_helper"

module Legacy
  RSpec.describe ChargeBreakdown, type: :model do
    context "instance methods" do
      let(:charge_breakdown) { FactoryBot.create(:legacy_charge_breakdown) }
      let(:shipment) { charge_breakdown.shipment }
      let(:price) { FactoryBot.create(:legacy_price) }
      let(:grand_total_category) {
        Legacy::ChargeCategory.find_by(code: "grand_total", organization_id: shipment.organization_id)
      }
      let(:hidden_args) do
        {
          hidden_grand_total: false,
          hidden_sub_total: false,
          hide_converted_grand_total: false
        }
      end

      let(:charge) do
        FactoryBot.create(
          :legacy_charge,
          charge_breakdown: charge_breakdown,
          charge_category: Legacy::ChargeCategory.from_code(
            code: "base_node", name: "Base Node", organization_id: shipment.organization_id
          ),
          children_charge_category: Legacy::ChargeCategory.from_code(
            code: "grand_total", name: "Grand Total", organization_id: shipment.organization_id
          ),
          price: price
        )
      end

      describe ".charges.from_category" do
        it "returns a collection of charges" do
          result = charge_breakdown.charges.from_category(
            Legacy::ChargeCategory.from_code(
              code: "base_node", name: "Base Node", organization_id: shipment.organization_id
            ).code
          )

          expect(result).not_to be_empty
          expect(result).to all be_a Charge
        end
      end

      describe ".charge_categories.detail" do
        it "returns a collection of charge categories" do
          result = charge_breakdown.charge_categories.detail(0)

          expect(result).not_to be_empty
          expect(result).to all be_a Legacy::ChargeCategory
        end
      end

      describe ".selected" do
        before do
          charge.touch
        end

        it "selects" do
          expect(described_class.selected).to match(charge_breakdown)
        end
      end

      describe ".charge" do
        it "gets charge" do
          charges = charge_breakdown.charge(charge.charge_category.code)
          expect(charges).to be_nil
        end
      end

      describe ".grand_total" do
        it "gets grand_total" do
          result = charge_breakdown.grand_total
          expect(result).to eq(
            Legacy::Charge.find_by(
              charge_breakdown_id: charge_breakdown.id,
              children_charge_category: grand_total_category
            )
          )
        end
      end

      describe ".grand_total=" do
        it "sets grand_total" do
          charge_breakdown.grand_total = charge
          expect(charge_breakdown.charges).to include(charge)
        end
      end

      describe ".to_nested_hash" do
        it "gets nested_hash" do
          cargo_unit_id = charge_breakdown.charges.find_by(detail_level: 3)&.charge_category&.cargo_unit_id
          expected = {
            "total" => {"value" => 0.999e1, "currency" => "EUR"},
            "edited_total" => nil,
            "name" => "Grand Total",
            "cargo" =>
          {"total" => {"value" => 0.999e1, "currency" => "EUR"},
           "edited_total" => nil,
           "name" => "Cargo",
           cargo_unit_id.to_s =>
            {"total" => {"value" => 0.999e1, "currency" => "EUR"},
             "edited_total" => nil,
             "name" => "Container",
             "bas" => {"currency" => "EUR", "sandbox_id" => nil, "value" => 0.999e1, "name" => "Basic Ocean Freight"}}},
            "trip_id" => 2107
          }

          expect(charge_breakdown.to_nested_hash(hidden_args)["cargo"]).to eq(expected["cargo"])
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: charge_breakdowns
#
#  id                         :bigint           not null, primary key
#  valid_until                :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  delivery_tenant_vehicle_id :integer
#  freight_tenant_vehicle_id  :integer
#  pickup_tenant_vehicle_id   :integer
#  sandbox_id                 :uuid
#  shipment_id                :integer
#  tender_id                  :uuid
#  trip_id                    :integer
#
# Indexes
#
#  index_charge_breakdowns_on_delivery_tenant_vehicle_id  (delivery_tenant_vehicle_id)
#  index_charge_breakdowns_on_freight_tenant_vehicle_id   (freight_tenant_vehicle_id)
#  index_charge_breakdowns_on_pickup_tenant_vehicle_id    (pickup_tenant_vehicle_id)
#  index_charge_breakdowns_on_sandbox_id                  (sandbox_id)
#
# Foreign Keys
#
#  fk_rails_...  (delivery_tenant_vehicle_id => tenant_vehicles.id)
#  fk_rails_...  (freight_tenant_vehicle_id => tenant_vehicles.id)
#  fk_rails_...  (pickup_tenant_vehicle_id => tenant_vehicles.id)
#
