# frozen_string_literal: true

module Cargo
  class Group < ApplicationRecord
    include Bitfields
    belongs_to :user, class_name: 'Tenants::User'
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    belongs_to :load, class_name: 'Cargo::Load'

    bitfield :cargo_class, Cargo::Specification::CLASS_ENUM_HASH
    bitfield :cargo_type, Cargo::Specification::TYPE_ENUM_HASH

    after_update :update_parent_load

    validates_presence_of :tenant_id, scope: %i(user_id cargo_class)

    def unit_area
      (dimension_x * dimension_y) / Cargo::Specification::AREA_DIVISOR
    end

    def area
      unit_area * quantity
    end

    def unit_volume
      (dimension_x * dimension_y * dimension_z) / Cargo::Specification::CBM_VOLUME_DIVISOR
    end

    def volume
      unit_volume * quantity
    end

    def total_weight
      weight * quantity
    end
    
    def weight_measure
      (total_weight / 1000) / volume
    end

    def stowage
      volume / (total_weight / 1000)
    end

    def update_parent_load
      self.load.update_weight_and_volume
    end
  end
end

# == Schema Information
#
# Table name: cargo_groups
#
#  id              :uuid             not null, primary key
#  user_id         :uuid
#  tenant_id       :uuid
#  weight          :decimal(, )
#  dimension_x     :decimal(, )
#  dimension_y     :decimal(, )
#  dimension_z     :decimal(, )
#  quantity        :integer
#  cargo_class     :bigint           default(0)
#  cargo_type      :bigint           default(0)
#  stackable       :boolean
#  dangerous_goods :boolean
#  load_id         :uuid
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
