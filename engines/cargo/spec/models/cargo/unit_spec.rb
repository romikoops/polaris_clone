# frozen_string_literal: true

require 'rails_helper'

module Cargo
  RSpec.describe Unit, type: :model do
    it_behaves_like 'a Cargo Unit' do
      subject do
        unit = FactoryBot.build(:cargo_unit, :lcl, quantity: 2,
                                                   weight_value: 3000,
                                                   width_value: 1.20,
                                                   length_value: 0.80,
                                                   height_value: 1.40)
        unit.validate
        unit
      end
    end
  end
end

# == Schema Information
#
# Table name: cargo_units
#
#  id                   :uuid             not null, primary key
#  cargo_class          :bigint           default("00")
#  cargo_type           :bigint           default("LCL")
#  dangerous_goods      :integer          default("unspecified")
#  goods_value_cents    :integer          default(0), not null
#  goods_value_currency :string           not null
#  height_unit          :string           default("m")
#  height_value         :decimal(100, 4)  default(0.0)
#  legacy_type          :string
#  length_unit          :string           default("m")
#  length_value         :decimal(100, 4)  default(0.0)
#  quantity             :integer          default(0)
#  stackable            :boolean          default(FALSE)
#  volume_unit          :string           default("m3")
#  volume_value         :decimal(100, 6)  default(0.0)
#  weight_unit          :string           default("kg")
#  weight_value         :decimal(100, 3)  default(0.0)
#  width_unit           :string           default("m")
#  width_value          :decimal(100, 4)  default(0.0)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  cargo_id             :uuid
#  organization_id      :uuid
#  tenant_id            :uuid
#
# Indexes
#
#  index_cargo_units_on_cargo_class                (cargo_class)
#  index_cargo_units_on_cargo_id                   (cargo_id)
#  index_cargo_units_on_cargo_type                 (cargo_type)
#  index_cargo_units_on_legacy_type_and_legacy_id  (legacy_type,legacy_id)
#  index_cargo_units_on_tenant_id                  (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (cargo_id => cargo_cargos.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
