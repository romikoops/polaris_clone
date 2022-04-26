# frozen_string_literal: true

module Api
  module V2
    class FileDescriptorsController < ApiController
      skip_before_action :doorkeeper_authorize!
      before_action :authenticate_request!, only: %i[create]
      before_action :validate_required_params, only: :create

      def create
        file_descriptor_arguments.delete(:organization_slug)
        file_descriptor = Api::FileDescriptor.new(file_descriptor_arguments)
        render json: { errors: file_descriptor.errors }, status: :unprocessable_entity and return unless file_descriptor.save

        render json: Api::V2::FileDescriptorSerializer.new(file_descriptor), status: :created
      end

      private

      def authenticate_request!
        render json: { message: "Unauthorized Request" }, status: :unauthorized if [auth_token, integration_token].any?(&:nil?)
      end

      def auth_token
        @auth_token ||= begin
          token, _options = ActionController::HttpAuthentication::Token.token_and_options(request)
          token
        end
      end

      def integration_token
        @integration_token ||= Organizations::IntegrationToken.active.find_by(
          token: auth_token,
          scope: "pricings.upload"
        )
      end

      def file_descriptor_arguments
        @file_descriptor_arguments ||= file_descriptor_create_params.to_h
          .deep_transform_keys { |key| key.to_s.underscore.to_sym }
          .merge(status: "ready", organization_id: organization_id)
      end

      def file_descriptor_create_params
        @file_descriptor_create_params ||= params.require(:fileDescriptor).permit(permittable_params)
      end

      def organization_id
        @organization_id ||= Organizations::Organization.find_by(slug: file_descriptor_create_params[:organizationSlug]).id
      end

      def permittable_params
        %i[filePath fileType originator source sourceType organizationSlug fileCreatedAt fileUpdatedAt syncedAt]
      end

      def validate_required_params
        required_params = %i[filePath fileType originator source sourceType organizationSlug]
        file_descriptor_create_params.require(required_params)
      end
    end
  end
end
