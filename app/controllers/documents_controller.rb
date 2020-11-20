# frozen_string_literal: true

class DocumentsController < ApplicationController
  skip_before_action :doorkeeper_authorize!

  def download_redirect
    redirect_to Rails.application.routes.url_helpers.rails_blob_url(
      Legacy::File.find_by(id: params[:document_id]).file,
      disposition: "attachment"
    )
  end

  def download_url
    response_handler(url: rails_blob_url(
      Legacy::File.find_by(id: params[:document_id]).file,
      disposition: "attachment"
    ))
  end

  def delete
    @document = Legacy::File.find_by(id: params[:document_id], user_id: organization_user.id)
    if @document.destroy
      response_handler(deleted: true)
    else
      response_handler(deleted: false)
    end
  end
end
