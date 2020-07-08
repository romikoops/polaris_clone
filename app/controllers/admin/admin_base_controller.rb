# frozen_string_literal: true

class Admin::AdminBaseController < ApplicationController
  protected

  def open_file(file)
    Roo::Spreadsheet.open(file)
  end

  def handle_upload(params:, text:, type:, options: {})
    document = Legacy::File.create!(
      text: text,
      doc_type: type,
      sandbox: @sandbox,
      organization: current_organization,
      file: params[:file]
    )

    file = params[:file].tempfile
    options = {
      organization: current_organization,
      file_or_path: file,
      options: options.merge(document: document)
    }
    uploader = ExcelDataServices::Loaders::Uploader.new(options)

    response_handler(uploader.perform)
  end

  def stop_index_json(stop:)
    stop.as_json(include: {
      hub: {
        include: {
          nexus: { only: %i[id name] },
          address: { only: %i[longitude latitude geocoded_address] }
        },
        only: %i[id name]
      }
    })
  end
end
