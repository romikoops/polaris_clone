# frozen_string_literal: true

module Legacy
  class TenantCargoItemType < ApplicationRecord
    self.table_name = 'tenant_cargo_item_types'
    belongs_to :tenant
    belongs_to :cargo_item_type

    validates :cargo_item_type, uniqueness: { scope: :tenant }
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
