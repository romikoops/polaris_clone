# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class ResultsController < ApiController
      before_action :doorkeeper_authorize!, only: %i[show index], unless: :guest_user?
      before_action :authorize_access!, only: %i[show index]

      def show
        render json: Api::V2::ResultSerializer.new(
          Api::V2::ResultDecorator.new(result, context: { scope: current_scope })
        )
      end

      def index
        render json: Api::V2::RestfulSerializer.new(query.results)
      end

      private

      def result
        @result ||= Journey::Result.find(params[:id])
      end

      def query
        @query ||= params[:query_id] ? Journey::Query.find(params[:query_id]) : result.query
      end

      def guest_user?
        current_user.nil?
      end

      def authorize_access!
        head :unauthorized unless current_organization == query.organization && current_user == query.client
      end
    end
  end
end
