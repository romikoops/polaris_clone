# frozen_string_literal: true

module Api
  class CargoItemTypeService
    def initialize(organization:)
      @organization_id = organization.id
    end

    def perform
      Legacy::CargoItemType.where(id: cargo_item_types_ids)
    end

    private

    def cargo_item_types_ids
      Legacy::TenantCargoItemType.where(organization_id: @organization_id).pluck(:cargo_item_type_id)
    end
  end
end
