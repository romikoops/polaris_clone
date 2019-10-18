# frozen_string_literal: true

class TenantCargoItemType < Legacy::TenantCargoItemType
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
