# frozen_string_literal: true

class DocumentsController < ApplicationController
  skip_before_action :require_authentication!

  def download_redirect
    redirect_to rails_blob_url(Document.find(params[:document_id]).file, disposition: 'attachment')
  end

  def delete
    @document = Document.find_by(id: params[:document_id], user_id: current_user.id)
    if @document.destroy
      response_handler(deleted: true)
    else
      response_handler(deleted: false)
    end
  end
end
