# frozen_string_literal: true

module Api
  class CargoItemTypeService
    def initialize(tenant:)
      @tenant_id = tenant.legacy_id
    end

    def perform
      Legacy::CargoItemType.where(id: cargo_item_types_ids)
    end

    private

    def cargo_item_types_ids
      Legacy::TenantCargoItemType.where(tenant_id: @tenant_id).pluck(:cargo_item_type_id)
    end
  end
end
