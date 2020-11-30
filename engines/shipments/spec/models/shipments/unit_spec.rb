# frozen_string_literal: true

require "rails_helper"

module Shipments
  RSpec.describe Unit, type: :model do
    describe "cargo unit functionality" do
      it_behaves_like "a Cargo Unit" do
        subject do
          unit = FactoryBot.build(:shipments_unit, :lcl, quantity: 2,
                                                         weight_value: 3000,
                                                         width_value: 1.20,
                                                         length_value: 0.80,
                                                         height_value: 1.40,
                                                         volume_value: 1.344)
          unit.validate
          unit
        end
      end
    end

    describe "validity" do
      let(:unit) { FactoryBot.build(:shipments_unit, :lcl, quantity: 2) }

      it "is valid" do
        expect(unit).to be_valid
      end
    end
  end
end

# == Schema Information
#
# Table name: shipments_units
#
#  id                   :uuid             not null, primary key
#  cargo_class          :bigint
#  cargo_type           :bigint
#  dangerous_goods      :integer          default("unspecified")
#  goods_value_cents    :integer          default(0), not null
#  goods_value_currency :string           not null
#  height_unit          :string           default("m")
#  height_value         :decimal(100, 4)
#  length_unit          :string           default("m")
#  length_value         :decimal(100, 4)
#  quantity             :integer          not null
#  stackable            :boolean
#  volume_unit          :string           default("m3")
#  volume_value         :decimal(100, 6)
#  weight_unit          :string           default("kg")
#  weight_value         :decimal(100, 3)
#  width_unit           :string           default("m")
#  width_value          :decimal(100, 4)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  cargo_id             :uuid             not null
#  sandbox_id           :uuid
#
# Indexes
#
#  index_shipments_units_on_cargo_id    (cargo_id)
#  index_shipments_units_on_sandbox_id  (sandbox_id)
#
# Foreign Keys
#
#  fk_rails_...  (sandbox_id => tenants_sandboxes.id)
#
