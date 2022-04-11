# frozen_string_literal: true

module Api
  module V2
    class FileDescriptorsController < ApiController
      skip_before_action :doorkeeper_authorize!
      before_action :authenticate, only: %i[create]
      before_action :validate_required_params, only: :create

      def create
        file_descriptor_arguments.delete(:organization_slug)
        file_descriptor = Api::FileDescriptor.new(file_descriptor_arguments)
        render json: { errors: file_descriptor.errors }, status: :unprocessable_entity and return unless file_descriptor.save

        render json: Api::V2::FileDescriptorSerializer.new(file_descriptor), status: :created
      end

      private

      def authenticate
        authenticated = authenticate_with_http_token do |token, _options|
          ActiveSupport::SecurityUtils.secure_compare(Settings.uploads.secret, token)
        end

        head :unauthorized unless authenticated
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
