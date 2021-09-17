# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class ErrorsController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:index]

      def index
        render json: Api::V2::ErrorSerializer.new(errors)
      end

      private

      def query
        @query ||= Journey::Query.find(params[:query_id])
      end

      def errors
        query.result_errors
      end
    end
  end
end
