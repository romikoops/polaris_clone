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
      organization: current_organization,
      file: params[:file]
    )

    ## Async Uploader
    UploaderJob.perform_later(document_id: document.id, options: {
      user_id: options[:user]&.id,
      group_id: options[:group_id],
      applicable: options[:applicable]
    })
    response_handler({has_errors: false, async: true})
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
