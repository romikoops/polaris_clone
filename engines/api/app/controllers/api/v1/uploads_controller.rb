# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class UploadsController < ApiController
      skip_before_action :doorkeeper_authorize!, :ensure_organization!
      before_action :authenticate_request!

      def create
        if file.present? && uploaded?(s3_response: s3_upload)
          head 201
        else
          render json: { message: "Error uploading object: etag is missing" }, status: :unprocessable_entity
        end
      rescue Aws::S3::Errors::ServiceError => e
        render json: { message: "Error uploading object: #{e.message}" }, status: :unprocessable_entity
      end

      private

      def authenticate_request!
        head :unauthorized if auth_token.nil? || integration_token.nil?
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

      def uploaded?(s3_response:)
        s3_response.etag.present?
      end

      def s3_upload
        s3_client.put_object(
          bucket: Settings.aws.ingest_bucket,
          key: "#{integration_token.organization_id}/okargo_#{file.original_filename}",
          body: file.read,
          content_type: file.content_type
        )
      end

      def s3_client
        @s3_client ||= Aws::S3::Client.new
      end

      def file
        @file ||= params.require(:file)
      end
    end
  end
end
