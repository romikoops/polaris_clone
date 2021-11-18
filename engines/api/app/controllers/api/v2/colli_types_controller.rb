# frozen_string_literal: true

module Api
  module V2
    class ColliTypesController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:show]

      def show
        render json: { data: colli_types }
      end

      private

      def colli_types
        Journey::CargoUnit.colli_types.values &
          Legacy::CargoItemType.joins(:tenant_cargo_item_types)
            .where(tenant_cargo_item_types: { organization: current_organization.id })
            .pluck(:category).uniq.map(&:downcase)
      end
    end
  end
end
