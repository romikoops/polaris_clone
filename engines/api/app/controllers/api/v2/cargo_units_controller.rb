# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class CargoUnitsController < ApiController
      skip_before_action :doorkeeper_authorize!, if: :guest_user?

      def index
        render json: Api::V2::CargoUnitSerializer.new(
          Api::V2::CargoUnitDecorator.decorate_collection(cargo_units)
        )
      end

      def show
        render json: Api::V2::CargoUnitSerializer.new(
          Api::V2::CargoUnitDecorator.new(cargo_unit)
        )
      end

      private

      def query
        @query ||= Journey::Query.find(params[:query_id])
      end

      def cargo_units
        @cargo_units ||= Journey::CargoUnit.where(query_id: params[:query_id])
      end

      def cargo_unit
        @cargo_unit ||= Journey::CargoUnit.find(params[:id])
      end

      def guest_user?
        !current_scope["closed_shop"] && query.client_id.blank? && current_user.blank?
      end
    end
  end
end
