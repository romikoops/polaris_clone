# frozen_string_literal: true

module Cargo
  class Load < ApplicationRecord
    include Bitfields
    belongs_to :user, class_name: 'Tenants::User'
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    has_many :groups, class_name: 'Cargo::Group'

    bitfield :cargo_class, Cargo::Specification::CLASS_ENUM_HASH
    bitfield :cargo_type, Cargo::Specification::TYPE_ENUM_HASH

    def area
      if groups.present?
        groups.sum(&:area)
      else
        volume / Cargo::Specification::DEFAULT_HEIGHT
      end
    end

    def height
      groups.present? ? (groups.sum(&:dimension_z) / groups.length) : Cargo::Specification::DEFAULT_HEIGHT
    end

    def stackable
      groups.present? ? groups.all?(&:stackable) : true
    end

    def weight_measure
      (weight / 1000) / volume
    end

    def stowage
      volume / (weight / 1000)
    end

    def update_weight_and_volume
      self.weight = groups.sum(&:total_weight)
      self.volume = groups.sum(&:volume)
    end
  end
end

# == Schema Information
#
# Table name: cargo_loads
#
#  id          :uuid             not null, primary key
#  user_id     :uuid
#  tenant_id   :uuid
#  weight      :decimal(, )      default(0.0)
#  quantity    :integer          default(0)
#  volume      :decimal(, )      default(0.0)
#  cargo_class :bigint           default(0)
#  cargo_type  :bigint           default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
