# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class ActiveLocodesController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:show]

      def show
        render json: { data: active_locode_lookup }
      end

      private

      def active_locode_lookup
        @active_locode_lookup ||= Api::ActiveLocodeLookup.new.perform
      end
    end
  end
end
