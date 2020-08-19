# frozen_string_literal: true

module Api
  module V1
    class WidgetsController < ApiController
      skip_before_action :doorkeeper_authorize!, only: :index, raise: false
      before_action :ensure_admin!, only: %i[create update destroy]

      def index
        widgets = CmsData::Widget.where(organization: current_organization)
        render json: WidgetSerializer.new(widgets)
      end

      def create
        widget = CmsData::Widget.new(widget_params.merge(organization: current_organization))
        if widget.save
          render json: WidgetSerializer.new(widget), status: :created
        else
          render json: {errors: widget.errors}, status: :unprocessable_entity
        end
      end

      def update
        if widget.update(widget_params)
          render json: WidgetSerializer.new(widget)
        else
          render json: {errors: widget.errors}, status: :unprocessable_entity
        end
      end

      def destroy
        widget.destroy
        head :no_content
      end

      private

      def widget_params
        params.require(:widget).permit(:name, :order, :data)
      end

      def widget
        @widget ||= CmsData::Widget.find(params[:id])
      end

      def ensure_admin!
        head :forbidden unless Organizations::Membership.exists?(organization: current_organization,
                                                                 user: current_user,
                                                                 role: "admin")
      end
    end
  end
end
