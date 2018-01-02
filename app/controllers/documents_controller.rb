class DocumentsController < ApplicationController
	skip_before_action :require_authentication!

	def	download_redirect
		@url = Document.get_file_url(params[:document_id])
		redirect_to @url
	end
  def delete
    @document = Document.delete_document(params[:document_id])
    response_handler({deleted: true})
  end
end
