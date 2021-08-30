# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class UploadsController < ApiController
      skip_before_action :doorkeeper_authorize!, only: %i[create show]
      before_action :authenticate, only: %i[create show]

      def show
        render json: ExcelDataServices::Upload.find(params[:id]), status: :ok
      end

      def create
        if upload.save
          ExcelDataServices::UploaderJob.perform_later(
            upload_id: upload.id,
            options: {
              user_id: upload_user.id,
              group_id: upload_params[:group_id]
            }
          )

          render json: Api::V2::UploadsSerializer.new(upload), status: :created
        else
          render json: { errors: [{ status: "500", title: "Unable to create upload" }] }, status: :internal_server_error
        end
      end

      private

      def authenticate
        authenticated = authenticate_with_http_token do |token, _options|
          ActiveSupport::SecurityUtils.secure_compare(Settings.uploads.secret, token)
        end

        head :unauthorized unless authenticated
      end

      def upload
        @upload ||= ExcelDataServices::Upload.new(
          organization: current_organization,
          user: current_user,
          status: "not_started",
          file_attributes: {
            text: slug_with_time,
            doc_type: "v2_uploads",
            organization: current_organization,
            user: upload_user,
            file: ActiveStorage::Blob.build_after_upload(
              io: file,
              filename: original_filename
            )
          }
        )
      end

      def upload_user
        Users::User.find_by(email: "shopadmin@itsmycargo.com")
      end

      def file
        @file ||= URI.parse(file_params).open
      end

      def file_params
        @file_params ||= params.require(:file)
      end

      def slug_with_time
        [current_organization.slug, Time.zone.now.strftime("%s")].join("_")
      end

      def original_filename
        CGI.unescape(File.basename(URI.parse(file_params).path))
      end

      def upload_params
        params.permit(:group_id, :organization_id)
      end
    end
  end
end
