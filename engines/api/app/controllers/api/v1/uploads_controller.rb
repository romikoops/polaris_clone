# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class UploadsController < ApiController
      skip_before_action :doorkeeper_authorize!, :ensure_organization!
      before_action :authenticate_request!
      before_action :file_params, only: [:create]

      def create
        s3_upload && (render json: { message: "File uploaded" }, status: :created)
      rescue Aws::S3::Errors::ServiceError => e
        render json: { message: "Error uploading object: #{e.message}" }, status: :unprocessable_entity
      end

      private

      def authenticate_request!
        render json: { message: "Unauthorized Request" }, status: :unauthorized if auth_token.nil? || integration_token.nil?
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

      def file_params
        @file_params ||= case request.content_type
                         when "application/json"
                           {
                             content_type: "application/json",
                             filename: "#{SecureRandom.uuid}.json",
                             file_or_string: case_invariant_params.require(:json_data)
                           }
                         when "multipart/form-data"
                           uploaded_file = case_invariant_params.require(:file)

                           {
                             content_type: uploaded_file.content_type,
                             filename: uploaded_file.original_filename,
                             file_or_string: uploaded_file.tempfile
                           }
                         else
                           render json: { message: "Unsupported Content-Type" }, status: :unsupported_media_type and return
                         end
      end

      def case_invariant_params
        params.transform_keys(&:underscore)
      end

      def s3_upload
        response = Aws::S3::Client.new.put_object(
          bucket: Settings.aws.ingest_bucket,
          content_type: file_params[:content_type],
          key: "#{integration_token.organization_id}/#{file_params[:filename]}",
          body: file_params[:file_or_string]
        )

        response.etag.present? || (raise Aws::S3::Errors::ServiceError.new("etag is missing", nil))
      end
    end
  end
end
