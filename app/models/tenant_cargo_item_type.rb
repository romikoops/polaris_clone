class TenantCargoItemType < ApplicationRecord
  belongs_to :tenant
  belongs_to :cargo_item_type

  validates :cargo_item_type, uniqueness: {
    scope: :tenant,
    message: -> _, cargo_item_type {
    	"(id: #{cargo_item_type[:value].id}) has already been taken by this Tenant"
    }
  }
end
