# frozen_string_literal: true

module Api
  module V1
    class WidgetsController < ApiController
      skip_before_action :doorkeeper_authorize!, only: :index, raise: false

      def index
        widgets = CmsData::Widget.where(organization: current_organization)
        render json: WidgetSerializer.new(widgets)
      end
    end
  end
end
