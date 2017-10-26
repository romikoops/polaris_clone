class DocumentsController < ApplicationController
	def	download_redirect
		
		@url = Document.get_file_url(params[:document_id])
		redirect_to @url
	end
end
