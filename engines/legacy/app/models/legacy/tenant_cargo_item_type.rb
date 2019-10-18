# frozen_string_literal: true

module Legacy
  class TenantCargoItemType < ApplicationRecord
    self.table_name = 'tenant_cargo_item_types'

    belongs_to :tenant, class_name: 'Legacy::Tenant'
    belongs_to :cargo_item_type, class_name: 'Legacy::CargoItemType'

    validates :cargo_item_type, uniqueness: {
      scope: :tenant,
      message: lambda { |_, cargo_item_type|
        "(id: #{cargo_item_type[:value].id}) has already been taken by this Tenant"
      }
    }
  end
end

# == Schema Information
#
# Table name: tenant_cargo_item_types
#
#  id                 :bigint           not null, primary key
#  tenant_id          :bigint
#  cargo_item_type_id :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  sandbox_id         :uuid
#
