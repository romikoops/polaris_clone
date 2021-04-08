# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class SettingsController < ApiController
      skip_before_action :ensure_organization!, only: :show

      def show
        render json: Api::V1::SettingSerializer.new(settings)
      end

      private

      def settings
        @settings ||= current_user.settings
      end
    end
  end
end
