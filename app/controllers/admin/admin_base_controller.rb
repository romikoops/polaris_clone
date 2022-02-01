# frozen_string_literal: true

module Admin
  class AdminBaseController < ApplicationController
    include Api::UsersUserAccess

    protected

    def open_file(file)
      Roo::Spreadsheet.open(file)
    end

    def handle_upload(params:, text:, type:, options: {})
      upload = ExcelDataServices::Upload.create!(
        organization: current_organization,
        user: current_user,
        status: "not_started",
        file_attributes: {
          text: text,
          doc_type: type,
          organization: current_organization,
          user: current_user,
          file: params[:file]
        }
      )
      ExcelDataServices::UploaderJob.perform_later(
        upload_id: upload.id,
        options: { user_id: current_user&.id }.merge(options)
      )

      response_handler({ has_errors: false, async: true })
    end

    def handle_download(category_identifier:, file_name:, options: {})
      ExcelDataServices::DownloaderJob.perform_later(
        organization: current_organization,
        category_identifier: category_identifier,
        file_name: file_name,
        user: current_user,
        options: options
      )

      response_handler(
        key: category_identifier,
        success_message: "#{category_identifier} sheet will be e-mailed to #{current_user.email}"
      )
    end

    def stop_index_json(stop:)
      stop.as_json(
        include: {
          hub: {
            include: {
              nexus: { only: %i[id name] },
              address: { only: %i[longitude latitude geocoded_address] }
            },
            only: %i[id name]
          }
        },
        only: %i[id hub_id itinerary_id index]
      )
    end
  end
end
