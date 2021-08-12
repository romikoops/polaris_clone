# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class ResultsController < ApiController
      skip_before_action :doorkeeper_authorize!, only: %i[show index]

      def show
        render json: Api::V2::ResultSerializer.new(
          Api::V2::ResultDecorator.new(result)
        )
      end

      def index
        render json: Api::V2::RestfulSerializer.new(results)
      end

      private

      def result
        @result ||= Journey::Result.find(params[:id])
      end

      def result_set
        @result_set ||= Journey::ResultSet.find(params[:result_set_id])
      end

      def results
        Journey::Result.where(result_set: result_set)
      end
    end
  end
end
