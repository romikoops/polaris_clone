# frozen_string_literal: true

module Api
  module V2
    class ThemesController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:show]

      def show
        render json: ThemeSerializer.new(current_organization.theme)
      end
    end
  end
end
