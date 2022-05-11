# frozen_string_literal: true

module Api
  module V2
    class CountriesController < ApiController
      skip_before_action :doorkeeper_authorize!
      skip_before_action :ensure_organization!

      def index
        render json: Api::V2::CountrySerializer.new(countries)
      end

      private

      def countries
        @countries = Country.all
      end
    end
  end
end
