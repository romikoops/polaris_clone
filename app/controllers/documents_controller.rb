class DocumentsController < ApplicationController
	skip_before_action :require_authentication!
  include DocumentTools
	def	download_redirect
		@url = Document.get_file_url(params[:document_id])
		redirect_to @url
	end

  def delete
    @document = Document.find(params[:document_id])
    if current_user && current_user.id == @document.user_id
      Document.delete_document(params[:document_id])
      response_handler({deleted: true})
    else
      response_handler({deleted: false})
    end
  end

end
