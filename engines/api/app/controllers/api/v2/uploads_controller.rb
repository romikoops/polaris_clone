# frozen_string_literal: true

require_dependency "api/api_controller"

module Api
  module V2
    class UploadsController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:create]
      before_action :authenticate, only: [:create]

      def create
        ExcelDataServices::UploaderJob.perform_later(document_id: document.id, options: {
          user_id: upload_user.id,
          group_id: upload_params[:group_id]
        })
        render json: {status: 200}
      end

      private

      def authenticate
        authenticate_or_request_with_http_token do |token, options|
          ActiveSupport::SecurityUtils.secure_compare(Settings.uploads.secret, token)
        end
      end

      def upload_params
        params.permit(:group_id, :organization_id)
      end

      def file_params
        params.require(:file)
      end

      def document
        Legacy::File.create!(
          text: [current_organization.slug, Time.zone.now.strftime("%s")].join("_"),
          doc_type: "v2_uploads",
          organization: current_organization,
          user: upload_user,
          file: {
            io: file,
            filename: "#{document_slug}.xlsx"
          }
        )
      end

      def upload_user
        Users::User.find_by(email: "shopadmin@itsmycargo.com")
      end

      def file
        @file ||= URI.parse(file_params).open
      end

      def document_slug
        @document_slug ||= [current_organization.slug, Time.zone.now.strftime("%s")].join("_")
      end
    end
  end
end
