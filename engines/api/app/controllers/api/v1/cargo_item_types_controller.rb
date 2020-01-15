# frozen_string_literal: true

module Api
  module V1
    class CargoItemTypesController < ApiController
      def index
        tenant = current_user.tenant.legacy
        render json: tenant.cargo_item_types
      end
    end
  end
end
