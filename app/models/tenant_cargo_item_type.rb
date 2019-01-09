# frozen_string_literal: true

class TenantCargoItemType < ApplicationRecord
  belongs_to :tenant
  belongs_to :cargo_item_type

  validates :cargo_item_type, uniqueness: {
    scope: :tenant,
    message: lambda { |_, cargo_item_type|
      "(id: #{cargo_item_type[:value].id}) has already been taken by this Tenant"
    }
  }
end

# == Schema Information
#
# Table name: tenant_cargo_item_types
#
#  id                 :bigint(8)        not null, primary key
#  tenant_id          :bigint(8)
#  cargo_item_type_id :bigint(8)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
