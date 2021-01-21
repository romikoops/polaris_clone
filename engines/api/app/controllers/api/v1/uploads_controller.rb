# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class UploadsController < ApiController
      skip_before_action :doorkeeper_authorize!, :ensure_organization!
      before_action :authenticate_request!

      def create
        if uploaded?(s3_response: s3_upload)
          head :ok
        else
          render json: {message: "Error uploading object: etag is missing"}, status: :unprocessable_entity
        end
      rescue Aws::S3::Errors::ServiceError => e
        render json: {message: "Error uploading object: #{e.message}"}, status: :unprocessable_entity
      end

      private

      def uploaded?(s3_response:)
        s3_response.etag.present?
      end

      def s3_upload
        s3_client.put_object(
          bucket: Settings.aws.ingest_bucket,
          key: "#{@token.organization_id}/okargo_#{file.original_filename}",
          body: file.read,
          content_type: file.content_type
        )
      end

      def s3_client
        @s3_client ||= Aws::S3::Client.new
      end

      def file
        @file ||= params[:file]
      end

      def auth_header
        request.headers["Authorization"]
      end

      def authenticate_request!
        @token = Organizations::IntegrationToken.where("expires_at > NOW()").find_by(
          token: auth_header,
          scope: "pricings.upload"
        )
        head :unauthorized if @token.blank?
      end
    end
  end
end
