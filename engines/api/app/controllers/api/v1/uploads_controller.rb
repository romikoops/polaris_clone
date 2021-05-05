# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V1
    class UploadsController < ApiController
      skip_before_action :doorkeeper_authorize!, :ensure_organization!
      before_action :authenticate_request!

      FileWrapper = Struct.new(:content_type, :filename, :file_or_string, keyword_init: true)

      def create
        upload_pipeline.perform

        render json: { message: upload_pipeline.message }, status: :created
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

      def upload_pipeline
        @upload_pipeline ||= Api::UploadPipelines::Base
          .get(pipeline: integration_token.pipeline)
          .new(organization_id: integration_token.organization_id, file_wrapper: file_wrapper)
      end

      def file_wrapper
        @file_wrapper ||=
          case request.content_type
          when "application/json"
            FileWrapper.new(
              content_type: "application/json",
              filename: "#{SecureRandom.uuid}.json",
              file_or_string: case_invariant_params.require(:json_data)
            )
          when "multipart/form-data"
            uploaded_file = case_invariant_params.require(:file)

            FileWrapper.new(
              content_type: uploaded_file.content_type,
              filename: uploaded_file.original_filename,
              file_or_string: uploaded_file.tempfile
            )
          else
            render json: { message: "Unsupported Content-Type" }, status: :unsupported_media_type and return
          end
      end

      def case_invariant_params
        params.transform_keys(&:underscore)
      end
    end
  end
end
