# frozen_string_literal: true

module Api
  module V1
    class CargoItemTypesController < ApiController
      def index
        cargo_item_types = Api::CargoItemTypeService.new(tenant: current_tenant).perform

        render json: CargoItemTypeSerializer.new(cargo_item_types)
      end
    end
  end
end
