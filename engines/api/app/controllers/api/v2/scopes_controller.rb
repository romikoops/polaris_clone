# frozen_string_literal: true

module Api
  module V2
    class ScopesController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:show]

      def show
        render json: ScopeSerializer.new(api_scope)
      end

      private

      def api_scope
        Api::Scope.new(content: current_scope)
      end
    end
  end
end
