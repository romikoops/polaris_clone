# frozen_string_literal: true

module Api
  module V2
    class UsersInteractionsController < ApiController
      def index
        render json: { data: Tracker::UsersInteraction.where(client_id: current_user.id).map(&:name) }
      end

      def create
        render json: { error_code: "undefined_interaction", success: false }, status: :unprocessable_entity and return if interaction.blank?

        Tracker::UsersInteraction.create(client: current_user, interaction: interaction)

        render json: { success: true }, status: :created
      end

      private

      def create_params
        @create_params ||= params.require(:userInteraction).permit(:interactionName).to_h.deep_transform_keys { |key| key.to_s.underscore.to_sym }
      end

      def interaction
        @interaction ||= Tracker::Interaction.find_by(name: create_params[:interaction_name], organization_id: current_organization.id)
      end
    end
  end
end
