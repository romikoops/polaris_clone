# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class TruckingCountriesController < ApiController
      include UsersUserAccess
      def index
        countries = Api::Routing::Trucking::CountriesService.new(
          organization: current_organization,
          load_type: trucking_params[:load_type],
          target: trucking_params[:location_type].to_sym
        ).perform

        render json: CountrySerializer.new(countries)
      end

      private

      def trucking_params
        params.permit(:load_type, :location_type)
      end
    end
  end
end
