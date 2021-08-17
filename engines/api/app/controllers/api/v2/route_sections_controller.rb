# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class RouteSectionsController < ApiController
      skip_before_action :doorkeeper_authorize!, only: %i[index]

      def index
        render json: Api::V2::RouteSectionSerializer.new(
          Api::V2::RouteSectionDecorator.decorate_collection(route_sections)
        )
      end

      private

      def result
        @result ||= Journey::Result.find(params[:result_id])
      end

      def route_sections
        @route_sections ||= Journey::RouteSection.where(result: result)
      end
    end
  end
end
