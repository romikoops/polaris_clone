# frozen_string_literal: true

module Api
  module V1
    class RoutePointDecorator < ApplicationDecorator
      delegate_all

      delegate :latitude, to: :coordinates
      delegate :longitude, to: :coordinates

      def modes_of_transport
      end

      def country_name
      end
    end
  end
end
